import SwiftUI
import ARKit
import Vision
import CoreML
import UIKit

// MARK: - PruebaEnVivoSheetView
struct PruebaEnVivoSheetView: View {
    let videoName: String // Seña esperada
    let categoryName: String

    @Environment(\.presentationMode) var presentationMode
    
    // Estados para mostrar overlays
    @State private var isCorrect = false
    @State private var isIncorrect = false
    
    // Nuevo: para mostrar la detección en SwiftUI
    @State private var detectionText = "Esperando detecciones..."

    var body: some View {
        ZStack {
            // 1. Cámara + inferencia
            CameraSessionView(
                videoName: videoName,
                categoryName: categoryName,
                isCorrect: $isCorrect,
                isIncorrect: $isIncorrect,
                detectionText: $detectionText
            )
            .edgesIgnoringSafeArea(.all)

            // 2. Etiqueta de detección en SwiftUI para que no haya problemas despues lol
            VStack {
                Text(detectionText)
                    .font(.headline)
                    .foregroundColor(.white)
                    .padding(8)
                    .background(Color.black.opacity(0.6))
                    .cornerRadius(8)
                    .rotationEffect(.degrees(90))
                    .padding(.leading,190)
        
            }
                
            
            // 3. Overlay "¡Correcto!"
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
                .rotationEffect(.degrees(90))
                .padding()
                .background(Color.black.opacity(0.7))
                .cornerRadius(12)
            }

            // 4. Overlay "¡Incorrecto!"
            if isIncorrect {
                VStack {
                    Text("¡Incorrecto!")
                        .font(.largeTitle)
                        .foregroundColor(.white)
                        .padding()
                }
                .padding()
                .background(Color.black.opacity(0.7))
                .cornerRadius(12)
                .rotationEffect(.degrees(90))
            }
        }
    }
}

// MARK: - CameraSessionView
struct CameraSessionView: View {
    let videoName: String
    let categoryName: String
    @Binding var isCorrect: Bool
    @Binding var isIncorrect: Bool
    
    // Recibimos la detección desde ARViewController
    @Binding var detectionText: String

    var body: some View {
        ZStack {
            CameraSessionRepresentable(
                videoName: videoName,
                categoryName: categoryName,
                isCorrect: $isCorrect,
                isIncorrect: $isIncorrect,
                detectionText: $detectionText
            )
        }
    }
}

// MARK: - CameraSessionRepresentable
struct CameraSessionRepresentable: UIViewControllerRepresentable {
    
    let videoName: String
    let categoryName: String
    @Binding var isCorrect: Bool
    @Binding var isIncorrect: Bool
    @Binding var detectionText: String

    func makeUIViewController(context: Context) -> ARViewController {
        let arVC = ARViewController()
        arVC.videoName = videoName
        arVC.categoryName = categoryName
        arVC.isCorrect = $isCorrect
        arVC.isIncorrect = $isIncorrect
        arVC.detectionText = $detectionText  // <-- Nuevo
        return arVC
    }

    func updateUIViewController(_ uiViewController: ARViewController, context: Context) {}
}

// MARK: - ARViewController
class ARViewController: UIViewController, ARSessionDelegate {
    
    // === Modelo CoreML ===
    private var handActionModel: MLModelWrapper!

    // === Parámetros ===
    private let queueSize = 60
    private let queueSamplingCount = 55
    private let handPosePredictionInterval = 2
    private let handActionConfidenceThreshold: Double = 0.8

    // === Colas de frames por mano ===
    private var queueLeft = [MLMultiArray]()
    private var queueRight = [MLMultiArray]()

    // === Contadores de frames ===
    private var frameCounter = 0
    private var queueSamplingCounterLeft = 0
    private var queueSamplingCounterRight = 0

    // === ARSCNView ===
    private var arView: ARSCNView!
    private var rotateLabel: UILabel?    // Indica “Por favor gira tu teléfono a horizontal”

    // Datos de SwiftUI
    var videoName: String = ""
    var categoryName: String = ""
    
    var isCorrect: Binding<Bool>? = nil
    var isIncorrect: Binding<Bool>? = nil
    
    // NUEVO: Binding para texto de detección
    var detectionText: Binding<String>? = nil

