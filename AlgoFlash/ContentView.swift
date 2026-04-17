import SwiftUI

struct ContentView: View {
    @EnvironmentObject var authViewModel: AuthViewModel

    var body: some View {
        Group {
            if authViewModel.userSession == nil {
                LoginView()
            } else if authViewModel.currentRole == nil {
                ProgressView()
                    .frame(maxWidth: .infinity, maxHeight: .infinity)
                    .background(Color(.systemBackground))
            } else if authViewModel.currentRole == "admin" {
                AdminTabView()
            } else {
                MainTabView()
            }
        }
    }
}
