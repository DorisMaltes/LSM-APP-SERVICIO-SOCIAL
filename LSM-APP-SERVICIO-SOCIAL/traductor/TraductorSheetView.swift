import SwiftUI

struct TraductorSheetView: View {
    @State private var frase: [String] = []
    @State private var candidatos: [String] = []

    @Environment(\.presentationMode) var presentationMode

    var body: some View {
        VStack(spacing: 16) {
            
            // Frase arriba
            Text(frase.joined(separator: " "))
                .font(.title2)
                .multilineTextAlignment(.center)
                .padding()
                .frame(maxWidth: .infinity)
                .background(Color.gray.opacity(0.2))
                .cornerRadius(8)
                .padding(.horizontal)
            
            // Cámara con aspectRatio para evitar recortes
            TraductorCameraView(candidatos: $candidatos)
                .aspectRatio(3/4, contentMode: .fit) // o 9/16, etc.
                .background(Color.black)             // para ver las barras
                .cornerRadius(12)
                .padding(.horizontal)
            
            // Sección de candidatos
            if !candidatos.isEmpty {
                VStack(spacing: 8) {
                    Text("¿Quieres decir?:")
                        .font(.headline)
                    
                    ScrollView(.horizontal, showsIndicators: false) {
                        HStack {
                            ForEach(candidatos, id: \.self) { candidato in
                                Button(candidato) {
                                    frase.append(candidato)
                                    candidatos.removeAll()
                                }
                                .padding(.horizontal, 10)
                                .padding(.vertical, 5)
                                .background(Color.blue)
                                .foregroundColor(.white)
                                .cornerRadius(8)
                            }
                        }
                        .padding(.horizontal)
                    }
                }
                .padding(.vertical, 8)
                .background(Color.gray.opacity(0.1))
                .cornerRadius(8)
                .padding(.horizontal)
            }
            
            // Botón para finalizar
            Button("Finalizar sesión de traducción") {
                presentationMode.wrappedValue.dismiss()
            }
            .padding()
            .background(Color.red)
            .foregroundColor(.white)
            .cornerRadius(8)
        }
        .padding(.top)
    }
}


struct TraductorSheetView_Previews: PreviewProvider {
    static var previews: some View {
        TraductorSheetView()
    }
}

