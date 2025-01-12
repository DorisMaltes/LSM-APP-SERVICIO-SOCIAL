//
//  QuizCameraView.swift
//  LSM-APP-SERVICIO-SOCIAL
//
//  Created by Doris Elena  on 12/01/25.
//
import Foundation
import SwiftUI

struct QuizCameraView: View {
    let palabraEsperada: String
    
    // Notificar cada vez que haya una detección
    let onDetect: (String, Double, Bool) -> Void
    
    var body: some View {
        ZStack {
            QuizCameraRepresentable(palabraEsperada: palabraEsperada, onDetect: onDetect)
        }
    }
}

struct QuizCameraRepresentable: UIViewControllerRepresentable {
    let palabraEsperada: String
    let onDetect: (String, Double, Bool) -> Void
    
    func makeUIViewController(context: Context) -> QuizARViewController {
        let vc = QuizARViewController()
        vc.palabraEsperada = palabraEsperada
        vc.onSignDetected = onDetect
        return vc
    }
    
    func updateUIViewController(_ uiViewController: QuizARViewController, context: Context) {}
}

