//
//  TraductorView.swift
//  LSM-APP-SERVICIO-SOCIAL
//
//  Created by Doris Elena  on 08/01/25.
//

import SwiftUI

struct TraductorView: View {
    @State private var showTranslatorSheet = false
    
    var body: some View {
        VStack {
            Button("¡Iniciar sesión de traducción!") {
                showTranslatorSheet = true
            }
            .padding()
            .sheet(isPresented: $showTranslatorSheet) {
                // Presentamos la nueva sheet
                TraductorSheetView()
            }
        }
        .background(Color.blue)
        .foregroundColor(.white)
        .cornerRadius(8)
    }
}


#Preview {
    TraductorView()
}
