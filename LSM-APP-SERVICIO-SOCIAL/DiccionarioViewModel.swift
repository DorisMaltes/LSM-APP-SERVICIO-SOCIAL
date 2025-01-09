//
//  DiccionarioViewModel.swift
//  LSM-APP-SERVICIO-SOCIAL
//
//  Created by Doris Elena  on 08/01/25.
//

import FirebaseStorage
import Foundation

class DiccionarioViewModel: ObservableObject {
    @Published var videos: [Video] = [] // Lista plana de videos
    @Published var searchQuery: String = "" // Consulta de búsqueda
    @Published var hasFetched: Bool = false // Controla si ya se cargaron los datos

    
    var filteredVideos: [Video] {
        if searchQuery.isEmpty {
            return videos
        } else {
            return videos.filter { $0.nombre.lowercased().contains(searchQuery.lowercased()) }
        }
    }

    func fetchLecciones() {
        DispatchQueue.main.async {
            self.videos.removeAll() // Limpia la lista de videos
        }

        let storage = Storage.storage()
        let rootRef = storage.reference(withPath: "Videos") // Carpeta raíz donde están las lecciones

        rootRef.listAll { result, error in
            if let error = error {
                print("Error al listar lecciones: \(error.localizedDescription)")
                return
            }

            guard let result = result else {
                print("Error: No se pudo obtener el resultado de listAll.")
                return
            }

            // Procesar cada lección
            for leccionRef in result.prefixes { // Subcarpetas (lecciones)
                self.fetchCategorias(for: leccionRef)
            }
        }
    }


    private func fetchCategorias(for leccionRef: StorageReference) {
        leccionRef.listAll { result, error in
            if let error = error {
                print("Error al listar categorías: \(error.localizedDescription)")
                return
            }

            guard let result = result else {
                print("Error: No se pudo obtener el resultado de listAll para categorías.")
                return
            }

            // Procesar cada categoría
            for categoriaRef in result.prefixes { // Subcarpetas (categorías)
                self.fetchVideos(for: categoriaRef)
            }
        }
    }


    private func fetchVideos(for categoriaRef: StorageReference) {
        categoriaRef.listAll { result, error in
            if let error = error {
                print("Error al listar videos: \(error.localizedDescription)")
                return
            }

            guard let result = result else {
                print("Error: No se pudo obtener el resultado de listAll para videos.")
                return
            }

            for videoRef in result.items { // Archivos (videos)
                let nombre = videoRef.name.replacingOccurrences(of: ".mp4", with: "")
                let ruta = videoRef.fullPath

                videoRef.downloadURL { url, error in
                    if let url = url {
                        DispatchQueue.main.async {
                            // Verifica si el video ya existe en la lista
                            if !self.videos.contains(where: { $0.id == videoRef.name }) {
                                let video = Video(id: videoRef.name, nombre: nombre, ruta: ruta)
                                self.videos.append(video)
                            }
                        }
                    }
                }
            }
        }
    }


}






