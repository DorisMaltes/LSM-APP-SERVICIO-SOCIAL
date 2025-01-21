//
//  QuizARViewController.swift
//  LSM-APP-SERVICIO-SOCIAL
//
//  Created by Doris Elena  on 12/01/25.
//

import UIKit
import ARKit
import Vision
import CoreML
import SwiftUI

class QuizARViewController: UIViewController, ARSessionDelegate {
    
    // Dato que esperamos
    var palabraEsperada: String = ""
    // Callback
    var onSignDetected: ((String, Double, Bool) -> Void)?
    
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
    
    private var detectionLabel: UILabel?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        arView = ARSCNView(frame: view.bounds)
        arView.session.delegate = self
        view.addSubview(arView)
        
        setupDetectionLabel()
        configureARSession()
        
        do {
            handActionModel = try Personas(configuration: MLModelConfiguration())
        } catch {
            fatalError("No se pudo cargar el modelo: \(error)")
        }
    }

    private func setupDetectionLabel() {
        let label = UILabel(frame: CGRect(x: 20, y: 60,
                                          width: view.bounds.width - 40,
                                          height: 40))
        
        label.textColor = .white
        label.backgroundColor = UIColor.black.withAlphaComponent(0.6)
        label.textAlignment = .center
        label.font = UIFont.systemFont(ofSize: 16, weight: .bold)
        label.text = "Esperando detecciones..."
        
        self.detectionLabel = label
        view.addSubview(label)
    }

    private func configureARSession() {
        let configuration = ARFaceTrackingConfiguration()
        arView.session.run(configuration, options: [.resetTracking, .removeExistingAnchors])
    }

    // MARK: - ARSessionDelegate
    func session(_ session: ARSession, didUpdate frame: ARFrame) {
        let pixelBuffer = frame.capturedImage
        
        let handPoseRequest = VNDetectHumanHandPoseRequest()
        handPoseRequest.maximumHandCount = 2
        
        let handler = VNImageRequestHandler(cvPixelBuffer: pixelBuffer, options: [:])
        do {
            try handler.perform([handPoseRequest])
        } catch {
            print("Fallo VNDetectHumanHandPoseRequest: \(error)")
            return
        }

        guard let handPoses = handPoseRequest.results, !handPoses.isEmpty else { return }
        
        frameCounter += 1
        
        if frameCounter % handPosePredictionInterval == 0 {
            var labelLeft: (label: String, conf: Double)?
            var labelRight: (label: String, conf: Double)?
            
            for handObservation in handPoses {
                guard let keypoints = try? handObservation.keypointsMultiArray() else { continue }
                
                if handObservation.chirality == .left {
                    queueLeft.append(keypoints)
                    queueLeft = Array(queueLeft.suffix(queueSize))
                    queueSamplingCounterLeft += 1
                    
                    if queueLeft.count == queueSize && queueSamplingCounterLeft % queueSamplingCount == 0 {
                        do {
                            let poses = MLMultiArray(concatenating: queueLeft, axis: 0, dataType: .float32)
                            let pred = try handActionModel.prediction(poses: poses)
                            
                            let lb = pred.label
                            if let cf = pred.labelProbabilities[lb], cf > handActionConfidenceThreshold {
                                labelLeft = (lb, cf)
                            }
                        } catch {
                            print("Fallo prediccion mano izq: \(error)")
                        }
                    }
                }
                else if handObservation.chirality == .right {
                    queueRight.append(keypoints)
                    queueRight = Array(queueRight.suffix(queueSize))
                    queueSamplingCounterRight += 1
                    
                    if queueRight.count == queueSize && queueSamplingCounterRight % queueSamplingCount == 0 {
                        do {
                            let poses = MLMultiArray(concatenating: queueRight, axis: 0, dataType: .float32)
                            let pred = try handActionModel.prediction(poses: poses)
                            
                            let lb = pred.label
                            if let cf = pred.labelProbabilities[lb], cf > handActionConfidenceThreshold {
                                labelRight = (lb, cf)
                            }
                        } catch {
                            print("Fallo prediccion mano der: \(error)")
                        }
                    }
                }
            } // fin for
            
            // Decidir la seña final
            if labelLeft != nil || labelRight != nil {
                var finalLabel = ""
                var finalConf = 0.0
                
                // 1) Si ambas manos coinciden
                if let l = labelLeft, let r = labelRight, l.label == r.label {
                    finalLabel = l.label
                    finalConf = max(l.conf, r.conf)
                }
                // 2) Solo izquierda
                else if let l = labelLeft, labelRight == nil {
                    finalLabel = l.label
                    finalConf = l.conf
                }
                // 3) Solo derecha
                else if let r = labelRight, labelLeft == nil {
                    finalLabel = r.label
                    finalConf = r.conf
                }
                // 4) Ambas difieren => mayor confianza
                else if let l = labelLeft, let r = labelRight {
                    if l.conf >= r.conf {
                        finalLabel = l.label
                        finalConf = l.conf
                    } else {
                        finalLabel = r.label
                        finalConf = r.conf
                    }
                }
                
                if !finalLabel.isEmpty {
                    DispatchQueue.main.async {
                        let confStr = String(format: "%.2f", finalConf * 100)
                        self.detectionLabel?.text = "Seña: \(finalLabel) | \(confStr)%"
                        
                        // ¿Es correcto?
                        let esCorrecto = (finalLabel == self.palabraEsperada)
                        self.onSignDetected?(finalLabel, finalConf, esCorrecto)
                    }
                }
            }
        }
    }
}

