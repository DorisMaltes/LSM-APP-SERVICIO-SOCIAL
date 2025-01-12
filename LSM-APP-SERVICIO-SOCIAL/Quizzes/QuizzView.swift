//
//  QuizView.swift
//  LSM-APP-SERVICIO-SOCIAL
//
//  Created by Doris Elena  on 08/01/25.
//

import SwiftUI

struct QuizzView: View {
    var body: some View {
        NavigationStack {
            List(lecciones) { leccion in
                NavigationLink(leccion.nombre, destination: ListaDeCategoriasQuizView(leccion: leccion))
            }
            .navigationTitle("Quizzes")
        }
    }
}


#Preview {
    QuizzView()
}
