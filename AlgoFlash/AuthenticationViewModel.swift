//
//  AuthenticationViewModel.swift
//  AlgoFlash
//
//

import Foundation
#if canImport(UIKit)
import UIKit
#endif
#if canImport(FirebaseCore)
import FirebaseCore
#endif
#if canImport(FirebaseAuth)
import FirebaseAuth
#endif
#if canImport(FirebaseFirestore)
import FirebaseFirestore
#endif
#if canImport(GoogleSignIn)
import GoogleSignIn
#endif

struct AuthenticatedSession: Identifiable, Equatable {
    let id: String
    let fullName: String
    let email: String
    let providerLabel: String

    var initials: String {
        let pieces = fullName
            .split(separator: " ")
            .prefix(2)
            .compactMap { $0.first }

        let letters = String(pieces)
        return letters.isEmpty ? "AF" : letters.uppercased()
    }
}

@MainActor
final class AuthenticationViewModel: ObservableObject {
    @Published private(set) var currentSession: AuthenticatedSession?
    @Published private(set) var isBusy = false
    @Published private(set) var isFirebaseReady = false
    @Published var statusMessage = "Firebase authentication is ready to connect."
    @Published var errorMessage: String?

    func loadSession() {
        #if canImport(FirebaseCore) && canImport(FirebaseAuth)
        isFirebaseReady = FirebaseApp.app() != nil

        guard isFirebaseReady else {
            currentSession = nil
            errorMessage = "Firebase is not configured yet. Add the Apple packages in Xcode and make sure GoogleService-Info.plist is in the AlgoFlash target."
            statusMessage = "Waiting for the Firebase iOS SDK to be linked on macOS."
            return
        }

        currentSession = Self.makeSession(from: Auth.auth().currentUser)
        errorMessage = nil

        if let currentSession {
            statusMessage = "Welcome back, \(currentSession.fullName). Your Firebase session is active."
        } else {
            statusMessage = "Sign in with email/password or Google. Firebase will restore the session automatically next time."
        }
        #else
        isFirebaseReady = false
        currentSession = nil
        errorMessage = "Firebase packages are not linked yet. Add FirebaseCore, FirebaseAuth, FirebaseFirestore, and GoogleSignIn in Xcode on the Mac."
        statusMessage = "The UI is ready, but native Firebase packages still need to be resolved in Xcode."
        #endif
    }

    func signIn(email: String, password: String) async {
        let trimmedEmail = email.trimmingCharacters(in: .whitespacesAndNewlines)

        guard validateCredentials(email: trimmedEmail, password: password, mode: .login) else {
            return
        }

        guard ensureFirebaseReadyForAction() else {
            return
        }

        isBusy = true
        errorMessage = nil
        defer { isBusy = false }

        #if canImport(FirebaseCore) && canImport(FirebaseAuth)
        do {
            let result = try await signInWithEmail(email: trimmedEmail, password: password)
            currentSession = Self.makeSession(from: result.user)

            let syncNote = await syncUserProfile(for: result.user, preferredName: nil, providerOverride: "password")
            statusMessage = "Welcome back, \(currentSession?.fullName ?? "trader").\(syncNote)"
        } catch {
            errorMessage = friendlyMessage(for: error)
            statusMessage = "Sign in could not be completed."
        }
        #endif
    }

