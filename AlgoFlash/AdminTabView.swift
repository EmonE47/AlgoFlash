import SwiftUI

struct AdminTabView: View {
    @EnvironmentObject var authViewModel: AuthViewModel
    @State private var selectedTab = 0

    var body: some View {
        TabView(selection: $selectedTab) {
            ManageFlashcardsView()
                .tabItem {
                    Label("Manage Cards", systemImage: "rectangle.on.rectangle")
                }
                .tag(0)

            ManageQuizView()
                .tabItem {
                    Label("Manage Quiz", systemImage: "questionmark.circle")
                }
                .tag(1)

            AdminResultsView()
                .tabItem {
                    Label("Results", systemImage: "chart.bar")
                }
                .tag(2)

            AdminProfileView()
                .tabItem {
                    Label("Profile", systemImage: "person.crop.circle")
                }
                .tag(3)
        }
    }
}

#Preview {
    AdminTabView()
        .environmentObject(AuthViewModel())
}
