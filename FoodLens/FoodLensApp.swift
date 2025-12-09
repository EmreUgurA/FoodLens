//
//  FoodLensApp.swift
//  FoodLens
//
//  Created by Emre Uğur on 21.10.2025.
//

import SwiftUI
import FirebaseCore

class AppDelegate: NSObject, UIApplicationDelegate {
  func application(_ application: UIApplication,
                   didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey : Any]? = nil) -> Bool {
    FirebaseApp.configure()
    return true
  }
}

@main
struct FoodLensApp: App {
    // Firebase entegrasyonu için delegate
    @UIApplicationDelegateAdaptor(AppDelegate.self) var delegate
    
    // Tüm uygulama boyunca kullanıcının oturum durumunu takip edecek obje
    @StateObject var authViewModel = AuthViewModel()
    
    var body: some Scene {
        WindowGroup {
            ContentView()
                .environmentObject(authViewModel)
        }
    }
}
