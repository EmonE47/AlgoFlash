import SwiftUI
import FirebaseCore

@main
struct AlgoFlashApp: App {
    @StateObject private var authViewModel: AuthViewModel

    init() {
        if FirebaseApp.app() == nil {
            FirebaseApp.configure()
        }
        _authViewModel = StateObject(wrappedValue: AuthViewModel())
    }
    
    var body: some Scene {
        WindowGroup {
            ContentView()
                .environmentObject(authViewModel)
        }
    }
}
