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
            )
        ]
    ),
    
]

    
