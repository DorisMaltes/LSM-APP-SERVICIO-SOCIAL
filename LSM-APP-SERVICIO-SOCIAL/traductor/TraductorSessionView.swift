//
//  TraductorSessionView.swift
//  LSM-APP-SERVICIO-SOCIAL
//
//  Created by Doris Elena  on 20/01/25.
//

import SwiftUI


struct TraductorSessionView: View {
    @Environment(\.presentationMode) var presentationMode
    
    @State private var frase: [String] = []
    @State private var lastDetectedSign: String? = nil
    
    // Sheet final
    @State private var showFinalSheet = false
    
    // Para pausar la cámara
    @State private var shouldStop = false

    var body: some View {
        ZStack {
            // 1. Cámara, mientras shouldStop == false
            if !shouldStop {
                TraductorCameraFullView(
                    frase: $frase,
                    lastDetectedSign: $lastDetectedSign,
                    shouldStop: $shouldStop
                )
                .edgesIgnoringSafeArea(.all)
            }

            // 2. Overlay con la última seña detectada (si quieres mostrarla unos segundos)
            if let sign = lastDetectedSign {
                VStack {
                    Text(sign)
                        .font(.largeTitle)
                        .foregroundColor(.white)
                        .padding()
                }
                .padding()
                .background(Color.black.opacity(0.7))
                .cornerRadius(12)
                .rotationEffect(.degrees(90))
            }

            // 3. Botón para finalizar
            VStack {
                Spacer()
                HStack {
                    Spacer()
                    Button("Finalizar sesión de traducción") {
                        // Detenemos la sesión
                        shouldStop = true
                        // Mostramos el sheet con la frase
                        showFinalSheet = true
                    }
                    .padding()
                    .background(Color.red)
                    .foregroundColor(.white)
                    .cornerRadius(8)
                    .padding(.trailing, 20)
                    .padding(.bottom, 20)
                }
            }
        }
        // Al presentar el sheet final
        .sheet(isPresented: $showFinalSheet, onDismiss: {
            // Cuando cierra la frase final, cerramos toda la vista
            presentationMode.wrappedValue.dismiss()
        }) {
            ResumenFraseSheetView(frase: frase) {
                // Callback al cerrar
                showFinalSheet = false
            }
        }
    }
}




#Preview {
    TraductorSessionView()
}
