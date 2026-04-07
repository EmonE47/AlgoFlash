import SwiftUI

private enum AuthMode: String, CaseIterable, Identifiable {
    case login = "Login"
    case signUp = "Sign Up"

    var id: String { rawValue }
}

struct AuthFlowView: View {
    @State private var mode: AuthMode = .login
    @State private var fullName = ""
    @State private var email = ""
    @State private var password = ""
    @State private var confirmPassword = ""
    @State private var rememberMe = true
    @State private var statusMessage = ""

    var body: some View {
        ZStack {
            Color(.systemGroupedBackground)
                .ignoresSafeArea()

            ScrollView(showsIndicators: false) {
                VStack(spacing: 24) {
                    header
                    authCard
                }
                .padding(.horizontal, 20)
                .padding(.vertical, 32)
            }
        }
    }

    private var header: some View {
        VStack(spacing: 8) {
            Text("AlgoFlash")
                .font(.largeTitle)
                .fontWeight(.semibold)
        }
    }

    private var authCard: some View {
        VStack(spacing: 16) {
            Picker("Authentication Mode", selection: $mode) {
                ForEach(AuthMode.allCases) { item in
                    Text(item.rawValue).tag(item)
                }
            }
            .pickerStyle(.segmented)

            if mode == .signUp {
                standardField(
                    title: "Full Name",
                    placeholder: "Enter your full name",
                    text: $fullName
                )
                .textInputAutocapitalization(.words)
            }

            standardField(
                title: "Email",
                placeholder: "you@example.com",
                text: $email
            )
            .keyboardType(.emailAddress)
            .textInputAutocapitalization(.never)
            .autocorrectionDisabled()

            standardSecureField(
                title: "Password",
                placeholder: mode == .login ? "Enter your password" : "Create a password",
                text: $password
            )

            if mode == .signUp {
                standardSecureField(
                    title: "Confirm Password",
                    placeholder: "Re-enter your password",
                    text: $confirmPassword
                )
            }

            if mode == .login {
                Toggle("Remember me", isOn: $rememberMe)
                    .font(.subheadline)
                    .tint(.blue)
            }

            Button(action: submit) {
                Text(mode == .login ? "Login" : "Create Account")
                    .fontWeight(.semibold)
                    .frame(maxWidth: .infinity)
                    .padding(.vertical, 12)
                    .background(Color.blue)
                    .foregroundStyle(.white)
                    .cornerRadius(10)
            }

            Button(action: googleSignInTapped) {
                Text("Continue with Google")
                    .fontWeight(.semibold)
                    .frame(maxWidth: .infinity)
                    .padding(.vertical, 12)
                    .background(Color(.systemBackground))
                    .overlay(
                        RoundedRectangle(cornerRadius: 10)
                            .stroke(Color(.separator), lineWidth: 1)
                    )
            }
            .buttonStyle(.plain)

            if !statusMessage.isEmpty {
                Text(statusMessage)
                    .font(.footnote)
                    .foregroundStyle(.secondary)
                    .frame(maxWidth: .infinity, alignment: .leading)
            }
        }
        .padding(20)
        .background(Color(.secondarySystemGroupedBackground))
        .cornerRadius(14)
        .overlay(
            RoundedRectangle(cornerRadius: 14)
                .stroke(Color(.separator), lineWidth: 1)
        )
    }

    private func submit() {
        if email.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty ||
            password.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty {
            statusMessage = "Please enter email and password."
            return
        }

        if mode == .signUp {
            if fullName.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty {
                statusMessage = "Please enter your full name."
                return
            }

            if confirmPassword != password {
                statusMessage = "Passwords do not match."
                return
            }
        }

        statusMessage = mode == .login
            ? "Login form is ready."
            : "Sign up form is ready."
    }

    private func googleSignInTapped() {
        statusMessage = "Google sign-in button tapped."
    }

    private func standardField(
        title: String,
        placeholder: String,
        text: Binding<String>
    ) -> some View {
        VStack(alignment: .leading, spacing: 6) {
            Text(title)
                .font(.footnote)
                .foregroundStyle(.secondary)

            TextField(placeholder, text: text)
                .padding(.horizontal, 12)
                .padding(.vertical, 11)
                .background(Color(.systemBackground))
                .overlay(
                    RoundedRectangle(cornerRadius: 10)
                        .stroke(Color(.separator), lineWidth: 1)
                )
        }
    }

    private func standardSecureField(
        title: String,
        placeholder: String,
        text: Binding<String>
    ) -> some View {
        VStack(alignment: .leading, spacing: 6) {
            Text(title)
                .font(.footnote)
                .foregroundStyle(.secondary)

            SecureField(placeholder, text: text)
                .padding(.horizontal, 12)
                .padding(.vertical, 11)
                .background(Color(.systemBackground))
                .overlay(
                    RoundedRectangle(cornerRadius: 10)
                        .stroke(Color(.separator), lineWidth: 1)
                )
        }
    }
}

#Preview {
    AuthFlowView()
}
