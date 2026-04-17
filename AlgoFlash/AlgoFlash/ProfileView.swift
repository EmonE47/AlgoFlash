import SwiftUI
import FirebaseAuth

struct ProfileView: View {
    @EnvironmentObject var authViewModel: AuthViewModel
    @EnvironmentObject var flashcardVM: FlashcardViewModel
    @StateObject private var profileVM = ProfileViewModel()

    var body: some View {
        NavigationStack {
            ScrollView {
                VStack(spacing: 24) {
                    // Avatar + name
                    avatarSection

                    // Stats cards
                    statsSection

                    // Account info
                    accountSection

                    // Logout
                    Button(role: .destructive) {
                        authViewModel.logOut()
                    } label: {
                        Label("Log Out", systemImage: "rectangle.portrait.and.arrow.right")
                            .frame(maxWidth: .infinity)
                            .padding()
                            .background(Color(.systemGray6))
                            .clipShape(RoundedRectangle(cornerRadius: 12))
                    }
                    .padding(.horizontal, 20)
                    .padding(.bottom, 20)
                }
                .padding(.top, 20)
            }
            .navigationTitle("Profile")
            .onAppear { profileVM.fetchProfile() }
            .overlay {
                if profileVM.isLoading {
                    ProgressView()
                }
            }
        }
    }

    // MARK: - Sections

    private var avatarSection: some View {
        VStack(spacing: 10) {
            ZStack {
                Circle()
                    .fill(LinearGradient(colors: [.blue, .purple], startPoint: .topLeading, endPoint: .bottomTrailing))
                    .frame(width: 90, height: 90)
                Text(initials)
                    .font(.system(size: 34, weight: .bold))
                    .foregroundColor(.white)
            }

            Text(profileVM.appUser?.fullName ?? Auth.auth().currentUser?.email ?? "User")
                .font(.title2.bold())

            Text(profileVM.appUser?.email ?? Auth.auth().currentUser?.email ?? "")
                .font(.subheadline)
                .foregroundColor(.secondary)
        }
    }

    private var statsSection: some View {
        VStack(alignment: .leading, spacing: 12) {
            Text("Progress")
                .font(.headline)
                .padding(.horizontal, 20)

            HStack(spacing: 12) {
                StatCard(
                    title: "Best Score",
                    value: "\(profileVM.appUser?.score ?? 0)",
                    icon: "star.fill",
                    color: .yellow
                )
                StatCard(
                    title: "Quizzes Taken",
                    value: "\(profileVM.appUser?.quizzesTaken ?? 0)",
                    icon: "checkmark.circle.fill",
                    color: .green
                )
                StatCard(
                    title: "Favourites",
                    value: "\(flashcardVM.favouriteIDs.count)",
                    icon: "heart.fill",
                    color: .red
                )
            }
            .padding(.horizontal, 20)
        }
    }

    private var accountSection: some View {
        VStack(alignment: .leading, spacing: 0) {
            Text("Account")
                .font(.headline)
                .padding(.horizontal, 20)
                .padding(.bottom, 8)

            VStack(spacing: 0) {
                InfoRow(label: "Full Name", value: profileVM.appUser?.fullName ?? "—")
                Divider().padding(.leading, 16)
                InfoRow(label: "Email", value: profileVM.appUser?.email ?? Auth.auth().currentUser?.email ?? "—")
            }
            .background(Color(.systemBackground))
            .clipShape(RoundedRectangle(cornerRadius: 12))
            .overlay(RoundedRectangle(cornerRadius: 12).stroke(Color(.systemGray5)))
            .padding(.horizontal, 20)
        }
    }

    private var initials: String {
        let name = profileVM.appUser?.fullName ?? ""
        let parts = name.split(separator: " ")
        if parts.count >= 2 {
            return "\(parts[0].prefix(1))\(parts[1].prefix(1))".uppercased()
        } else if let first = parts.first {
            return String(first.prefix(2)).uppercased()
        }
        return "AF"
    }
}

// MARK: - Sub-views

struct StatCard: View {
    let title: String
    let value: String
    let icon: String
    let color: Color

    var body: some View {
        VStack(spacing: 8) {
            Image(systemName: icon)
                .font(.title2)
                .foregroundColor(color)
            Text(value)
                .font(.title2.bold())
            Text(title)
                .font(.caption)
                .foregroundColor(.secondary)
                .multilineTextAlignment(.center)
        }
        .frame(maxWidth: .infinity)
        .padding(.vertical, 16)
        .background(Color(.systemGray6))
        .clipShape(RoundedRectangle(cornerRadius: 12))
    }
}

struct InfoRow: View {
    let label: String
    let value: String

    var body: some View {
        HStack {
            Text(label)
                .foregroundColor(.secondary)
            Spacer()
            Text(value)
                .foregroundColor(.primary)
                .multilineTextAlignment(.trailing)
        }
        .padding(.horizontal, 16)
        .padding(.vertical, 14)
    }
}
