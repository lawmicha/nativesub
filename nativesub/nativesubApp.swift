//
//  nativesubApp.swift
//  nativesub
//
//  Created by Law, Michael on 9/28/20.
//

import SwiftUI
import Amplify
import AmplifyPlugins
@main
struct nativesubApp: App {
    var body: some Scene {
        WindowGroup {
            ContentView()
        }
    }

    public init() {
        do {
            try Amplify.add(plugin: AWSAPIPlugin(modelRegistration: AmplifyModels()))
            try Amplify.configure()
            print("Amplify configured with API plugin")
        } catch {
            print("Failed to initialize Amplify with \(error)")
        }
    }
}
