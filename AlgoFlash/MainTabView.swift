import SwiftUI

struct MainTabView: View {
    @EnvironmentObject var authViewModel: AuthViewModel
    @StateObject private var flashcardVM = FlashcardViewModel()
    @State private var selectedTab = 0

    var body: some View {
        TabView(selection: $selectedTab) {
            FlashcardsView()
                .environmentObject(flashcardVM)
                .tabItem {
                    Label("Flashcards", systemImage: "square.stack.3d.up.fill")
                }
                .tag(0)

            FavouritesView()
                .environmentObject(flashcardVM)
                .tabItem {
                    Label("Favourites", systemImage: "heart.fill")
                }
                .tag(1)

            QuizView()
                .tabItem {
                    Label("Quiz", systemImage: "brain.head.profile")
                }
                .tag(2)

            NewsView()
                .tabItem {
                    Label("News", systemImage: "newspaper.fill")
                }
                .tag(3)

            ProfileView()
                .environmentObject(flashcardVM)
                .tabItem {
                    Label("Profile", systemImage: "person.crop.circle.fill")
                }
                .tag(4)
        }
        .tint(Color.brand)
        .onChange(of: selectedTab) { _ in
            HapticManager.selection()
        }
        .onAppear {
            let appearance = UITabBarAppearance()
            appearance.configureWithOpaqueBackground()
            appearance.backgroundColor = UIColor.systemBackground
            appearance.shadowColor = UIColor.separator
            UITabBar.appearance().standardAppearance = appearance
            UITabBar.appearance().scrollEdgeAppearance = appearance
        }
    }
}
