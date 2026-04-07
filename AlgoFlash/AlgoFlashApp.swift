//
//  AlgoFlashApp.swift
//  AlgoFlash
//
//

import SwiftUI

#if canImport(UIKit)
import UIKit
#endif
#if canImport(FirebaseCore)
import FirebaseCore
#endif

#if canImport(FirebaseCore)
final class AppDelegate: NSObject, UIApplicationDelegate {
    func application(
        _ application: UIApplication,
        didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey: Any]? = nil
    ) -> Bool {
        guard FirebaseApp.app() == nil else {
            return true
        }

        guard
            let filePath = Bundle.main.path(forResource: "GoogleService-Info", ofType: "plist"),
            let options = FirebaseOptions(contentsOfFile: filePath)
        else {
            assertionFailure("Missing GoogleService-Info.plist in the AlgoFlash target.")
            return true
        }

        FirebaseApp.configure(options: options)
        return true
    }
}
#endif

@main
struct AlgoFlashApp: App {
    #if canImport(FirebaseCore)
    @UIApplicationDelegateAdaptor(AppDelegate.self) var delegate
    #endif

    var body: some Scene {
        WindowGroup {
            ContentView()
        }
    }
}
