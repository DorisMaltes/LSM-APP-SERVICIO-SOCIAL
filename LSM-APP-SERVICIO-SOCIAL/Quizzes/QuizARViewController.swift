//
//  QuizARViewController.swift
//  LSM-APP-SERVICIO-SOCIAL
//
//  Created by Doris Elena  on 12/01/25.
//


//EN ESTE CODIGUIN ES DONDE SE AGREGA LA BIBLIOTECA DE MODELOS 🚩🚩🚩🚩🚩🚩🚩🚩 <--- si ves esta flag es donde hay que poner los nuevos modelos de las categorias
import UIKit
import ARKit
import Vision
import CoreML
import SwiftUI

class QuizARViewController: UIViewController, ARSessionDelegate {
    
    // 1) Datos recibidos
    var palabraEsperada: String = ""
    var categoryName: String = ""

    // 2) Binders
    var isCorrect: Binding<Bool>? = nil
    var isIncorrect: Binding<Bool>? = nil
    var detectionText: Binding<String>? = nil
    
    // 3) Modelo unificado
    private var handActionModel: MLModelWrapper!

    // 4) Parámetros
    private let queueSize = 60
    private let queueSamplingCount = 55
    private let handPosePredictionInterval = 2
    private let handActionConfidenceThreshold: Double = 0.8

    // 5) Colas
    private var queueLeft = [MLMultiArray]()
    private var queueRight = [MLMultiArray]()

    // contadores
    private var frameCounter = 0
    private var queueSamplingCounterLeft = 0
    private var queueSamplingCounterRight = 0

    // 6) ARSCNView
    private var arView: ARSCNView!
    private var rotateLabel: UILabel?

    // MARK: - viewDidLoad
    override func viewDidLoad() {
        super.viewDidLoad()

        arView = ARSCNView(frame: view.bounds)
        arView.session.delegate = self
        view.addSubview(arView)

        setupRotateLabel()
        configureARSession()

        // Diccionario de modelos, aqui agregar todas!!! 🚩❣️
        do {
            let modelRegistry: [String: () throws -> MLModel] = [
                "Personas": { try Personas(configuration: MLModelConfiguration()).model },
                "Alfabeto": { try Alfabeto(configuration: MLModelConfiguration()).model },
                
                // "Animales": { try Animales(configuration: MLModelConfiguration()).model },
                // etc...
            ]
            if let constructor = modelRegistry[categoryName] {
                let mlModel = try constructor()
                handActionModel = MLModelWrapper(model: mlModel)
            } else {
                let fallbackModel = try Personas(configuration: MLModelConfiguration()).model
                handActionModel = MLModelWrapper(model: fallbackModel)
            }
        } catch {
            fatalError("No se pudo cargar el modelo quiz para categoria \(categoryName): \(error)")
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

    private func configureARSession() {
        let config = ARFaceTrackingConfiguration()
        arView.session.run(config, options: [.resetTracking, .removeExistingAnchors])
    }

    // MARK: - rotate label
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

    // MARK: - ARSessionDelegate => predicción
    func session(_ session: ARSession, didUpdate frame: ARFrame) {
        let pixelBuffer = frame.capturedImage
        
        let request = VNDetectHumanHandPoseRequest()
        request.maximumHandCount = 2
        
        let handler = VNImageRequestHandler(cvPixelBuffer: pixelBuffer, options: [:])
        do { try handler.perform([request]) } catch {
            print("Error VNDetectHumanHandPoseRequest: \(error)")
            return
        }

        guard let handPoses = request.results, !handPoses.isEmpty else { return }

        frameCounter += 1
        if frameCounter % handPosePredictionInterval == 0 {
            var leftCandidate: (String, Double)? = nil
            var rightCandidate: (String, Double)? = nil

            for handObs in handPoses {
                guard let keypoints = try? handObs.keypointsMultiArray() else { continue }

                if handObs.chirality == .left {
                    queueLeft.append(keypoints)
                    queueLeft = Array(queueLeft.suffix(queueSize))
                    queueSamplingCounterLeft += 1

                    if queueLeft.count == queueSize && queueSamplingCounterLeft % queueSamplingCount == 0 {
                        do {
                            let (label, probs) = try handActionModel.prediction(poses: queueLeft)
                            if let conf = probs[label], conf > handActionConfidenceThreshold {
                                leftCandidate = (label, conf)
                            }
                        } catch {
                            print("Fallo prediccion izq: \(error)")
                        }
                    }
                }
                else if handObs.chirality == .right {
                    queueRight.append(keypoints)
                    queueRight = Array(queueRight.suffix(queueSize))
                    queueSamplingCounterRight += 1

                    if queueRight.count == queueSize && queueSamplingCounterRight % queueSamplingCount == 0 {
                        do {
                            let (label, probs) = try handActionModel.prediction(poses: queueRight)
                            if let conf = probs[label], conf > handActionConfidenceThreshold {
                                rightCandidate = (label, conf)
                            }
                        } catch {
                            print("Fallo prediccion der: \(error)")
                        }
                    }
                }
            }
            
            // Determinar la seña final
            if leftCandidate != nil || rightCandidate != nil {
                var finalLabel = ""
                var finalConf: Double = 0.0

                if let l = leftCandidate, let r = rightCandidate, l.0 == r.0 {
                    finalLabel = l.0
                    finalConf = max(l.1, r.1)
                } else if let l = leftCandidate, rightCandidate == nil {
                    finalLabel = l.0
                    finalConf = l.1
                } else if let r = rightCandidate, leftCandidate == nil {
                    finalLabel = r.0
                    finalConf = r.1
                } else if let l = leftCandidate, let r = rightCandidate {
                    if l.1 >= r.1 {
                        finalLabel = l.0
                        finalConf = l.1
                    } else {
                        finalLabel = r.0
                        finalConf = r.1
                    }
                }

                DispatchQueue.main.async {
                    guard !finalLabel.isEmpty else { return }

                    let confPct = String(format: "%.2f", finalConf * 100)
                    let newText = "Seña: \(finalLabel) | Conf: \(confPct)%"
                    self.detectionText?.wrappedValue = newText

                    if finalLabel == self.palabraEsperada {
                        self.isCorrect?.wrappedValue = true
                        self.isIncorrect?.wrappedValue = false
                    } else {
                        self.isCorrect?.wrappedValue = false
                        self.isIncorrect?.wrappedValue = true
                    }
                }
            }
        }
    }
}




