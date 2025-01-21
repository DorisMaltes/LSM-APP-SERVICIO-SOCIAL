//
//  DatosVideos.swift
//  LSM-APP-SERVICIO-SOCIAL
//
//  Created by Doris Elena  on 07/01/25.
//

import Foundation

//cada leccion contiene entre 1 o 3 categorias son 11 categorias en total y como mas de 400+ palabras
struct Leccion: Identifiable {
    let id: String
    let nombre: String
    let objetivo: String
    let categorias: [Categoria]
}

struct Categoria: Identifiable {
    let id: String
    let nombre: String
    let videos: [Video]
}

struct Video: Identifiable {
    let id: String
    let nombre: String //palabra
    let ruta: String // esto es para la ruta en Firebase Storage :)
}


//Datos Locales, definicion de las lecciones y categorias directamente aqui en codigo (sera mucho efe)

let lecciones = [
    Leccion(
        id: "1",
        nombre: "Lección 1",
        objetivo: "Introducir el alfabeto en LSM y las señas básicas para describir personas, incluyendo pronombres y términos comunes.",
        categorias: [
            Categoria(
                id: "personas",
                nombre: "Personas",
                videos: [
                    Video(id: "alguien", nombre: "Alguien", ruta: "Videos/Leccion1/Personas/Alguien.mp4"),
                    Video(id: "Algunos", nombre: "Algunos", ruta: "Videos/Leccion1/Personas/Algunos.mp4"),
                    Video(id: "Amante", nombre: "Amante", ruta: "Videos/Leccion1/Personas/Amante.mp4"),
                    Video(id: "Amiga",nombre: "Amiga", ruta: "Videos/Leccion1/Personas/Amiga.mp4"),
                    Video(id: "Amigo",nombre: "Amigo", ruta: "Videos/Leccion1/Personas/Amigo.mp4"),
                    Video(id: "Amistad", nombre: "Amistad", ruta: "Videos/Leccion1/Personas/Amistad.mp4"),
                    Video(id: "Apellido",nombre: "Apellido",ruta: "Videos/Leccion1/Personas/Apellido.mp4"),
                    Video(id: "El", nombre: "El", ruta: "Videos/Leccion1/Personas/El.mp4"),
                    Video(id: "Ellos",nombre: "Ellos",ruta: "Videos/Leccion1/Personas/Ellos.mp4"),
                    Video( id: "Esposo_Casado",nombre: "Esposo_Casado",ruta: "Videos/Leccion1/Personas/Esposo_Casado.mp4"),
                    Video( id: "Gente", nombre: "Gente", ruta: "Videos/Leccion1/Personas/Gente.mp4")
                ]
            ),
            Categoria(
                id:"alfabeto",
                nombre: "Alfabeto",
                videos: [
                    Video(id: "a", nombre: "A", ruta: "Videos/Leccion1/Alfabeto/A.mp4"),
                    Video(id: "B", nombre: "B", ruta: "Videos/Leccion1/Alfabeto/B.mp4"),
                    Video(id: "C", nombre: "C", ruta: "Videos/Leccion1/Alfabeto/C.mp4"),
                    Video(id: "D", nombre: "D", ruta: "Videos/Leccion1/Alfabeto/D.mp4"),
                    Video(id: "E", nombre: "E", ruta: "Videos/Leccion1/Alfabeto/E.mp4"),
                    Video(id: "F", nombre: "F", ruta: "Videos/Leccion1/Alfabeto/F.mp4"),
                    Video(id: "G", nombre: "G", ruta: "Videos/Leccion1/Alfabeto/G.mp4"),
                    Video(id: "H", nombre: "H", ruta: "Videos/Leccion1/Alfabeto/H.mp4"),
                    Video(id: "I", nombre: "I", ruta: "Videos/Leccion1/Alfabeto/I.mp4"),
                    Video(id: "j", nombre: "J", ruta: "Videos/Leccion1/Alfabeto/J.mp4"),
                    Video(id: "k", nombre: "K", ruta: "Videos/Leccion1/Alfabeto/K.mp4"),
                    Video(id: "L", nombre: "L", ruta: "Videos/Leccion1/Alfabeto/L.mp4"),
                    Video(id: "LL", nombre: "LL", ruta: "Videos/Leccion1/Alfabeto/LL.mp4"),
                    Video(id: "M", nombre: "M", ruta: "Videos/Leccion1/Alfabeto/M.mp4"),
                    Video(id: "N", nombre: "N", ruta: "Videos/Leccion1/Alfabeto/N.mp4"),
                    Video(id: "O", nombre: "O", ruta: "Videos/Leccion1/Alfabeto/O.mp4"),
                    Video(id: "P", nombre: "P", ruta: "Videos/Leccion1/Alfabeto/P.mp4"),
                    Video(id: "Q", nombre: "Q", ruta: "Videos/Leccion1/Alfabeto/Q.mp4"),
                    Video(id: "R", nombre: "R", ruta: "Videos/Leccion1/Alfabeto/R.mp4"),
                    Video(id: "S", nombre: "S", ruta: "Videos/Leccion1/Alfabeto/S.mp4"),
                    Video(id: "T", nombre: "T", ruta: "Videos/Leccion1/Alfabeto/T.mp4"),
                    Video(id: "U", nombre: "U", ruta: "Videos/Leccion1/Alfabeto/U.mp4"),
                    Video(id: "V", nombre: "V", ruta: "Videos/Leccion1/Alfabeto/V.mp4"),
                    Video(id: "W", nombre: "W", ruta: "Videos/Leccion1/Alfabeto/W.mp4"),
                    Video(id: "X", nombre: "X", ruta: "Videos/Leccion1/Alfabeto/X.mp4"),
                    Video(id: "Y", nombre: "Y", ruta: "Videos/Leccion1/Alfabeto/Y.mp4"),
                    Video(id: "Z", nombre: "Z", ruta: "Videos/Leccion1/Alfabeto/Z.mp4")
                ]
            )
        ]
    ),
    
]

    
