import SwiftUI

struct MainTabView: View {
    @EnvironmentObject var authViewModel: AuthViewModel
    @StateObject private var flashcardVM = FlashcardViewModel()

    var body: some View {
        TabView {
            FlashcardsView()
                .environmentObject(flashcardVM)
                .tabItem {
                    Label("Flashcards", systemImage: "rectangle.stack.fill")
                }

            FavouritesView()
                .environmentObject(flashcardVM)
                .tabItem {
                    Label("Favourites", systemImage: "heart.fill")
                }

            QuizView()
                .tabItem {
                    Label("Quiz", systemImage: "questionmark.circle.fill")
                }

            ProfileView()
                .environmentObject(flashcardVM)
                .tabItem {
                    Label("Profile", systemImage: "person.fill")
                }
        }
        .tint(.blue)
    }
}
