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
                    avatarSection
                    statsSection
                    accountSection
                    ProfileActionsSection(viewModel: profileVM) {
                        if let uid = profileVM.appUser?.id {
                            authViewModel.fetchCurrentUser(userId: uid)
                        }
                    }

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
                InfoRow(label: "Full Name", value: profileVM.appUser?.fullName ?? "-")
                Divider().padding(.leading, 16)
                InfoRow(label: "Email", value: profileVM.appUser?.email ?? Auth.auth().currentUser?.email ?? "-")
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

struct ProfileActionsSection: View {
    @ObservedObject var viewModel: ProfileViewModel
    var onProfileChanged: (() -> Void)? = nil

    @State private var fullName = ""
    @State private var email = ""

    var body: some View {
        VStack(alignment: .leading, spacing: 12) {
            Text("Manage Account")
                .font(.headline)
                .padding(.horizontal, 20)

            VStack(spacing: 14) {
                TextField("Full Name", text: $fullName)
                    .textInputAutocapitalization(.words)
                    .padding()
                    .background(Color(.systemGray6))
                    .clipShape(RoundedRectangle(cornerRadius: 10))

                Button {
                    viewModel.updateName(fullName) {
                        onProfileChanged?()
                    }
                } label: {
                    Label("Update Name", systemImage: "person.text.rectangle")
                        .frame(maxWidth: .infinity)
                }
                .buttonStyle(.borderedProminent)
                .disabled(viewModel.isLoading || fullName.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty)

                Divider()

                TextField("Email", text: $email)
                    .textInputAutocapitalization(.never)
                    .keyboardType(.emailAddress)
                    .autocorrectionDisabled()
                    .padding()
                    .background(Color(.systemGray6))
                    .clipShape(RoundedRectangle(cornerRadius: 10))

                Button {
                    viewModel.requestEmailUpdate(email)
                } label: {
                    Label("Update Email", systemImage: "envelope")
                        .frame(maxWidth: .infinity)
                }
                .buttonStyle(.bordered)
                .disabled(viewModel.isLoading || email.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty)

                Text("Email changes require verification. Check the new address inbox after tapping Update Email.")
                    .font(.caption)
                    .foregroundColor(.secondary)

                Divider()

                Button {
                    viewModel.sendPasswordReset()
                } label: {
                    Label("Send Password Reset Email", systemImage: "key")
                        .frame(maxWidth: .infinity)
                }
                .buttonStyle(.bordered)
                .disabled(viewModel.isLoading)

                if !viewModel.errorMessage.isEmpty {
                    Text(viewModel.errorMessage)
                        .font(.footnote)
                        .foregroundColor(.red)
                        .frame(maxWidth: .infinity, alignment: .leading)
                }

                if !viewModel.successMessage.isEmpty {
                    Text(viewModel.successMessage)
                        .font(.footnote)
                        .foregroundColor(.green)
                        .frame(maxWidth: .infinity, alignment: .leading)
                }
            }
            .padding(16)
            .background(Color(.systemBackground))
            .clipShape(RoundedRectangle(cornerRadius: 12))
            .overlay(RoundedRectangle(cornerRadius: 12).stroke(Color(.systemGray5)))
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
