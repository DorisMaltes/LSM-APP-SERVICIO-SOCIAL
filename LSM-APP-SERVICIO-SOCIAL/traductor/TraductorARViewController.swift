//
//  SwiftUIView.swift
//  LSM-APP-SERVICIO-SOCIAL
//
//  Created by Doris Elena  on 12/01/25.
//

import UIKit
import ARKit
import Vision
import CoreML
import SwiftUI

/// UIViewController con la lógica de ARKit + CoreML para el Traductor
class TraductorARViewController: UIViewController, ARSessionDelegate {
    
    // MARK: - ARKit
    private var arView: ARSCNView!
    
    // MARK: - CoreML
    private var handActionModel: PruebaPersonasCategoria2!
    
    // MARK: - Parámetros
    private let queueSize = 60
    private let queueSamplingCount = 55
    private let handPosePredictionInterval = 2
    private let handActionConfidenceThreshold: Double = 0.8

    // Dos colas, una para cada mano
    private var queueLeft = [MLMultiArray]()
    private var queueRight = [MLMultiArray]()
    
    // Contadores
    private var frameCounter = 0
    private var queueSamplingCounterLeft = 0
    private var queueSamplingCounterRight = 0
    
    // Para mostrar en pantalla
    private var detectionLabel: UILabel?

    // --- Binding con SwiftUI ---
    var candidatos: Binding<[String]>? = nil
    
    // MARK: - View Lifecycle
    override func viewDidLoad() {
        super.viewDidLoad()

        // 1. ARSCNView
        arView = ARSCNView(frame: view.bounds)
        arView.session.delegate = self
        view.addSubview(arView)

        // 2. Etiqueta UI
        setupDetectionLabel()

        // 3. Configurar ARSession (cámara frontal)
        configureARSession()

        // 4. Cargar modelo
        do {
            handActionModel = try PruebaPersonasCategoria2(configuration: MLModelConfiguration())
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
        label.font = .systemFont(ofSize: 16, weight: .bold)
        label.text = "Esperando detecciones..."
        
        self.detectionLabel = label
        view.addSubview(label)
    }

    private func configureARSession() {
        let configuration = ARFaceTrackingConfiguration()
        arView.session.run(configuration,
                           options: [.resetTracking, .removeExistingAnchors])
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
            print("Error en VNDetectHumanHandPoseRequest: \(error)")
            return
        }

        guard let handPoses = handPoseRequest.results, !handPoses.isEmpty else { return }
        
        frameCounter += 1
        
        // Solo hacemos inferencia cada X frames
        if frameCounter % handPosePredictionInterval == 0 {
            var finalLabels = [String]() // aquí guardaremos TODAS las señas con conf > threshold
            
            for handObservation in handPoses {
                guard let keypoints = try? handObservation.keypointsMultiArray() else { continue }
                
                // Mano izquierda
                if handObservation.chirality == .left {
                    queueLeft.append(keypoints)
                    queueLeft = Array(queueLeft.suffix(queueSize))
                    queueSamplingCounterLeft += 1
                    
                    if queueLeft.count == queueSize &&
                        queueSamplingCounterLeft % queueSamplingCount == 0 {
                        
                        do {
                            let poses = MLMultiArray(
                                concatenating: queueLeft,
                                axis: 0,
                                dataType: .float32
                            )
                            let prediction = try handActionModel.prediction(poses: poses)
                            
                            // Recorremos TODAS las probabilidades
                            for (label, conf) in prediction.labelProbabilities {
                                if conf > handActionConfidenceThreshold {
                                    finalLabels.append(label)
                                }
                            }
                        } catch {
                            print("Fallo la prediccion (mano izq): \(error)")
                        }
                    }
                }
                // Mano derecha
                else if handObservation.chirality == .right {
                    queueRight.append(keypoints)
                    queueRight = Array(queueRight.suffix(queueSize))
                    queueSamplingCounterRight += 1
                    
                    if queueRight.count == queueSize &&
                        queueSamplingCounterRight % queueSamplingCount == 0 {
                        
                        do {
                            let poses = MLMultiArray(
                                concatenating: queueRight,
                                axis: 0,
                                dataType: .float32
                            )
                            let prediction = try handActionModel.prediction(poses: poses)
                            
                            // Recorremos TODAS las probabilidades
                            for (label, conf) in prediction.labelProbabilities {
                                if conf > handActionConfidenceThreshold {
                                    finalLabels.append(label)
                                }
                            }
                        } catch {
                            print("Fallo la prediccion (mano der): \(error)")
                        }
                    }
                }
            } // fin for handPoses
            
            // Si encontramos señas, las mostramos
            if !finalLabels.isEmpty {
                DispatchQueue.main.async {
                    // Actualizamos la etiqueta con una lista de señas candidatas
                    self.detectionLabel?.text = "Candidatos: " + finalLabels.joined(separator: ", ")
                    // Enviamos a SwiftUI
                    self.candidatos?.wrappedValue = Array(Set(finalLabels))
                    // ^ opcional: convertimos a Set para evitar duplicados
                }
                
                // Feedback háptico
                let impact = UIImpactFeedbackGenerator(style: .light)
                impact.impactOccurred()
            }
        }
    }
}
