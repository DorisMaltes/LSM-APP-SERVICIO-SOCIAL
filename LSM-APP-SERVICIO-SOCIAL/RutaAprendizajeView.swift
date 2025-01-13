//
//  RutaAprendizajeView.swift
//  LSM-APP-SERVICIO-SOCIAL
//
//  Created by Doris Elena  on 07/01/25.
//

import SwiftUI
import AVKit
import FirebaseStorage

//lista las lecciones disponibles
struct RutaAprendizajeView: View {
    var body: some View {
        NavigationStack {
            List (lecciones){ leccion in
                NavigationLink(leccion.nombre, destination: ListaDeCategoriasView(leccion: leccion))
            }.navigationTitle("Ruta Aprendizaje prueba")
        }
    }
}

//lista de categorias dentro de lecciones
struct ListaDeCategoriasView: View {
    let leccion: Leccion

    var body: some View {
        VStack {
            Text("El objetivo de esta lección es: " + leccion.objetivo)
                .multilineTextAlignment(.center)
                .padding()

            Text("Temas de la " + leccion.nombre)
                .padding(.top)
                .font(.headline)

            List(leccion.categorias) { categoria in
                VStack(alignment: .leading) {
                    NavigationLink(destination: ListaDeVideosView(categoria: categoria)) {
                        Text(categoria.nombre)
                    }
                    Button(action: {
                        // Navega a la vista de aprendizaje
                    }) {
                        Text("¡Aprende sobre \(categoria.nombre)!")
                            .font(.subheadline)
                            .foregroundColor(.blue)
                    }
                }
            }
        }
        .navigationTitle(leccion.nombre)
    }
}

struct AprenderCategoriaView: View {
    let categoria: Categoria
    @State private var currentIndex = 0
    @State private var videoURL: URL?
    
    @State private var showSheet: Bool = false

    var body: some View {
        VStack {
            if currentIndex < categoria.videos.count {
                let video = categoria.videos[currentIndex]

                // Cargar el video dinámicamente
                if let videoURL = videoURL {
                    VideoPlayer(player: AVPlayer(url: videoURL))
                        .frame(height: 300)
                        .cornerRadius(10)
                        .padding()
                } else {
                    Text("Cargando video...")
                        .padding()
                }

                // Nombre de la palabra actual
                Text(video.nombre)
                    .font(.title)
                    .padding(.bottom)

                // Botones de navegación
                HStack {
                    Button(action: {
                        if currentIndex > 0 {
                            currentIndex -= 1
                            loadVideo(for: categoria.videos[currentIndex])
                        }
                    }) {
                        Text("Anterior")
                            .frame(maxWidth: .infinity)
                            .padding()
                            .background(currentIndex > 0 ? Color.blue : Color.gray)
                            .foregroundColor(.white)
                            .cornerRadius(8)
                    }
                    .disabled(currentIndex == 0)

                    Button(action: {
                                           showSheet = true
                                       }) {
                                           Text("Prueba en vivo")
                                               .frame(maxWidth: .infinity)
                                               .padding()
                                               .background(Color.green)
                                               .foregroundColor(.white)
                                               .cornerRadius(8)
                                       }
                                       .sheet(isPresented: $showSheet) {
                                           // Pasamos video.nombre a la sheet
                                           PruebaEnVivoSheetView(videoName: video.nombre)
                                       }

                    Button(action: {
                        if currentIndex < categoria.videos.count - 1 {
                            currentIndex += 1
                            loadVideo(for: categoria.videos[currentIndex])
                        } else {
                            currentIndex += 1
                        }
                    }) {
                        Text("Siguiente")
                            .frame(maxWidth: .infinity)
                            .padding()
                            .background(currentIndex < categoria.videos.count ? Color.blue : Color.gray)
                            .foregroundColor(.white)
                            .cornerRadius(8)
                    }
                    .disabled(currentIndex >= categoria.videos.count)
                }
                .padding()
            } else {
                // Mensaje al finalizar la categoría
                VStack {
                    Text("¡Felicidades!")
                        .font(.largeTitle)
                        .padding()

                    Text("Has completado esta categoría.")
                        .font(.title2)
                        .padding()

                    
                }
            }
        }
        .padding()
        .navigationTitle("Aprende: \(categoria.nombre)")
        .onAppear {
            loadVideo(for: categoria.videos[currentIndex])
        }
    }

    private func loadVideo(for video: Video) {
        let storage = Storage.storage()
        let videoRef = storage.reference(withPath: video.ruta)

        videoRef.downloadURL { url, error in
            if let error = error {
                print("Error al cargar el video: \(error.localizedDescription)")
            } else if let url = url {
                DispatchQueue.main.async {
                    self.videoURL = url
                }
            }
        }
    }
}




//lista de palabras
struct ListaDeVideosView: View {
    let categoria: Categoria

    var body: some View {
        VStack {
            Button(action: {}) {
                NavigationLink(destination: AprenderCategoriaView(categoria: categoria)) {
                    Text("¡Aprende sobre \(categoria.nombre)!")
                        .font(.headline)
                        .padding()
                        .background(Color.blue)
                        .foregroundColor(.white)
                        .cornerRadius(8)
                }
            }
            .padding()

            List(categoria.videos) { video in
                NavigationLink(video.nombre, destination: ReproductorVideoView(video: video))
            }
        }
        .navigationTitle(categoria.nombre)
    }
}


struct PruebaEnVivoView: View {
    var body: some View {
        VStack {
            Text("Aquí irá la prueba en vivo")
                .font(.largeTitle)
                .multilineTextAlignment(.center)
                .padding()

            Text("Esta funcionalidad estará disponible próximamente.")
                .font(.headline)
                .multilineTextAlignment(.center)
                .padding()
        }
        .navigationTitle("Prueba en Vivo")
    }
}



#Preview {
    RutaAprendizajeView()
}
