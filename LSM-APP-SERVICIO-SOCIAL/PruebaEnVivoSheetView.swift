import SwiftUI
import ARKit
import Vision
import CoreML
import UIKit

/// Vista SwiftUI que contiene el ARViewController para la “prueba en vivo”.
struct PruebaEnVivoSheetView: View {
    
    /// El nombre de la palabra que queremos que se detecte (por ej. "Alguien", "Amante", etc.)
    let videoName: String
    
    /// Para cerrar la Sheet
    @Environment(\.presentationMode) var presentationMode
    
    /// Para mostrar mensaje de correcto
    @State private var isCorrect = false
    
    var body: some View {
        ZStack {
            // Cámara + inferencia
            CameraSessionView(videoName: videoName, isCorrect: $isCorrect)
                .edgesIgnoringSafeArea(.all)
            
            // Si detectamos la seña correcta, mostramos overlay
            if isCorrect {
                VStack {
                    Text("¡Correcto!")
                        .font(.largeTitle)
                        .foregroundColor(.white)
                        .padding()
                    
                    Button("Cerrar") {
                        presentationMode.wrappedValue.dismiss()
                    }
                    .padding()
                    .background(Color.white)
                    .foregroundColor(.blue)
                    .cornerRadius(8)
                }
                .padding()
                .background(Color.black.opacity(0.7))
                .cornerRadius(12)
            }
        }
    }
}

/// Este wrapper SwiftUI crea e integra el ARViewController
struct CameraSessionView: View {
    let videoName: String
    @Binding var isCorrect: Bool
    
    var body: some View {
        ZStack {
            CameraSessionRepresentable(videoName: videoName, isCorrect: $isCorrect)
        }
    }
}

/// Representable que gestiona el UIViewController (ARViewController)
struct CameraSessionRepresentable: UIViewControllerRepresentable {
    
    let videoName: String
    @Binding var isCorrect: Bool
    
    func makeUIViewController(context: Context) -> ARViewController {
        let arVC = ARViewController()
        arVC.videoName = videoName
        arVC.isCorrect = $isCorrect  // pasamos el binding
        return arVC
    }
    
    func updateUIViewController(_ uiViewController: ARViewController, context: Context) {}
}
class ARViewController: UIViewController, ARSessionDelegate {
    
    // --- Variables ---

    // Modelo CoreML
    private var handActionModel: PruebaPersonasCategoria2!
    
    // Parametrización
    private let queueSize = 60
    private let queueSamplingCount = 55
    private let handPosePredictionInterval = 2
    private let handActionConfidenceThreshold: Double = 0.8
    
    // Colas para cada mano
    private var queueLeft = [MLMultiArray]()
    private var queueRight = [MLMultiArray]()
    
    // Contadores
    private var frameCounter = 0
    private var queueSamplingCounterLeft = 0
    private var queueSamplingCounterRight = 0
    
    // UILabel para mostrar la seña
    private var detectionLabel: UILabel?
    
    // ARSCNView
    private var arView: ARSCNView!
    
    // --- Datos que vienen de la vista SwiftUI ---
    var videoName: String = ""            // la palabra que queremos detectar
    var isCorrect: Binding<Bool>? = nil   // binding para marcar si está correcto
    
    // --- Ciclo de vida ---
    override func viewDidLoad() {
        super.viewDidLoad()
        
        // 1. Creamos el ARSCNView
        arView = ARSCNView(frame: view.bounds)
        arView.session.delegate = self
        view.addSubview(arView)
        
        // 2. Configurar la etiqueta
        setupDetectionLabel()
        
        // 3. Iniciar la sesión AR
        configureARSession()
        
        // 4. Cargamos el modelo
        do {
            handActionModel = try PruebaPersonasCategoria2(configuration: MLModelConfiguration())
        } catch {
            fatalError("No se pudo cargar el modelo: \(error)")
        }
    }
    
    private func setupDetectionLabel() {
        let label = UILabel(frame: CGRect(x: 20, y: 60, width: view.bounds.width - 40, height: 40))
        label.textColor = .white
        label.backgroundColor = UIColor.black.withAlphaComponent(0.6)
        label.textAlignment = .center
        label.font = UIFont.systemFont(ofSize: 16, weight: .bold)
        label.text = "Esperando detecciones..."
        
        self.detectionLabel = label
        view.addSubview(label)
    }
    
    private func configureARSession() {
        // Cámara frontal
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
            print("Error en VNDetectHumanHandPoseRequest: \(error)")
            return
        }
        
        guard let handPoses = handPoseRequest.results, !handPoses.isEmpty else { return }
        
        frameCounter += 1
        
        // Solo predecimos cada X frames
        if frameCounter % handPosePredictionInterval == 0 {
            
            // Variables para guardar la predicción de cada mano
            var leftLabel: String? = nil
            var leftConfidence: Double = 0.0
            
            var rightLabel: String? = nil
            var rightConfidence: Double = 0.0
            
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
                            let poses = MLMultiArray(concatenating: queueLeft, axis: 0, dataType: .float32)
                            let prediction = try handActionModel.prediction(poses: poses)
                            
                            let labelPred = prediction.label
                            if let conf = prediction.labelProbabilities[labelPred],
                               conf > handActionConfidenceThreshold {
                                leftLabel = labelPred
                                leftConfidence = conf
                            }
                        } catch {
                            print("Predicción mano izq falló: \(error)")
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
                            let poses = MLMultiArray(concatenating: queueRight, axis: 0, dataType: .float32)
                            let prediction = try handActionModel.prediction(poses: poses)
                            
                            let labelPred = prediction.label
                            if let conf = prediction.labelProbabilities[labelPred],
                               conf > handActionConfidenceThreshold {
                                rightLabel = labelPred
                                rightConfidence = conf
                            }
                        } catch {
                            print("Predicción mano der falló: \(error)")
                        }
                    }
                }
            } // fin for handObservation
            
            // Tomar la seña final
            if leftLabel != nil || rightLabel != nil {
                // 1. Si ambas manos coinciden
                if let l = leftLabel, let r = rightLabel, l == r {
                    DispatchQueue.main.async {
                        self.handleGestureDetection(label: l, confidence: 1.0)
                    }
                }
                // 2. De lo contrario, la de mayor confianza
                else {
                    if let l = leftLabel, rightLabel == nil {
                        DispatchQueue.main.async {
                            self.handleGestureDetection(label: l, confidence: leftConfidence)
                        }
                    } else if let r = rightLabel, leftLabel == nil {
                        DispatchQueue.main.async {
                            self.handleGestureDetection(label: r, confidence: rightConfidence)
                        }
                    } else if let l = leftLabel, let r = rightLabel {
                        if leftConfidence >= rightConfidence {
                            DispatchQueue.main.async {
                                self.handleGestureDetection(label: l, confidence: leftConfidence)
                            }
                        } else {
                            DispatchQueue.main.async {
                                self.handleGestureDetection(label: r, confidence: rightConfidence)
                            }
                        }
                    }
                }
            }
        }
    }
    
    private func handleGestureDetection(label: String, confidence: Double) {
        let confPercent = String(format: "%.2f", confidence * 100)
        
        detectionLabel?.text = "Seña: \(label) | Conf: \(confPercent)%"
        
        // 1. Si el label coincide con 'videoName' => marcamos como correcto
        if label == videoName {
            self.isCorrect?.wrappedValue = true
        }
        
        // Feedback háptico
        let impact = UIImpactFeedbackGenerator(style: .medium)
        impact.impactOccurred()
    }
}

#Preview {
    PruebaEnVivoSheetView(videoName: "El")
}
