import SwiftUI

struct SignupView: View {
    @EnvironmentObject var viewModel: AuthViewModel
    @Environment(\.dismiss) var dismiss

    @State private var fullName = ""
    @State private var email = ""
    @State private var password = ""
    @State private var selectedRole: UserRole = .user

    var body: some View {
        ZStack {
            authBackground

            ScrollView {
                VStack(spacing: 24) {
                    header

                    VStack(spacing: 16) {
                        AlgoTextField(placeholder: "Full Name", text: $fullName, icon: "person")

                        AlgoTextField(
                            placeholder: "Email",
                            text: $email,
                            icon: "envelope",
                            keyboardType: .emailAddress
                        )

                        AlgoTextField(
                            placeholder: "Password",
                            text: $password,
                            icon: "lock",
                            isSecure: true
                        )

                        roleSelector

                        if !viewModel.errorMessage.isEmpty {
                            Text(viewModel.errorMessage)
                                .font(.footnote)
                                .foregroundStyle(Color.danger)
                                .multilineTextAlignment(.center)
                                .frame(maxWidth: .infinity)
                        }

                        AlgoButton(
                            title: selectedRole == .admin ? "Create Admin Account" : "Create User Account",
                            icon: selectedRole == .admin ? "star.fill" : "person.fill",
                            isLoading: viewModel.isLoading
                        ) {
                            HapticManager.impact()
                            viewModel.register(
                                email: email.trimmingCharacters(in: .whitespacesAndNewlines),
                                password: password,
                                fullName: fullName.trimmingCharacters(in: .whitespacesAndNewlines),
                                role: selectedRole
                            )
                        }
                        .disabled(viewModel.isLoading || fullName.isEmpty || email.isEmpty || password.isEmpty)
                    }
                    .padding(20)
                    .background(.ultraThinMaterial)
                    .clipShape(RoundedRectangle(cornerRadius: 28, style: .continuous))
                    .overlay(
                        RoundedRectangle(cornerRadius: 28, style: .continuous)
                            .stroke(Color.white.opacity(0.25), lineWidth: 1)
                    )
                    .shadow(color: .black.opacity(0.18), radius: 24, x: 0, y: 14)
                    .padding(.horizontal, 20)

                    Button {
                        HapticManager.selection()
                        dismiss()
                    } label: {
                        HStack(spacing: 4) {
                            Text("Already have an account?")
                                .foregroundStyle(.white.opacity(0.72))
                            Text("Log In")
                                .fontWeight(.bold)
                                .foregroundStyle(.white)
                        }
                        .font(.subheadline)
                        .padding(.vertical, 8)
                    }

                    Spacer(minLength: 24)
                }
                .padding(.top, 42)
            }
        }
    }

    private var header: some View {
        VStack(spacing: 12) {
            HStack(spacing: 10) {
                Image(systemName: "bolt.fill")
                    .font(.title2.bold())
                    .foregroundStyle(.white)
                Text("Create Account")
                    .font(.largeTitle.bold())
                    .foregroundStyle(.white)
            }

            Text("Choose a role and start with the right workspace.")
                .font(.headline)
                .foregroundStyle(.white.opacity(0.78))
                .multilineTextAlignment(.center)
                .padding(.horizontal, 28)
        }
    }

    private var roleSelector: some View {
        VStack(alignment: .leading, spacing: 10) {
            Text("Account Role")
                .font(.headline)
                .foregroundStyle(.primary)

            HStack(spacing: 12) {
                RoleOptionCard(
                    title: "Learner",
                    subtitle: "Study and quiz",
                    icon: "person.fill",
                    isSelected: selectedRole == .user
                ) {
                    selectedRole = .user
                }

                RoleOptionCard(
                    title: "Admin",
                    subtitle: "Manage content",
                    icon: "star.fill",
                    isSelected: selectedRole == .admin
                ) {
                    selectedRole = .admin
                }
            }

            Text(selectedRole == .admin
                 ? "Admin accounts can manage flashcards and quiz questions."
                 : "User accounts can study flashcards, save favourites, and take quizzes.")
                .font(.footnote)
                .foregroundStyle(.secondary)
                .animation(Motion.easeOut, value: selectedRole)
        }
    }

    private var authBackground: some View {
        LinearGradient(
            colors: [
                Color(red: 0.06, green: 0.07, blue: 0.20),
                Color.brandDark,
                Color.brand
            ],
            startPoint: .topLeading,
            endPoint: .bottomTrailing
        )
        .ignoresSafeArea()
    }
}

private struct RoleOptionCard: View {
    let title: String
    let subtitle: String
    let icon: String
    let isSelected: Bool
    let action: () -> Void

    var body: some View {
        Button {
            HapticManager.selection()
            action()
        } label: {
            VStack(alignment: .leading, spacing: 8) {
                Image(systemName: icon)
                    .font(.title3.weight(.semibold))
                Text(title)
                    .font(.subheadline.weight(.bold))
                Text(subtitle)
                    .font(.caption)
                    .lineLimit(1)
            }
            .frame(maxWidth: .infinity, alignment: .leading)
            .padding(14)
            .foregroundStyle(isSelected ? Color.white : Color.primary)
            .background {
                if isSelected {
                    BrandGradient(colors: title == "Admin" ? [Color.warning, Color.danger.opacity(0.78)] : [Color.brand, Color.brandLight])
                } else {
                    Color.surface1
                }
            }
            .clipShape(RoundedRectangle(cornerRadius: 16, style: .continuous))
            .overlay(
                RoundedRectangle(cornerRadius: 16, style: .continuous)
                    .stroke(isSelected ? Color.white.opacity(0.28) : Color.clear, lineWidth: 1)
            )
            .shadow(color: isSelected ? Color.brand.opacity(0.18) : .clear, radius: 14, x: 0, y: 8)
        }
        .buttonStyle(ScaleButtonStyle())
    }
}
