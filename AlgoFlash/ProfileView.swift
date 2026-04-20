import SwiftUI
import FirebaseAuth

struct ProfileView: View {
    @EnvironmentObject var authViewModel: AuthViewModel
    @EnvironmentObject var flashcardVM: FlashcardViewModel
    @StateObject private var profileVM = ProfileViewModel()
    @State private var showingLogoutConfirmation = false

    var body: some View {
        NavigationStack {
            ZStack {
                AppBackground()

                ScrollView {
                    VStack(spacing: 0) {
                        heroHeader

                        VStack(spacing: 24) {
                            statsSection
                                .offset(y: -28)
                                .padding(.bottom, -28)

                            ProfileActionsSection(viewModel: profileVM) {
                                if let uid = profileVM.appUser?.id {
                                    authViewModel.fetchCurrentUser(userId: uid)
                                }
                            }

                            AlgoButton(title: "Log Out", icon: "rectangle.portrait.and.arrow.right", style: .danger) {
                                showingLogoutConfirmation = true
                            }
                            .padding(.horizontal, 20)
                            .padding(.bottom, 24)
                        }
                    }
                }
                .ignoresSafeArea(edges: .top)

                if profileVM.isLoading {
                    ProgressView()
                        .padding(18)
                        .background(.thinMaterial)
                        .clipShape(RoundedRectangle(cornerRadius: 18, style: .continuous))
                }
            }
            .navigationTitle("Profile")
            .navigationBarTitleDisplayMode(.inline)
            .onAppear { profileVM.fetchProfile() }
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

    private var heroHeader: some View {
        ZStack(alignment: .bottom) {
            BrandGradient(colors: [Color.brandDark, Color.brand, Color.brandLight])
                .frame(height: 245)

            VStack(spacing: 10) {
                ZStack {
                    Circle()
                        .fill(Color.white.opacity(0.18))
                        .frame(width: 104, height: 104)
                    Circle()
                        .stroke(Color.white.opacity(0.72), lineWidth: 3)
                        .frame(width: 104, height: 104)
                    Text(initials)
                        .font(.system(size: 36, weight: .bold))
                        .foregroundStyle(.white)
                }

                Text(profileVM.appUser?.fullName ?? Auth.auth().currentUser?.email ?? "User")
                    .font(.title2.bold())
                    .foregroundStyle(.white)

                Text(profileVM.appUser?.email ?? Auth.auth().currentUser?.email ?? "")
                    .font(.subheadline)
                    .foregroundStyle(.white.opacity(0.75))

                Label("Student", systemImage: "graduationcap.fill")
                    .font(.caption.weight(.bold))
                    .padding(.horizontal, 12)
                    .padding(.vertical, 6)
                    .foregroundStyle(.white)
                    .background(.white.opacity(0.16))
                    .clipShape(Capsule())
            }
            .padding(.bottom, 22)
            .padding(.top, 48)
        }
    }

    private var statsSection: some View {
        HStack(spacing: 12) {
            StatCard(
                title: "Best Score",
                value: "\(profileVM.appUser?.score ?? 0)",
                icon: "star.fill",
                color: Color.warning
            )
            StatCard(
                title: "Quizzes",
                value: "\(profileVM.appUser?.quizzesTaken ?? 0)",
                icon: "checkmark.circle.fill",
                color: Color.success
            )
            StatCard(
                title: "Favourites",
                value: "\(flashcardVM.favouriteIDs.count)",
                icon: "heart.fill",
                color: Color.danger
            )
        }
        .padding(.horizontal, 20)
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

struct StatCard: View {
    let title: String
    let value: String
    let icon: String
    let color: Color

    var body: some View {
        VStack(alignment: .leading, spacing: 10) {
            Rectangle()
                .fill(color)
                .frame(height: 3)
                .clipShape(Capsule())

            Image(systemName: icon)
                .font(.title3)
                .foregroundStyle(color)

            Text(value)
                .font(.title2.bold())
                .lineLimit(1)
                .minimumScaleFactor(0.7)

            Text(title)
                .font(.caption)
                .foregroundStyle(.secondary)
                .lineLimit(2)
                .minimumScaleFactor(0.8)
        }
        .frame(maxWidth: .infinity, alignment: .leading)
        .padding(14)
        .background(Color.surface0)
        .clipShape(RoundedRectangle(cornerRadius: 16, style: .continuous))
        .shadow(color: .black.opacity(0.08), radius: 12, x: 0, y: 6)
    }
}

struct InfoRow: View {
    let label: String
    let value: String

    var body: some View {
        HStack {
            Text(label)
                .foregroundStyle(.secondary)
            Spacer()
            Text(value)
                .foregroundStyle(.primary)
                .multilineTextAlignment(.trailing)
        }
        .padding(.horizontal, 16)
        .padding(.vertical, 14)
    }
}

struct ProfileActionsSection: View {
    @ObservedObject var viewModel: ProfileViewModel
    var onProfileChanged: (() -> Void)? = nil

    @State private var fullName = ""
    @State private var email = ""

    var body: some View {
        VStack(alignment: .leading, spacing: 12) {
            SectionHeader(title: "Account Settings", subtitle: "Keep your profile details current.")
                .padding(.horizontal, 20)

            VStack(spacing: 14) {
                AlgoTextField(placeholder: "Full Name", text: $fullName, icon: "person.text.rectangle")

                AlgoButton(title: "Update Name", icon: "checkmark.circle", style: .secondary, isLoading: viewModel.isLoading) {
                    viewModel.updateName(fullName) {
                        onProfileChanged?()
                    }
                }
                .disabled(viewModel.isLoading || fullName.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty)

                Divider()

                AlgoTextField(
                    placeholder: "Email",
                    text: $email,
                    icon: "envelope",
                    keyboardType: .emailAddress
                )

                AlgoButton(title: "Update Email", icon: "envelope.badge", style: .ghost, isLoading: viewModel.isLoading) {
                    viewModel.updateEmail(email)
                }
                .disabled(viewModel.isLoading || email.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty)

                if !viewModel.errorMessage.isEmpty {
                    MessageBanner(text: viewModel.errorMessage, color: Color.danger)
                }

                if !viewModel.successMessage.isEmpty {
                    MessageBanner(text: viewModel.successMessage, color: Color.success)
                }
            }
            .padding(16)
            .background(Color.surface0)
            .clipShape(RoundedRectangle(cornerRadius: 18, style: .continuous))
            .overlay(
                RoundedRectangle(cornerRadius: 18, style: .continuous)
                    .stroke(Color.secondary.opacity(0.10), lineWidth: 1)
            )
            .shadow(color: .black.opacity(0.06), radius: 12, x: 0, y: 6)
            .padding(.horizontal, 20)
        }
        .onAppear(perform: seedFields)
        .onChange(of: viewModel.appUser?.fullName) { _ in
            seedFields()
        }
        .onChange(of: viewModel.appUser?.email) { _ in
            seedFields()
        }
    }

    private func seedFields() {
        fullName = viewModel.appUser?.fullName ?? ""
        email = viewModel.appUser?.email ?? Auth.auth().currentUser?.email ?? ""
    }
}

private struct MessageBanner: View {
    let text: String
    let color: Color

    var body: some View {
        Text(text)
            .font(.footnote)
            .foregroundStyle(color)
            .frame(maxWidth: .infinity, alignment: .leading)
            .padding(10)
            .background(color.opacity(0.10))
            .clipShape(RoundedRectangle(cornerRadius: 10, style: .continuous))
    }
}
