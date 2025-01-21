//
//  TraductorCameraView.swift
//  LSM-APP-SERVICIO-SOCIAL
//
//  Created by Doris Elena  on 12/01/25.
//

import SwiftUI

/// Vista que envuelve al UIViewController (AR + CoreML) para el Traductor
struct TraductorCameraView: View {
    @Binding var frase: [String]
    @Binding var lastDetectedSign: String?
    @Binding var shouldStop: Bool

        var body: some View {
            TraductorCameraRepresentable(
                frase: $frase,
                lastDetectedSign: $lastDetectedSign,
                shouldStop: $shouldStop
            )
        }
}
struct TraductorCameraRepresentable: UIViewControllerRepresentable {
    @Binding var frase: [String]
    @Binding var lastDetectedSign: String?
    @Binding var shouldStop: Bool

    func makeUIViewController(context: Context) -> TraductorARViewController {
        let vc = TraductorARViewController()
        vc.frase = $frase
        vc.lastDetectedSign = $lastDetectedSign
        vc.shouldStop = $shouldStop
        return vc
    }

    func updateUIViewController(_ uiViewController: TraductorARViewController, context: Context) {}
}


struct TraductorCameraFullView: View {
    @Binding var frase: [String]
    @Binding var lastDetectedSign: String?
    @Binding var shouldStop: Bool

    var body: some View {
        TraductorCameraRepresentable(
            frase: $frase,
            lastDetectedSign: $lastDetectedSign,
            shouldStop: $shouldStop
        )
    }
}



