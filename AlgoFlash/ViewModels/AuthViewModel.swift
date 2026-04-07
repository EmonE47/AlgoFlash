import Foundation
import UIKit
import FirebaseAuth

@MainActor
final class AuthViewModel: ObservableObject {
    enum Mode: String, CaseIterable, Identifiable {
        case login = "Login"
        case signUp = "Sign Up"

        var id: String { rawValue }
    }

    @Published var mode: Mode = .login
    @Published var fullName = ""
    @Published var email = ""
    @Published var password = ""
    @Published var confirmPassword = ""

    @Published var isLoading = false
    @Published var errorMessage = ""
    @Published var isAuthenticated = false
    @Published var displayName = ""
    @Published var userEmail = ""

    private let authService: AuthService

    init(authService: AuthService = .shared) {
        self.authService = authService
        refreshUserState(using: authService.currentUser())
    }

    func submit() async {
        guard !isLoading else { return }
        errorMessage = ""
        isLoading = true
        defer { isLoading = false }

        do {
            let user: User

            switch mode {
            case .login:
                user = try await authService.signIn(email: email, password: password)
            case .signUp:
                user = try await authService.signUp(
                    email: email,
                    password: password,
                    confirmPassword: confirmPassword,
                    fullName: fullName
                )
            }

            refreshUserState(using: user)
            clearFields()
        } catch {
            errorMessage = error.localizedDescription
        }
    }

    func continueWithGoogle(presentingViewController: UIViewController?) async {
        guard !isLoading else { return }
        errorMessage = ""
        isLoading = true
        defer { isLoading = false }

        do {
            let user = try await authService.signInWithGoogle(presentingViewController: presentingViewController)
            refreshUserState(using: user)
            clearFields()
        } catch {
            errorMessage = error.localizedDescription
        }
    }

    func signOut() {
        do {
            try authService.signOut()
            isAuthenticated = false
            displayName = ""
            userEmail = ""
            mode = .login
        } catch {
            errorMessage = error.localizedDescription
        }
    }

    private func refreshUserState(using user: User?) {
        isAuthenticated = user != nil
        displayName = user?.displayName ?? ""
        userEmail = user?.email ?? ""
    }

    private func clearFields() {
        password = ""
        confirmPassword = ""
    }
}
