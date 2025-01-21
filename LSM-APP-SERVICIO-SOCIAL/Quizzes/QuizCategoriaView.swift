//
//  QuizCategoriaView.swift
//  LSM-APP-SERVICIO-SOCIAL
//
//  Created by Doris Elena  on 12/01/25.
//

import SwiftUI

struct QuizCategoriaView: View {
    let categoria: Categoria
    
    @State private var currentIndex = 0
    @State private var results: [(pregunta: String, respuesta: String, confidence: Double, esCorrecto: Bool)] = []
    @State private var showQuizSheet = false

    var body: some View {
        VStack {
            // 1. Si aún quedan preguntas
            if currentIndex < categoria.videos.count {
                let video = categoria.videos[currentIndex]

                Text("Pregunta \(currentIndex + 1) de \(categoria.videos.count)")
                    .font(.headline)
                    .padding()

                Text("Haz la seña de:")
                    .font(.title3)

                Text(video.nombre)
                    .font(.largeTitle)
                    .fontWeight(.bold)
                    .padding(.bottom, 20)

                HStack(spacing: 20) {
                    // BOTÓN RESPONDER (ABRE LA SHEET)
                    Button("Responder") {
                        showQuizSheet = true
                    }
                    .padding()
                    .background(Color.blue)
                    .foregroundColor(.white)
                    .cornerRadius(8)
                    .sheet(isPresented: $showQuizSheet) {
                        QuizPreguntaSheetView(
                            palabraEsperada: video.nombre,
                            categoryName: categoria.nombre
                        ) { (señaDetectada, confidence, esCorrecto) in
                            results.append((
                                pregunta: video.nombre,
                                respuesta: señaDetectada,
                                confidence: confidence,
                                esCorrecto: esCorrecto
                            ))
                            currentIndex += 1
                        }
                    }

                    // BOTÓN SALTAR
                    Button("Saltar") {
                        // Marcamos esta pregunta como “Sin Respuesta” o “SALTADA”
                        results.append((
                            pregunta: video.nombre,
                            respuesta: "SALTADA",
                            confidence: 0.0,
                            esCorrecto: false
                        ))
                        // Avanzamos a la siguiente
                        currentIndex += 1
                    }
                    .padding()
                    .background(Color.gray)
                    .foregroundColor(.white)
                    .cornerRadius(8)
                }
            }
            // 2. Cuando no hay más preguntas
            else {
                Text("¡Has terminado el quiz de \(categoria.nombre)!")
                    .font(.title)
                    .padding()

                List(results.indices, id: \.self) { i in
                    let r = results[i]
                    VStack(alignment: .leading, spacing: 4) {
                        Text("Pregunta: \(r.pregunta)")
                            .font(.headline)

                        let confStr = String(format: "%.2f", r.confidence * 100)
                        Text("Tu respuesta: \(r.respuesta) (\(confStr)%)")

                        if r.esCorrecto {
                            Text("¡Correcto! ✅")
                                .foregroundColor(.green)
                        } else {
                            Text("Incorrecto/Saltado ❌")
                                .foregroundColor(.red)
                        }
                    }
                }
            }
        }
        .padding()
        .navigationTitle("Quiz: \(categoria.nombre)")
    }
}



struct QuizCategoriaView_Previews: PreviewProvider {
    static var previews: some View {
        QuizCategoriaView(
            categoria: lecciones[0].categorias[0]  // Ejemplo
        )
    }
}

