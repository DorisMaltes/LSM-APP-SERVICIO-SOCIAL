//
//  LSM_APP_SERVICIO_SOCIALApp.swift
//  LSM-APP-SERVICIO-SOCIAL
//
//  Created by Doris Elena  on 07/01/25.
//

import SwiftUI
import FirebaseCore
import FirebaseStorage
import FirebaseAuth

class AppDelegate: NSObject, UIApplicationDelegate {
    func application(_ application: UIApplication,
                     didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey: Any]?) -> Bool {
        // configuracion inicial de Firebase, se tuvo que crear un App Delegate porque asi funciona Firebase xd
        FirebaseApp.configure()
        return true
    }
}

@main
struct LSM_APP_SERVICIO_SOCIALApp: App {
    // Register app delegate for Firebase setup
    @UIApplicationDelegateAdaptor(AppDelegate.self) var delegate
    
    var body: some Scene {
        WindowGroup {
            NavigationView {
                DiccionarioView(viewModel:   DiccionarioViewModel())
            }
        }
    }
}
