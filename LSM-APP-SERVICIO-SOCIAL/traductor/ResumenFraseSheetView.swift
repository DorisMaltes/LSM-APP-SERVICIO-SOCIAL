//
//  ResumenFraseSheetView.swift
//  LSM-APP-SERVICIO-SOCIAL
//
//  Created by Doris Elena  on 20/01/25.
//

import SwiftUI
import Foundation

struct ResumenFraseSheetView: View {
    let frase: [String]
    var onClose: () -> Void

    var body: some View {
        VStack(spacing: 20) {
            Text("Frase final: xddd")
                .font(.headline)

            Text(frase.joined(separator: " "))
                .font(.title)
                .multilineTextAlignment(.center)
                .padding()
                .background(Color.gray.opacity(0.2))
                .cornerRadius(8)

            Button("Cerrar") {
                onClose()
            }
            .padding()
            .background(Color.blue)
            .foregroundColor(.white)
            .cornerRadius(8)
        }
        .padding()
    }
}


