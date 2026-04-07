import SwiftUI

struct HomeView: View {
    @EnvironmentObject var authViewModel: AuthViewModel
    
    var body: some View {
        NavigationStack {
            VStack(spacing: 30) {
                Text("Welcome to AlgoFlash!")
                    .font(.largeTitle)
                    .bold()
                
                Text("Your flashcards and quizzes will appear here.")
                    .foregroundColor(.gray)
                
                // Placeholder buttons for future features
                Button("Start Flashcards") {
                    // Action
                }
                .buttonStyle(.borderedProminent)
                
                Button("Start Quiz") {
                    // Action
                }
                .buttonStyle(.bordered)
            }
            .navigationTitle("Home")
            .toolbar {
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button("Log Out") {
                        authViewModel.logOut()
                    }
                    .foregroundColor(.red)
                }
            }
        }
    }
}