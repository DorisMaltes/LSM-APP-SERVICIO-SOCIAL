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
                TraductorSheetView()
            }
        }
    }
}

#Preview {
    TraductorView()
}
