//
//  RutaAprendizajeView.swift
//  LSM-APP-SERVICIO-SOCIAL
//
//  Created by Doris Elena  on 07/01/25.
//

import SwiftUI
import AVKit

//lista las lecciones disponibles
struct RutaAprendizajeView: View {
    var body: some View {
        NavigationStack {
            List (lecciones){ leccion in
                NavigationLink(leccion.nombre, destination: ListaDeCategoriasView(leccion: leccion))
            }.navigationTitle("Ruta Aprendizaje")
        }
    }
}
//lista de categorias dentro de lecciones
struct ListaDeCategoriasView: View {
    let leccion: Leccion

    var body: some View {
        List(leccion.categorias) { categoria in
            NavigationLink(categoria.nombre, destination: ListaDeVideosView(categoria: categoria))
        }
        .navigationTitle(leccion.nombre)
        
        Text("El objetivo de esta leccion es: " + leccion.objetivo)
    }
}

//lista de palabras
struct ListaDeVideosView: View {
    let categoria: Categoria

    var body: some View {
        List(categoria.videos) { video in
            NavigationLink(video.nombre, destination: ReproductorVideoView(video: video))
        }
        .navigationTitle(categoria.nombre)
    }
}




#Preview {
    RutaAprendizajeView()
}
