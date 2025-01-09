//
//  VerVideoView.swift
//  LSM-APP-SERVICIO-SOCIAL
//
//  Created by Doris Elena  on 07/01/25.
//

import SwiftUI
import FirebaseStorage
import AVKit


// este codigin nos ayuda e entender como el video puede ser fetcheado desde el bucket que creamos
struct VerVideoView: View {
    @State private var videoURL: URL?

    var body: some View {
        VStack {
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
        let storagePath = storage.reference(withPath: "Videos/Leccion1/Personas/Alguien.mp4")
        
        // Descargar la URL del archivo
        storagePath.downloadURL { url, error in
            if let error = error {
                print("Error al obtener la URL: \(error.localizedDescription)")
            } else if let url = url {
                print("URL del video: \(url)")
                DispatchQueue.main.async {
                    self.videoURL = url
                }
            }
        }
    }
}


#Preview {
    VerVideoView()
}