    // MARK: - viewDidLoad
    override func viewDidLoad() {
        super.viewDidLoad()

        // 1. ARSCNView
        arView = ARSCNView(frame: view.bounds)
        arView.session.delegate = self
        view.addSubview(arView)

        // 2. Etiqueta de "rotar el teléfono"
        setupRotateLabel()

        // 3. Configurar AR
        configureARSession()

        // 4. Cargar modelo, MOVERLE AQUI PARA AGREGAR LOS DEMAS MODELOS!!!! 🗿
        do {
            let modelRegistry: [String: () throws -> MLModel] = [
                "Personas": { try Personas(configuration: MLModelConfiguration()).model },
                "Alfabeto": { try Alfabeto(configuration: MLModelConfiguration()).model },
                // etc. Para otras categorías...
            ]
            // Buscamos el constructor según categoryName
                        if let constructor = modelRegistry[categoryName] {
                            let mlModel = try constructor()  // MLModel
                            
                            // Envolvemos con un MLModelWrapper (definido más abajo)
                            handActionModel = MLModelWrapper(model: mlModel)
                        } else {
                            // fallback: si no existe la key, usa "Personas" por ejemplo
                            let mlModel = try Personas(configuration: MLModelConfiguration()).model
                            handActionModel = MLModelWrapper(model: mlModel)
                        }
            
        }
        
        catch {
            fatalError("No se pudo cargar el modelo: \(error)")
        }

        // 5. Notificaciones de orientación
        UIDevice.current.beginGeneratingDeviceOrientationNotifications()
        NotificationCenter.default.addObserver(
            self,
            selector: #selector(orientationChanged),
            name: UIDevice.orientationDidChangeNotification,
            object: nil
        )
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

    // MARK: - setupRotateLabel
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

    // MARK: - ARSessionDelegate
    func session(_ session: ARSession, didUpdate frame: ARFrame) {
        let pixelBuffer = frame.capturedImage
        
        let request = VNDetectHumanHandPoseRequest()
        request.maximumHandCount = 2
        
        let handler = VNImageRequestHandler(cvPixelBuffer: pixelBuffer, options: [:])
        do {
            try handler.perform([request])
        } catch {
            print("Error en VNDetectHumanHandPoseRequest: \(error)")
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

                    if queueLeft.count == queueSize &&
                       queueSamplingCounterLeft % queueSamplingCount == 0 {
                        do {
                            let poses = MLMultiArray(concatenating: queueLeft, axis: 0, dataType: .float32)
                            let prediction = try handActionModel.prediction(poses: poses)
                            let lbl = prediction.label
                            if let conf = prediction.labelProbabilities[lbl],
                               conf > handActionConfidenceThreshold {
                                leftCandidate = (lbl, conf)
                            }
                        } catch {
                            print("Fallo prediccion izq: \(error)")
                        }
                    }
                } else if handObs.chirality == .right {
                    queueRight.append(keypoints)
                    queueRight = Array(queueRight.suffix(queueSize))
                    queueSamplingCounterRight += 1

                    if queueRight.count == queueSize &&
                       queueSamplingCounterRight % queueSamplingCount == 0 {
                        do {
                            let poses = MLMultiArray(concatenating: queueRight, axis: 0, dataType: .float32)
                            let prediction = try handActionModel.prediction(poses: poses)
                            let lbl = prediction.label
                            if let conf = prediction.labelProbabilities[lbl],
                               conf > handActionConfidenceThreshold {
                                rightCandidate = (lbl, conf)
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
                    // Asignamos el texto al binding detectionText
                    guard !finalLabel.isEmpty else { return }
                    
                    let confPct = String(format: "%.2f", finalConf * 100)
                    let newText = "Seña: \(finalLabel) | Conf: \(confPct)%"
                    self.detectionText?.wrappedValue = newText

                    if finalLabel == self.videoName {
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

/// MLModelWrapper se encarga de unificar la firma de predicción(poses: [MLMultiArray]) -> (label, labelProb).
/// Asume que tus modelos (Personas, Animales, etc.) generan la misma firma "public func prediction(poses: MLMultiArray)".
class MLModelWrapper {
    private let mlModel: MLModel

    init(model: MLModel) {
        self.mlModel = model
    }

    /// Predicción con array de MLMultiArray (varios frames)
    func prediction(poses: [MLMultiArray]) throws -> (label: String, labelProbabilities: [String: Double]) {
        let concat = MLMultiArray(concatenating: poses, axis: 0, dataType: .float32)
        return try prediction(poses: concat)
    }

    /// Predicción con un solo MLMultiArray
    func prediction(poses: MLMultiArray) throws -> (label: String, labelProbabilities: [String: Double]) {
        // Intentamos instanciar la clase autogenerada "Personas" con este MLModel,
        // y si funciona, llamamos su .prediction(poses:).
        if let modeloPersonas = try? Personas(model: self.mlModel) {
            let out = try modeloPersonas.prediction(poses: poses)
            return (out.label, out.labelProbabilities)
        }
        else if let modeloAlfabeto = try? Alfabeto(model: self.mlModel) {
            let out = try modeloAlfabeto.prediction(poses: poses)
            return (out.label, out.labelProbabilities)
        } //🗿AQUI TAMBIEN HAY QUE AGREGAR LAS OTRS
        // este es un ejemplo de como deberiamos poner los sigueintes modelos, solo hay 16 categorias entonces aqui deberia de haber 16 categorias:
        // else if let modeloAnimales = try? Animales(model: self.mlModel) {
        //     let out = try modeloAnimales.prediction(poses: poses)
        //     return (out.label, out.labelProbabilities)
        // }
        else {
            throw NSError(domain: "MLModelWrapper",
                          code: -1,
                          userInfo: [NSLocalizedDescriptionKey: "No se reconoció el tipo de MLModel"])
        }
    }
}


#Preview {
    PruebaEnVivoSheetView(videoName: "El", categoryName: "Personas")
}
