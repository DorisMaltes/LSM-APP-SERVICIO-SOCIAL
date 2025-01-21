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
    let categoriaName: String
    @Binding var isCorrect: Bool
    @Binding var isIncorrect: Bool
    @Binding var detectionText: String
    
    
    var body: some View {
        ZStack {
            QuizCameraRepresentable(
                palabraEsperada: palabraEsperada,
                categoryName: categoriaName,
                isCorrect: $isCorrect,
                isIncorrect: $isIncorrect,
                detectionText: $detectionText
                )
        }
    }
}

struct QuizCameraRepresentable: UIViewControllerRepresentable {
    let palabraEsperada: String
        let categoryName: String
        @Binding var isCorrect: Bool
        @Binding var isIncorrect: Bool
        @Binding var detectionText: String

        func makeUIViewController(context: Context) -> QuizARViewController {
            let vc = QuizARViewController()
            vc.palabraEsperada = palabraEsperada
            vc.categoryName = categoryName
            vc.isCorrect = $isCorrect
            vc.isIncorrect = $isIncorrect
            vc.detectionText = $detectionText
            return vc
        }

        func updateUIViewController(_ uiViewController: QuizARViewController, context: Context) {}
}

