import UIKit
import ARKit
import Vision
import CoreML
import SwiftUI

class TraductorARViewController: UIViewController, ARSessionDelegate {

    private var arView: ARSCNView!
    private var handActionModel: Personas!

    private let queueSize = 60
    private let queueSamplingCount = 55
    private let handPosePredictionInterval = 2
    private let handActionConfidenceThreshold: Double = 0.8

    private var queueLeft = [MLMultiArray]()
    private var queueRight = [MLMultiArray]()

    private var frameCounter = 0
    private var queueSamplingCounterLeft = 0
    private var queueSamplingCounterRight = 0

    private var rotateLabel: UILabel?

    // Bindings con SwiftUI
    var frase: Binding<[String]>? = nil
    var lastDetectedSign: Binding<String?>? = nil
    var shouldStop: Binding<Bool>? = nil

    override func viewDidLoad() {
        super.viewDidLoad()

        arView = ARSCNView(frame: view.bounds)
        arView.session.delegate = self
        view.addSubview(arView)

        setupRotateLabel()
        configureARSession()

        do {
            handActionModel = try Personas(configuration: MLModelConfiguration())
        } catch {
            fatalError("No se pudo cargar el modelo: \(error)")
        }

        UIDevice.current.beginGeneratingDeviceOrientationNotifications()
        NotificationCenter.default.addObserver(self,
                                               selector: #selector(orientationChanged),
                                               name: UIDevice.orientationDidChangeNotification,
                                               object: nil)
        orientationChanged()
    }

    deinit {
        NotificationCenter.default.removeObserver(self)
        UIDevice.current.endGeneratingDeviceOrientationNotifications()
    }

    private func setupRotateLabel() {
        let rotate = UILabel()
        rotate.numberOfLines = 2
        rotate.textColor = .white
        rotate.backgroundColor = UIColor.red.withAlphaComponent(0.7)
        rotate.textAlignment = .center
        rotate.font = .systemFont(ofSize: 16, weight: .bold)
        rotate.text = "Por favor gira tu teléfono a horizontal (landscape)"
        self.rotateLabel = rotate
        view.addSubview(rotate)
    }

    private func configureARSession() {
        let config = ARFaceTrackingConfiguration()
        arView.session.run(config, options: [.resetTracking, .removeExistingAnchors])
    }

    @objc private func orientationChanged() {
        let orientation = UIDevice.current.orientation
        if orientation.isLandscape {
            rotateLabel?.isHidden = true
        } else if orientation.isPortrait {
            rotateLabel?.isHidden = false
        }
        layoutLabels()
    }

    private func layoutLabels() {
        guard let rl = rotateLabel else { return }
        let rw: CGFloat = view.bounds.width - 40
        let rh: CGFloat = 60
        rl.frame = CGRect(x: 20, y: 60, width: rw, height: rh)
    }

    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        layoutLabels()
    }

    func session(_ session: ARSession, didUpdate frame: ARFrame) {
        // Verificamos si shouldStop = true => pausamos la sesión y no inferimos
        if shouldStop?.wrappedValue == true {
            // Pausamos la sesión AR (opcional)
            arView.session.pause()
            return
        }

        let pixelBuffer = frame.capturedImage
        let handPoseRequest = VNDetectHumanHandPoseRequest()
        handPoseRequest.maximumHandCount = 2
        
        let handler = VNImageRequestHandler(cvPixelBuffer: pixelBuffer, options: [:])
        do { try handler.perform([handPoseRequest]) } catch {
            print("Error en VNDetectHumanHandPoseRequest: \(error)")
            return
        }

        guard let handPoses = handPoseRequest.results, !handPoses.isEmpty else { return }

        frameCounter += 1
        
        if frameCounter % handPosePredictionInterval == 0 {
            var leftLabel: (String, Double)? = nil
            var rightLabel: (String, Double)? = nil

            for handObs in handPoses {
                guard let keypoints = try? handObs.keypointsMultiArray() else { continue }

                if handObs.chirality == .left {
                    queueLeft.append(keypoints)
                    queueLeft = Array(queueLeft.suffix(queueSize))
                    queueSamplingCounterLeft += 1

                    if queueLeft.count == queueSize &&
                       queueSamplingCounterLeft % queueSamplingCount == 0 {
                        do {
                            let multi = MLMultiArray(concatenating: queueLeft, axis: 0, dataType: .float32)
                            let pred = try handActionModel.prediction(poses: multi)
                            let lbl = pred.label
                            if let conf = pred.labelProbabilities[lbl],
                               conf > handActionConfidenceThreshold {
                                leftLabel = (lbl, conf)
                            }
                        } catch {
                            print("Predicción mano izq falló: \(error)")
                        }
                    }
                }
                else if handObs.chirality == .right {
                    queueRight.append(keypoints)
                    queueRight = Array(queueRight.suffix(queueSize))
                    queueSamplingCounterRight += 1

                    if queueRight.count == queueSize &&
                       queueSamplingCounterRight % queueSamplingCount == 0 {
                        do {
                            let multi = MLMultiArray(concatenating: queueRight, axis: 0, dataType: .float32)
                            let pred = try handActionModel.prediction(poses: multi)
                            let lbl = pred.label
                            if let conf = pred.labelProbabilities[lbl],
                               conf > handActionConfidenceThreshold {
                                rightLabel = (lbl, conf)
                            }
                        } catch {
                            print("Predicción mano der falló: \(error)")
                        }
                    }
                }
            }
            
            if leftLabel != nil || rightLabel != nil {
                var finalLabel = ""
                var finalConf: Double = 0.0
                
                if let l = leftLabel, let r = rightLabel, l.0 == r.0 {
                    finalLabel = l.0
                    finalConf = max(l.1, r.1)
                } else if let l = leftLabel, rightLabel == nil {
                    finalLabel = l.0
                    finalConf = l.1
                } else if let r = rightLabel, leftLabel == nil {
                    finalLabel = r.0
                    finalConf = r.1
                } else if let l = leftLabel, let r = rightLabel {
                    if l.1 >= r.1 {
                        finalLabel = l.0
                        finalConf = l.1
                    } else {
                        finalLabel = r.0
                        finalConf = r.1
                    }
                }

                if !finalLabel.isEmpty {
                    DispatchQueue.main.async {
                        // Si la seña es "background", ignoramos
                        if finalLabel.lowercased() == "background" {
                            return
                        }

                        // Mostramos la última seña
                        self.lastDetectedSign?.wrappedValue = finalLabel
                        
                        // Añadimos la seña a la frase
                        self.frase?.wrappedValue.append(finalLabel)

                        // O si quieres "desaparecer" lastDetectedSign tras 2 seg:
                        DispatchQueue.main.asyncAfter(deadline: .now() + 2.0) {
                            if self.lastDetectedSign?.wrappedValue == finalLabel {
                                self.lastDetectedSign?.wrappedValue = nil
                            }
                        }
                    }
                }
            }
        }
    }
}
