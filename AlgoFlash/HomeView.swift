import SwiftUI

struct HomeView: View {
    @EnvironmentObject var authViewModel: AuthViewModel
    
    var body: some View {
        NavigationStack {
            ZStack {
                AppBackground()

                VStack(spacing: 22) {
                    Image(systemName: "bolt.fill")
                        .font(.system(size: 58, weight: .bold))
                        .foregroundStyle(LinearGradient(colors: [Color.brand, Color.brandLight], startPoint: .top, endPoint: .bottom))

                    Text("Welcome to AlgoFlash")
                        .font(.largeTitle.bold())

                    Text("Your flashcards and quizzes are available from the tabs.")
                        .font(.subheadline)
                        .foregroundStyle(.secondary)
                        .multilineTextAlignment(.center)
                        .padding(.horizontal, 30)
                }
                .padding(24)
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
