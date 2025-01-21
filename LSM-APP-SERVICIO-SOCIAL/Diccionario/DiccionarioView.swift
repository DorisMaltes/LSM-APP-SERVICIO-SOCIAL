//
//  DiccionarioView.swift
//  LSM-APP-SERVICIO-SOCIAL
//
//  Created by Doris Elena  on 08/01/25.
//

import SwiftUI
import FirebaseStorage

struct DiccionarioView: View {
    @StateObject private var viewModel: DiccionarioViewModel
    
    init(viewModel: DiccionarioViewModel) {
            _viewModel = StateObject(wrappedValue: viewModel)
        }
    
    var body: some View {
        NavigationView {
            VStack {
                //este es el campo de busqueda
                TextField("Buscar palabra...", text: $viewModel.searchQuery)
                    .textFieldStyle(RoundedBorderTextFieldStyle())
                    .padding()
                
                //lista de palabras filtradas
                List(viewModel.filteredVideos){video in
                    NavigationLink(destination: ReproductorVideoView(video: video)){Text(video.nombre.capitalized)
                    }
                }
            }
            .navigationTitle("Diccionario")
            .onAppear {
                if !viewModel.hasFetched {
                    viewModel.fetchLecciones()
                    viewModel.hasFetched = true
                }
            }
        }
    }
}


//un viewModel de ejemplo para visualizar la vista correctamente
let viewModelEjemplo = DiccionarioViewModel()

#Preview{
    DiccionarioView(viewModel: viewModelEjemplo)
}
