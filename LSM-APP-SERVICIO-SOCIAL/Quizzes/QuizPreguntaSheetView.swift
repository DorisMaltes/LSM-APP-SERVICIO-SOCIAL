//
//  QuizPreguntaSheetView.swift
//  LSM-APP-SERVICIO-SOCIAL
//
//  Created by Doris Elena  on 12/01/25.
//

import SwiftUI

struct QuizPreguntaSheetView: View {
    let palabraEsperada: String
    
    /// Callback que se llama al cerrar la sheet
    var onDismiss: (String, Double, Bool) -> Void
    
    @Environment(\.presentationMode) var presentationMode
    
    // Bandera para mostrar el overlay de “¡Correcto!”
    @State private var mostrarCorrecto = false
    
    // Seña detectada
    @State private var señaDetectada = ""
    @State private var confidence: Double = 0.0
    
    var body: some View {
        ZStack {
            // Cámara (ARKit + CoreML)
            QuizCameraView(
                palabraEsperada: palabraEsperada
            ) { labelFinal, conf, esCorrecto in
                // Se llama cada vez que la cámara detecta algo
                señaDetectada = labelFinal
                confidence = conf
                
                if esCorrecto {
                    mostrarCorrecto = true
                }
            }
            .edgesIgnoringSafeArea(.all)
            
            if mostrarCorrecto {
                VStack {
                    Text("¡Correcto!")
                        .font(.largeTitle)
                        .foregroundColor(.white)
                        .padding()
                    
                    Button("Siguiente") {
                        onDismiss(señaDetectada, confidence, true)
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
        .toolbar {
            ToolbarItem(placement: .navigationBarLeading) {
                Button("Cancelar") {
                    // Notificamos que no fue correcto
                    onDismiss(señaDetectada, confidence, false)
                    presentationMode.wrappedValue.dismiss()
                }
            }
        }
    }
}


struct QuizPreguntaSheetView_Previews: PreviewProvider {
    static var previews: some View {
        QuizPreguntaSheetView(
            palabraEsperada: "Alguien"
        ) { label, conf, esCorrecto in
            // Ejemplo
            print("Cierre sheet: label=\(label), conf=\(conf), esCorrecto=\(esCorrecto)")
        }
    }
}


