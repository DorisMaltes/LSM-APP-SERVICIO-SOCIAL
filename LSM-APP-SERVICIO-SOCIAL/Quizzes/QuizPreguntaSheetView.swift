//
//  QuizPreguntaSheetView.swift
//  LSM-APP-SERVICIO-SOCIAL
//
//  Created by Doris Elena  on 12/01/25.
//

import SwiftUI

/// Vista para el Quiz, igual a PruebaEnVivoSheetView pero adaptada:
/// - Usa `palabraEsperada` y `categoryName`
/// - Muestra la cámara, la label de detección, overlays
/// - Llama `onDismiss(labelDetectado, conf, esCorrecto)` al tocar "Siguiente"
struct QuizPreguntaSheetView: View {
    let palabraEsperada: String
    let categoryName: String

    // Para avisar al padre (QuizCategoriaView) al cerrar la sheet
    var onDismiss: (String, Double, Bool) -> Void

    @Environment(\.presentationMode) var presentationMode
    
    // Estados de overlays
    @State private var isCorrect = false
    @State private var isIncorrect = false
    
    // Texto de detección que antes estaba en un UILabel
    @State private var detectionText = "Esperando detecciones..."

    var body: some View {
        ZStack {
            // 1. Cámara + inferencia
            QuizCameraView(
                palabraEsperada: palabraEsperada,
                categoriaName: categoryName,
                isCorrect: $isCorrect,
                isIncorrect: $isIncorrect,
                detectionText: $detectionText
            )
            .edgesIgnoringSafeArea(.all)

            // 2. Texto de detección
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

            // 3. "¡Correcto!" => Botón para continuar
            if isCorrect {
                VStack {
                    Text("¡Correcto!")
                        .font(.largeTitle)
                        .foregroundColor(.white)
                        .padding()

                    Button("Siguiente") {
                        // Notificar al padre
                        onDismiss(palabraEsperada, 1.0, true)
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

            // 4. "¡Incorrecto!"
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
        // Botón cancelar en la toolbar (opcional)
        .toolbar {
            ToolbarItem(placement: .navigationBarLeading) {
                Button("Cancelar") {
                    // Si cancela => incorrecto
                    onDismiss(palabraEsperada, 0.0, false)
                    presentationMode.wrappedValue.dismiss()
                }
            }
        }
    }
}



struct QuizPreguntaSheetView_Previews: PreviewProvider {
    static var previews: some View {
        QuizPreguntaSheetView(
            palabraEsperada: "Alguien", categoryName: "Personas"
        ) { label, conf, esCorrecto in
            // Ejemplo
            print("Cierre sheet: label=\(label), conf=\(conf), esCorrecto=\(esCorrecto)")
        }
    }
}


