import SwiftUI

struct AdminProfileView: View {
    @EnvironmentObject var authViewModel: AuthViewModel
    @State private var showingLogoutConfirmation = false

    var body: some View {
        NavigationStack {
            VStack(spacing: 24) {
                // Admin Info Card
                if let user = authViewModel.appUser {
                    VStack(spacing: 16) {
                        Image(systemName: "person.crop.circle.fill")
                            .font(.system(size: 60))
                            .foregroundColor(.blue)

                        VStack(spacing: 8) {
                            Text(user.fullName)
                                .font(.headline)
                            Text(user.email)
                                .font(.subheadline)
                                .foregroundColor(.gray)
                            
                            HStack {
                                Label("Admin", systemImage: "star.fill")
                                    .font(.caption)
                                    .foregroundColor(.orange)
                                    .padding(.horizontal, 12)
                                    .padding(.vertical, 6)
                                    .background(Color.orange.opacity(0.1))
                                    .cornerRadius(8)
                            }
                        }
                    }
                    .frame(maxWidth: .infinity)
                    .padding(24)
                    .background(Color(.systemGray6))
                    .cornerRadius(12)
                }

                Spacer()

                // Logout Button
                Button(action: { showingLogoutConfirmation = true }) {
                    HStack {
                        Image(systemName: "arrow.left.circle.fill")
                        Text("Log Out")
                    }
                    .frame(maxWidth: .infinity)
                    .padding(12)
                    .background(Color.red.opacity(0.1))
                    .foregroundColor(.red)
                    .cornerRadius(8)
                }

                Spacer()
            }
            .padding(16)
            .navigationTitle("Admin Profile")
            .navigationBarTitleDisplayMode(.inline)
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
}

#Preview {
    AdminProfileView()
        .environmentObject(AuthViewModel())
}
