import SwiftUI

struct SignupView: View {
    @EnvironmentObject var viewModel: AuthViewModel
    @Environment(\.dismiss) var dismiss

    @State private var fullName = ""
    @State private var email = ""
    @State private var password = ""
    @State private var selectedRole: UserRole = .user

    var body: some View {
        VStack(spacing: 20) {
            Text("Create Account")
                .font(.largeTitle)
                .bold()
                .padding(.bottom, 12)

            VStack(spacing: 15) {
                TextField("Full Name", text: $fullName)
                    .padding()
                    .background(Color(.systemGray6))
                    .cornerRadius(10)

                TextField("Email", text: $email)
                    .autocapitalization(.none)
                    .keyboardType(.emailAddress)
                    .padding()
                    .background(Color(.systemGray6))
                    .cornerRadius(10)

                SecureField("Password", text: $password)
                    .padding()
                    .background(Color(.systemGray6))
                    .cornerRadius(10)
            }
            .padding(.horizontal)

            VStack(alignment: .leading, spacing: 10) {
                Text("Account Role")
                    .font(.headline)

                Picker("Account Role", selection: $selectedRole) {
                    Text("User").tag(UserRole.user)
                    Text("Admin").tag(UserRole.admin)
                }
                .pickerStyle(.segmented)

                Text(selectedRole == .admin
                    ? "Admin accounts can manage flashcards and quiz questions."
                    : "User accounts can study flashcards, save favourites, and take quizzes.")
                    .font(.footnote)
                    .foregroundColor(.secondary)
            }
            .padding(.horizontal)

            if !viewModel.errorMessage.isEmpty {
                Text(viewModel.errorMessage)
                    .foregroundColor(.red)
                    .font(.footnote)
                    .multilineTextAlignment(.center)
                    .padding(.horizontal)
            }

            Button {
                viewModel.register(
                    email: email.trimmingCharacters(in: .whitespacesAndNewlines),
                    password: password,
                    fullName: fullName.trimmingCharacters(in: .whitespacesAndNewlines),
                    role: selectedRole
                )
            } label: {
                if viewModel.isLoading {
                    ProgressView()
                        .progressViewStyle(CircularProgressViewStyle(tint: .white))
                } else {
                    Text(selectedRole == .admin ? "Create Admin Account" : "Create User Account")
                }
            }
            .frame(maxWidth: .infinity)
            .padding()
            .background(Color.blue)
            .foregroundColor(.white)
            .cornerRadius(10)
            .padding(.horizontal)
            .disabled(viewModel.isLoading || fullName.isEmpty || email.isEmpty || password.isEmpty)

            Spacer()

            Button {
                dismiss()
            } label: {
                HStack {
                    Text("Already have an account?")
                        .foregroundColor(.gray)
                    Text("Log In")
                        .bold()
                        .foregroundColor(.blue)
                }
            }
        }
        .padding(.top, 50)
    }
}
