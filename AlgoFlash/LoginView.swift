import SwiftUI

struct LoginView: View {
    @EnvironmentObject var viewModel: AuthViewModel
    @State private var email = ""
    @State private var password = ""

    var body: some View {
        NavigationStack {
            ZStack {
                authBackground

                ScrollView {
                    VStack(spacing: 28) {
                        Spacer(minLength: 36)

                        brandHeader

                        VStack(spacing: 16) {
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

                            if !viewModel.errorMessage.isEmpty {
                                Text(viewModel.errorMessage)
                                    .font(.footnote)
                                    .foregroundStyle(Color.danger)
                                    .multilineTextAlignment(.center)
                                    .frame(maxWidth: .infinity)
                            }

                            AlgoButton(
                                title: "Log In",
                                icon: "arrow.right.circle.fill",
                                isLoading: viewModel.isLoading
                            ) {
                                HapticManager.impact()
                                viewModel.login(email: email, password: password)
                            }
                            .disabled(viewModel.isLoading)

                            Text("Your dashboard opens automatically after sign in.")
                                .font(.caption)
                                .foregroundStyle(.secondary)
                                .multilineTextAlignment(.center)
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

                        NavigationLink {
                            SignupView()
                                .navigationBarBackButtonHidden(true)
                        } label: {
                            HStack(spacing: 4) {
                                Text("Don't have an account?")
                                    .foregroundStyle(.white.opacity(0.72))
                                Text("Sign Up")
                                    .fontWeight(.bold)
                                    .foregroundStyle(.white)
                            }
                            .font(.subheadline)
                            .padding(.vertical, 8)
                        }

                        Spacer(minLength: 24)
                    }
                    .frame(maxWidth: .infinity)
                }
            }
        }
    }

    private var brandHeader: some View {
        VStack(spacing: 14) {
            HStack(spacing: 12) {
                ZStack {
                    Capsule()
                        .fill(Color.white.opacity(0.20))
                        .frame(width: 58, height: 44)
                    Image(systemName: "bolt.fill")
                        .font(.title2.bold())
                        .foregroundStyle(.white)
                }

                Text("AlgoFlash")
                    .font(.largeTitle.bold())
                    .foregroundStyle(.white)
            }
            .padding(.horizontal, 18)
            .padding(.vertical, 12)
            .background(.white.opacity(0.12))
            .clipShape(Capsule())

            Text("Learn algorithms fast")
                .font(.headline)
                .foregroundStyle(.white.opacity(0.82))
        }
        .padding(.top, 20)
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
