//
//  HomePageView.swift
//  LSM-APP-SERVICIO-SOCIAL
//
//  Created by Doris Elena  on 08/01/25.
//

import SwiftUI


struct HomePageView: View {
    var body: some View {
        TabView {
            // Home
            RutaAprendizajeView()
                .tabItem {
                    Label("Home", systemImage: "house.fill")
                }

            // Diccionario
            DiccionarioView(viewModel: DiccionarioViewModel())
                .tabItem {
                    Label("Diccionario", systemImage: "book.fill")
                }

            // Quizz
            QuizzView()
                .tabItem {
                    Label("Quizz", systemImage: "questionmark.circle.fill")
                }

            // Traductor
            TraductorView()
                .tabItem {
                    Label("Traductor", systemImage: "character.book.closed.fill")
                }
        }
    }
}


#Preview {
    HomePageView()
}
