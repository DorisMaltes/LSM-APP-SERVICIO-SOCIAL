//
//  HomePageView.swift
//  LSM-APP-SERVICIO-SOCIAL


import SwiftUI


struct HomePageView: View {
    var body: some View {
        TabView {
            // boton de home
            RutaAprendizajeView()
                .tabItem {
                    Label("Home", systemImage: "house.fill")
                }

            // diccionario
            DiccionarioView(viewModel: DiccionarioViewModel())
                .tabItem {
                    Label("Diccionario", systemImage: "book.fill")
                }

            // quizz
            QuizzView()
                .tabItem {
                    Label("Quizz", systemImage: "questionmark.circle.fill")
                }

            // traductor
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
