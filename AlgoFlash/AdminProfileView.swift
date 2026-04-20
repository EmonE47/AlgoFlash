import SwiftUI

struct AdminProfileView: View {
    @EnvironmentObject var authViewModel: AuthViewModel
    @StateObject private var profileVM = ProfileViewModel()
    @State private var showingLogoutConfirmation = false

    var body: some View {
        NavigationStack {
            ZStack {
                AppBackground()

                ScrollView {
                    VStack(spacing: 24) {
                        if let user = profileVM.appUser ?? authViewModel.appUser {
                            adminHero(user: user)
                        }

                        ProfileActionsSection(viewModel: profileVM) {
                            if let uid = profileVM.appUser?.id ?? authViewModel.appUser?.id {
                                authViewModel.fetchCurrentUser(userId: uid)
                            }
                        }

                        AlgoButton(title: "Log Out", icon: "arrow.left.circle.fill", style: .danger) {
                            showingLogoutConfirmation = true
                        }
                        .padding(.horizontal, 20)
                        .padding(.bottom, 20)
                    }
                    .padding(.vertical, 16)
                }

                if profileVM.isLoading {
                    ProgressView()
                        .padding(18)
                        .background(.thinMaterial)
                        .clipShape(RoundedRectangle(cornerRadius: 18, style: .continuous))
                }
            }
            .navigationTitle("Admin Profile")
            .navigationBarTitleDisplayMode(.inline)
            .onAppear {
                profileVM.fetchProfile()
            }
        }
        .confirmationDialog(
            "Log Out",
            isPresented: $showingLogoutConfirmation,
            actions: {
                Button("Log Out", role: .destructive) {
                    authViewModel.logOut()
                }
                Button("Cancel", role: .cancel) { }
            },
            message: {
                Text("Are you sure you want to log out?")
            }
        )
    }

    private func adminHero(user: AppUser) -> some View {
        VStack(spacing: 14) {
            ZStack {
                Circle()
                    .fill(LinearGradient(colors: [Color.warning, Color.danger.opacity(0.78)], startPoint: .topLeading, endPoint: .bottomTrailing))
                    .frame(width: 96, height: 96)
                Image(systemName: "star.fill")
                    .font(.system(size: 38, weight: .bold))
                    .foregroundStyle(.white)
            }

            VStack(spacing: 6) {
                Text(user.fullName)
                    .font(.title2.bold())
                Text(user.email)
                    .font(.subheadline)
                    .foregroundStyle(.secondary)

                Label("Admin", systemImage: "star.fill")
                    .font(.caption.weight(.bold))
                    .foregroundStyle(Color.warning)
                    .padding(.horizontal, 12)
                    .padding(.vertical, 6)
                    .background(Color.warning.opacity(0.12))
                    .clipShape(Capsule())
            }
        }
        .frame(maxWidth: .infinity)
        .padding(24)
        .background(Color.surface0)
        .clipShape(RoundedRectangle(cornerRadius: 24, style: .continuous))
        .shadow(color: Color.warning.opacity(0.16), radius: 20, x: 0, y: 10)
        .padding(.horizontal, 20)
    }
}

#Preview {
    AdminProfileView()
        .environmentObject(AuthViewModel())
}