    func register(fullName: String, email: String, password: String, confirmPassword: String) async {
        let trimmedName = fullName.trimmingCharacters(in: .whitespacesAndNewlines)
        let trimmedEmail = email.trimmingCharacters(in: .whitespacesAndNewlines)

        guard !trimmedName.isEmpty else {
            errorMessage = "Enter your full name before creating the account."
            statusMessage = "Registration needs your name, email, and password."
            return
        }

        guard validateCredentials(email: trimmedEmail, password: password, mode: .register) else {
            return
        }

        guard password == confirmPassword else {
            errorMessage = "Passwords do not match."
            statusMessage = "Please make sure both password fields are identical."
            return
        }

        guard ensureFirebaseReadyForAction() else {
            return
        }

        isBusy = true
        errorMessage = nil
        defer { isBusy = false }

        #if canImport(FirebaseCore) && canImport(FirebaseAuth)
        do {
            let result = try await createUser(email: trimmedEmail, password: password)
            try await updateDisplayName(trimmedName, for: result.user)
            try? await sendVerificationEmail(to: result.user)

            currentSession = Self.makeSession(from: result.user, preferredName: trimmedName)

            let syncNote = await syncUserProfile(for: result.user, preferredName: trimmedName, providerOverride: "password")
            statusMessage = "Account created for \(trimmedName). A verification email was requested.\(syncNote)"
        } catch {
            errorMessage = friendlyMessage(for: error)
            statusMessage = "Account creation could not be completed."
        }
        #endif
    }

    func signInWithGoogle() async {
        guard ensureFirebaseReadyForAction() else {
            return
        }

        isBusy = true
        errorMessage = nil
        defer { isBusy = false }

        #if canImport(FirebaseCore) && canImport(FirebaseAuth) && canImport(GoogleSignIn) && canImport(UIKit)
        do {
            let result = try await signInWithGoogleFlow()
            currentSession = Self.makeSession(from: result.user)

            let syncNote = await syncUserProfile(for: result.user, preferredName: result.user.displayName, providerOverride: "google")
            statusMessage = "Google sign-in worked for \(currentSession?.fullName ?? "your account").\(syncNote)"
        } catch {
            if isGoogleCancellation(error) {
                errorMessage = nil
                statusMessage = "Google sign-in was cancelled."
            } else {
                errorMessage = friendlyMessage(for: error)
                statusMessage = "Google sign-in could not be completed."
            }
        }
        #else
        errorMessage = "Google Sign-In is not linked yet. Add the GoogleSignIn package in Xcode on the Mac."
        statusMessage = "Google authentication is waiting for the native SDK."
        #endif
    }

    func signOut() {
        #if canImport(FirebaseAuth)
        do {
            try Auth.auth().signOut()
            #if canImport(GoogleSignIn)
            GIDSignIn.sharedInstance.signOut()
            #endif
            currentSession = nil
            errorMessage = nil
            statusMessage = "You have been signed out."
        } catch {
            errorMessage = friendlyMessage(for: error)
            statusMessage = "We could not sign you out cleanly."
        }
        #else
        currentSession = nil
        #endif
    }

    private func validateCredentials(email: String, password: String, mode: AuthMode) -> Bool {
        guard !email.isEmpty else {
            errorMessage = "Enter your email address."
            statusMessage = mode == .login ? "Email is required to sign in." : "Email is required to create an account."
            return false
        }

        guard email.contains("@"), email.contains(".") else {
            errorMessage = "Enter a valid email address."
            statusMessage = "The email format looks incomplete."
            return false
        }

        guard !password.isEmpty else {
            errorMessage = "Enter your password."
            statusMessage = mode == .login ? "Password is required to sign in." : "Password is required to create an account."
            return false
        }

        if mode == .register, password.count < 6 {
            errorMessage = "Password must be at least 6 characters long."
            statusMessage = "Use a stronger password to create the account."
            return false
        }

        return true
    }

    private func ensureFirebaseReadyForAction() -> Bool {
        loadSession()
        return isFirebaseReady
    }

    private func friendlyMessage(for error: Error) -> String {
        if let authFlowError = error as? AuthFlowError, let description = authFlowError.errorDescription {
            return description
        }

        let nsError = error as NSError

        #if canImport(FirebaseAuth)
        if let authCode = AuthErrorCode.Code(rawValue: nsError.code) {
            switch authCode {
            case .invalidEmail:
                return "That email address is not valid."
            case .wrongPassword, .invalidCredential:
                return "The email or password is incorrect."
            case .userNotFound:
                return "No account exists for that email yet."
            case .emailAlreadyInUse:
                return "This email is already connected to another account."
            case .weakPassword:
                return "Choose a stronger password with at least 6 characters."
            case .networkError:
                return "Network problem. Check your internet connection and try again."
            case .tooManyRequests:
                return "Too many attempts for now. Please wait a moment and try again."
            case .accountExistsWithDifferentCredential:
                return "This email already exists with a different sign-in method."
            default:
                break
            }
        }
        #endif

        return nsError.localizedDescription
    }

