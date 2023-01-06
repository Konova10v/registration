//
//  RegistrationAppApp.swift
//  RegistrationApp
//
//  Created by Кирилл Коновалов on 29.12.2022.
//

import SwiftUI

class AppState: ObservableObject {
    @Published var modelID: String = UserDefaults.standard.bool(forKey: "auth") ? ScreenID.profile : ScreenID.intro
}

@main
struct RegistrationApp: App {
    @StateObject var appState = AppState()
    @UIApplicationDelegateAdaptor(AppDelegate.self) var appDelegate

    var body: some Scene {
        WindowGroup {
            ContentView()
                .environmentObject(appState)
                .onContinueUserActivity(NSUserActivityTypeBrowsingWeb, perform: handleUserActivity)
        }
    }
}

private extension RegistrationApp {
    func handleUserActivity(_ userActivity: NSUserActivity) {
        guard let url = userActivity.webpageURL,
              let components = NSURLComponents(url: url, resolvingAgainstBaseURL: true),
              let queryItems = components.queryItems
        else {
            return
        }
        
        if let modelID = queryItems.first(where: { $0.name == "id" })?.value {
            self.appState.modelID = modelID
        }
    }
}

struct ContentView: View {
   @EnvironmentObject var appState: AppState

   var body: some View {
       switch appState.modelID {
       case ScreenID.intro:
           IntroView()
       case ScreenID.profile:
           ProfileView()
       default:
           IntroView()
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
