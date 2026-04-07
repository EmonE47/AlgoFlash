import SwiftUI

struct ContentView: View {
    @StateObject private var authViewModel = AuthViewModel()

    var body: some View {
        Group {
            if authViewModel.isAuthenticated {
                HomeView(viewModel: authViewModel)
            } else {
                AuthView(viewModel: authViewModel)
            }
        }
        .animation(.easeInOut(duration: 0.2), value: authViewModel.isAuthenticated)
    }
}

#Preview {
    ContentView()
}
