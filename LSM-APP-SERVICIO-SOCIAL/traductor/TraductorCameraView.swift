//
//  TraductorCameraView.swift
//  LSM-APP-SERVICIO-SOCIAL
//
//  Created by Doris Elena  on 12/01/25.
//

import SwiftUI

/// Vista que envuelve al UIViewController (AR + CoreML) para el Traductor
struct TraductorCameraView: View {
    @Binding var candidatos: [String]
    
    var body: some View {
        ZStack {
            TraductorCameraRepresentable(candidatos: $candidatos)
        }
    }
}

struct TraductorCameraRepresentable: UIViewControllerRepresentable {
    @Binding var candidatos: [String]
    
    func makeUIViewController(context: Context) -> TraductorARViewController {
        let vc = TraductorARViewController()
        vc.candidatos = $candidatos // inyectamos el binding
        return vc
    }
    
    func updateUIViewController(_ uiViewController: TraductorARViewController, context: Context) {}
}


#Preview {
    TraductorCameraView(candidatos: .constant([]))
}