    private func isGoogleCancellation(_ error: Error) -> Bool {
        let nsError = error as NSError
        return nsError.domain.contains("GIDSignIn") && nsError.code == -5
    }

    private static func makeSession(from user: Any?, preferredName: String? = nil) -> AuthenticatedSession? {
        #if canImport(FirebaseAuth)
        guard let user = user as? User else {
            return nil
        }

        let fallbackName = preferredName?.nonEmpty
            ?? user.displayName?.nonEmpty
            ?? user.email?.split(separator: "@").first.map(String.init)?.replacingOccurrences(of: ".", with: " ").capitalized
            ?? "AlgoFlash User"

        let email = user.email?.nonEmpty ?? "No email available"

        let provider = user.providerData
            .lazy
            .map(\.providerID)
            .first(where: { $0 != "firebase" })
            .flatMap(Self.providerLabel(for:))
            ?? "Email"

        return AuthenticatedSession(
            id: user.uid,
            fullName: fallbackName,
            email: email,
            providerLabel: provider
        )
        #else
        return nil
        #endif
    }

    private static func providerLabel(for providerID: String) -> String? {
        switch providerID {
        case "password":
            return "Email"
        case "google.com":
            return "Google"
        default:
            return providerID.isEmpty ? nil : providerID
        }
    }
}

private enum AuthMode {
    case login
    case register
}

private enum AuthFlowError: LocalizedError {
    case missingPresenter
    case missingClientID
    case missingGoogleToken
    case emptyAuthResult

    var errorDescription: String? {
        switch self {
        case .missingPresenter:
            return "We could not find a screen to present Google sign-in from."
        case .missingClientID:
            return "Firebase could not find the Google client ID in GoogleService-Info.plist."
        case .missingGoogleToken:
            return "Google sign-in finished without returning a valid token."
        case .emptyAuthResult:
            return "Firebase did not return a user session."
        }
    }
}

private extension String {
    var nonEmpty: String? {
        let trimmed = trimmingCharacters(in: .whitespacesAndNewlines)
        return trimmed.isEmpty ? nil : trimmed
    }
}

#if canImport(FirebaseAuth)
private extension AuthenticationViewModel {
    func signInWithEmail(email: String, password: String) async throws -> AuthDataResult {
        try await withCheckedThrowingContinuation { continuation in
            Auth.auth().signIn(withEmail: email, password: password) { result, error in
                if let error {
                    continuation.resume(throwing: error)
                } else if let result {
                    continuation.resume(returning: result)
                } else {
                    continuation.resume(throwing: AuthFlowError.emptyAuthResult)
                }
            }
        }
    }

    func createUser(email: String, password: String) async throws -> AuthDataResult {
        try await withCheckedThrowingContinuation { continuation in
            Auth.auth().createUser(withEmail: email, password: password) { result, error in
                if let error {
                    continuation.resume(throwing: error)
                } else if let result {
                    continuation.resume(returning: result)
                } else {
                    continuation.resume(throwing: AuthFlowError.emptyAuthResult)
                }
            }
        }
    }

    func signIn(with credential: AuthCredential) async throws -> AuthDataResult {
        try await withCheckedThrowingContinuation { continuation in
            Auth.auth().signIn(with: credential) { result, error in
                if let error {
                    continuation.resume(throwing: error)
                } else if let result {
                    continuation.resume(returning: result)
                } else {
                    continuation.resume(throwing: AuthFlowError.emptyAuthResult)
                }
            }
        }
    }

