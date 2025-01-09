//
//  ReproductorVideoView.swift
//  LSM-APP-SERVICIO-SOCIAL
//
//  Created by Doris Elena  on 07/01/25.
//

import SwiftUI

import FirebaseStorage
import AVKit

//este es como el manager para visualizar los videos, los fetchea desde el Cloud Storage de FirebaseStorage

struct ReproductorVideoView: View {
    let video: Video
    @State private var videoURL: URL?

    var body: some View {
        
        VStack {
            Text(video.nombre)
                .font(.title)
                .padding()
            
            if let videoURL = videoURL {
                VideoPlayer(player: AVPlayer(url: videoURL))
                    .frame(height: 300)
            } else {
                Text("Cargando video...")
            }

            
        }
        .onAppear {
            fetchVideoURL()
        }
    }

    func fetchVideoURL() {
        let storage = Storage.storage()
        let videoRef = storage.reference(withPath: video.ruta)

        videoRef.downloadURL { url, error in
            if let error = error {
                //no obtiene el video del Bucket
                print("Error al obtener la URL del video: \(error.localizedDescription)")
            } else if let url = url {
                DispatchQueue.main.async {
                    self.videoURL = url
                }
            }
        }
    }
}

#Preview {
    ReproductorVideoView(video: Video(id: "alguien", nombre: "Alguien", ruta: "Videos/Leccion1/Personas/Alguien.mp4"))
}
