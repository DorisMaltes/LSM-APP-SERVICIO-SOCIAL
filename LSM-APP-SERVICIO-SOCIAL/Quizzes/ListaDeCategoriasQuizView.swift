//
//  ListaDeCategoriasQuizView.swift
//  LSM-APP-SERVICIO-SOCIAL
//
//  Created by Doris Elena  on 12/01/25.
//

import SwiftUI


struct ListaDeCategoriasQuizView: View {
    let leccion: Leccion

    var body: some View {
        VStack {
            Text("Quizzes para la \(leccion.nombre)")
                .font(.headline)
                .padding()

            List(leccion.categorias) { categoria in
                NavigationLink("Quiz de \(categoria.nombre)",
                               destination: QuizCategoriaView(categoria: categoria))
            }
        }
        .navigationTitle(leccion.nombre)
    }
}


struct ListaDeCategoriasQuizView_Previews: PreviewProvider {
    static var previews: some View {
        ListaDeCategoriasQuizView(
            leccion: lecciones[0] // ejemplo
        )
    }
}

