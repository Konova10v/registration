//
//  RegistrationAppApp.swift
//  RegistrationApp
//
//  Created by Кирилл Коновалов on 29.12.2022.
//

import SwiftUI

@main
struct RegistrationAppApp: App {
    @UIApplicationDelegateAdaptor(AppDelegate.self) var appDelegate
    
    var body: some Scene {
        WindowGroup {
            if UserDefaults.standard.bool(forKey: "auth") {
                ProfileView()
            } else {
                IntroView()
            }
        }
    }
}

class AppDelegate: NSObject, UIApplicationDelegate {
    func application(_ application: UIApplication, didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey: Any]?) -> Bool {
        localSaveData()
        
        return true
    }
    
    @objc private func localSaveData() {
        let defaults = UserDefaults.standard
        let auth: [String: Bool] = ["auth": false]
        let email: [String: String] = ["email": ""]
            
        defaults.register(defaults: auth)
        defaults.register(defaults: email)
    }
}
