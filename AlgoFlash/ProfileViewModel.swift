import Combine
import Foundation
import FirebaseAuth

@MainActor
class ProfileViewModel: ObservableObject {
    @Published var appUser: AppUser?
    @Published var isLoading = false
    @Published var errorMessage = ""
    @Published var successMessage = ""

    func fetchProfile() {
        guard let currentUser = Auth.auth().currentUser else { return }
        let uid = currentUser.uid
        isLoading = true

        currentUser.reload { [weak self] _ in
            FirestoreService.shared.fetchUser(userId: uid) { user in
                Task { @MainActor in
                    guard let self else { return }
                    let syncedUser = self.userBySyncingVerifiedEmail(user)
                    self.appUser = syncedUser
                    self.isLoading = false
                }
            }
        }
    }

    func updateName(_ fullName: String, completion: (() -> Void)? = nil) {
        guard let uid = Auth.auth().currentUser?.uid else {
            errorMessage = "No signed-in user found."
            return
        }

        let trimmedName = fullName.trimmingCharacters(in: .whitespacesAndNewlines)
        guard !trimmedName.isEmpty else {
            errorMessage = "Name cannot be empty."
            successMessage = ""
            return
        }

        isLoading = true
        errorMessage = ""
        successMessage = ""

        AuthService.shared.updateDisplayName(trimmedName) { [weak self] authError in
            if let authError {
                Task { @MainActor in
                    self?.isLoading = false
                    self?.errorMessage = authError.localizedDescription
                }
                return
            }

            FirestoreService.shared.updateUserName(userId: uid, fullName: trimmedName) { firestoreError in
                Task { @MainActor in
                    guard let self else { return }
                    self.isLoading = false
                    if let firestoreError {
                        self.errorMessage = firestoreError.localizedDescription
                        return
                    }

                    self.successMessage = "Name updated."
                    self.fetchProfile()
                    completion?()
                }
            }
        }
    }

    func requestEmailUpdate(_ email: String, completion: (() -> Void)? = nil) {
        let trimmedEmail = email.trimmingCharacters(in: .whitespacesAndNewlines)
        guard !trimmedEmail.isEmpty else {
            errorMessage = "Email cannot be empty."
            successMessage = ""
            return
        }

        isLoading = true
        errorMessage = ""
        successMessage = ""

        AuthService.shared.sendEmailUpdateVerification(newEmail: trimmedEmail) { [weak self] error in
            Task { @MainActor in
                guard let self else { return }
                self.isLoading = false
                if let error {
                    self.errorMessage = error.localizedDescription
                    return
                }

                self.successMessage = "Verification email sent. Open the link in that email to finish updating your address."
                completion?()
            }
        }
    }

    func clearMessages() {
        errorMessage = ""
        successMessage = ""
    }

    private func userBySyncingVerifiedEmail(_ user: AppUser?) -> AppUser? {
        guard let user else { return nil }
        guard let authEmail = Auth.auth().currentUser?.email,
              !authEmail.isEmpty,
              authEmail != user.email else {
            return user
        }

        FirestoreService.shared.updateUserEmail(userId: user.id, email: authEmail) { _ in }

        return AppUser(
            id: user.id,
            email: authEmail,
            fullName: user.fullName,
            role: user.role,
            score: user.score,
            quizzesTaken: user.quizzesTaken,
            favourites: user.favourites
        )
    }
}