    func updateDisplayName(_ fullName: String, for user: User) async throws {
        try await withCheckedThrowingContinuation { continuation in
            let request = user.createProfileChangeRequest()
            request.displayName = fullName
            request.commitChanges { error in
                if let error {
                    continuation.resume(throwing: error)
                } else {
                    continuation.resume(returning: ())
                }
            }
        }
    }

    func sendVerificationEmail(to user: User) async throws {
        try await withCheckedThrowingContinuation { continuation in
            user.sendEmailVerification { error in
                if let error {
                    continuation.resume(throwing: error)
                } else {
                    continuation.resume(returning: ())
                }
            }
        }
    }
}
#endif

#if canImport(FirebaseFirestore) && canImport(FirebaseAuth)
private extension AuthenticationViewModel {
    func syncUserProfile(for user: User, preferredName: String?, providerOverride: String) async -> String {
        let displayName = preferredName?.nonEmpty
            ?? user.displayName?.nonEmpty
            ?? user.email?.split(separator: "@").first.map(String.init)?.replacingOccurrences(of: ".", with: " ").capitalized
            ?? "AlgoFlash User"

        let payload: [String: Any] = [
            "uid": user.uid,
            "displayName": displayName,
            "email": user.email ?? "",
            "provider": providerOverride,
            "lastLoginAt": FieldValue.serverTimestamp()
        ]

        do {
            try await withCheckedThrowingContinuation { continuation in
                Firestore.firestore()
                    .collection("users")
                    .document(user.uid)
                    .setData(payload, merge: true) { error in
                        if let error {
                            continuation.resume(throwing: error)
                        } else {
                            continuation.resume(returning: ())
                        }
                    }
            }

            return " Your profile was synced to Firestore."
        } catch {
            return " Authentication worked, but Firestore profile sync still needs attention."
        }
    }
}
#else
private extension AuthenticationViewModel {
    func syncUserProfile(for user: Any, preferredName: String?, providerOverride: String) async -> String {
        ""
    }
}
#endif

#if canImport(FirebaseCore) && canImport(FirebaseAuth) && canImport(GoogleSignIn) && canImport(UIKit)
private extension AuthenticationViewModel {
    func signInWithGoogleFlow() async throws -> AuthDataResult {
        guard let clientID = FirebaseApp.app()?.options.clientID else {
            throw AuthFlowError.missingClientID
        }

        guard let presentingViewController = Self.topViewController() else {
            throw AuthFlowError.missingPresenter
        }

        GIDSignIn.sharedInstance.configuration = GIDConfiguration(clientID: clientID)

        let signInResult = try await withCheckedThrowingContinuation { continuation in
            GIDSignIn.sharedInstance.signIn(withPresenting: presentingViewController) { result, error in
                if let error {
                    continuation.resume(throwing: error)
                } else if let result {
                    continuation.resume(returning: result)
                } else {
                    continuation.resume(throwing: AuthFlowError.emptyAuthResult)
                }
            }
        }

        guard let idToken = signInResult.user.idToken?.tokenString else {
            throw AuthFlowError.missingGoogleToken
        }

        let accessToken = signInResult.user.accessToken.tokenString
        let credential = GoogleAuthProvider.credential(withIDToken: idToken, accessToken: accessToken)
        return try await signIn(with: credential)
    }

    static func topViewController(
        from controller: UIViewController? = UIApplication.shared.connectedScenes
            .compactMap { $0 as? UIWindowScene }
            .flatMap(\.windows)
            .first(where: \.isKeyWindow)?
            .rootViewController
    ) -> UIViewController? {
        if let navigationController = controller as? UINavigationController {
            return topViewController(from: navigationController.visibleViewController)
        }

        if let tabBarController = controller as? UITabBarController {
            return topViewController(from: tabBarController.selectedViewController)
        }

        if let presentedViewController = controller?.presentedViewController {
            return topViewController(from: presentedViewController)
        }

        return controller
    }
}
#endif
