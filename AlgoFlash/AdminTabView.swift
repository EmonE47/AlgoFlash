import SwiftUI

struct AdminTabView: View {
    @EnvironmentObject var authViewModel: AuthViewModel
    @State private var selectedTab = 0

    var body: some View {
        TabView(selection: $selectedTab) {
            ManageFlashcardsView()
                .tabItem {
                    Label("Manage Cards", systemImage: "square.stack.3d.up.fill")
                }
                .tag(0)

            ManageQuizView()
                .tabItem {
                    Label("Manage Quiz", systemImage: "checkmark.seal.fill")
                }
                .tag(1)

            AdminResultsView()
                .tabItem {
                    Label("Results", systemImage: "chart.bar.fill")
                }
                .tag(2)

            AdminProfileView()
                .tabItem {
                    Label("Profile", systemImage: "person.crop.circle.fill")
                }
                .tag(3)
        }
        .tint(Color.warning)
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

#Preview {
    AdminTabView()
        .environmentObject(AuthViewModel())
}
