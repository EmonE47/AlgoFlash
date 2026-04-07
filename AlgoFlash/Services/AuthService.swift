import Foundation
import UIKit
import FirebaseAuth
import FirebaseCore
#if canImport(GoogleSignIn)
import GoogleSignIn
#endif

enum AuthServiceError: LocalizedError {
    case emptyCredentials
    case passwordsDoNotMatch
    case missingPresenter
    case missingGoogleClientID
    case missingGoogleToken
    case googleSDKNotLinked

    var errorDescription: String? {
        switch self {
        case .emptyCredentials:
            return "Email and password are required."
        case .passwordsDoNotMatch:
            return "Passwords do not match."
        case .missingPresenter:
            return "Could not present Google sign-in UI."
        case .missingGoogleClientID:
            return "Google client ID is missing in Firebase config."
        case .missingGoogleToken:
            return "Google sign-in did not return a valid token."
        case .googleSDKNotLinked:
            return "GoogleSignIn SDK is not linked. Add GoogleSignIn-iOS package."
        }
    }
}

@MainActor
final class AuthService {
    static let shared = AuthService()

    private init() {}

    func currentUser() -> User? {
        Auth.auth().currentUser
    }

    func signIn(email: String, password: String) async throws -> User {
        let trimmedEmail = email.trimmingCharacters(in: .whitespacesAndNewlines)
        let trimmedPassword = password.trimmingCharacters(in: .whitespacesAndNewlines)

        guard !trimmedEmail.isEmpty, !trimmedPassword.isEmpty else {
            throw AuthServiceError.emptyCredentials
        }

        let authResult = try await Auth.auth().signIn(withEmail: trimmedEmail, password: trimmedPassword)
        return authResult.user
    }

    func signUp(email: String, password: String, confirmPassword: String, fullName: String) async throws -> User {
        let trimmedEmail = email.trimmingCharacters(in: .whitespacesAndNewlines)
        let trimmedPassword = password.trimmingCharacters(in: .whitespacesAndNewlines)
        let trimmedConfirmPassword = confirmPassword.trimmingCharacters(in: .whitespacesAndNewlines)

        guard !trimmedEmail.isEmpty, !trimmedPassword.isEmpty else {
            throw AuthServiceError.emptyCredentials
        }

        guard trimmedPassword == trimmedConfirmPassword else {
            throw AuthServiceError.passwordsDoNotMatch
        }

        let authResult = try await Auth.auth().createUser(withEmail: trimmedEmail, password: trimmedPassword)
        let user = authResult.user
        let trimmedName = fullName.trimmingCharacters(in: .whitespacesAndNewlines)

        if !trimmedName.isEmpty {
            let request = user.createProfileChangeRequest()
            request.displayName = trimmedName
            try await request.commitChanges()
        }

        return user
    }

    func signInWithGoogle(presentingViewController: UIViewController?) async throws -> User {
        guard let presentingViewController else {
            throw AuthServiceError.missingPresenter
        }

        #if canImport(GoogleSignIn)
        guard let clientID = FirebaseApp.app()?.options.clientID else {
            throw AuthServiceError.missingGoogleClientID
        }

        let configuration = GIDConfiguration(clientID: clientID)
        GIDSignIn.sharedInstance.configuration = configuration

        let signInResult = try await GIDSignIn.sharedInstance.signIn(withPresenting: presentingViewController)

        guard let idToken = signInResult.user.idToken?.tokenString else {
            throw AuthServiceError.missingGoogleToken
        }

        let accessToken = signInResult.user.accessToken.tokenString
        let credential = GoogleAuthProvider.credential(withIDToken: idToken, accessToken: accessToken)
        let authResult = try await Auth.auth().signIn(with: credential)

        return authResult.user
        #else
        throw AuthServiceError.googleSDKNotLinked
        #endif
    }

    func signOut() throws {
        try Auth.auth().signOut()
        #if canImport(GoogleSignIn)
        GIDSignIn.sharedInstance.signOut()
        #endif
    }
}
