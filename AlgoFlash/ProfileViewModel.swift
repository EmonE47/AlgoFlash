import Combine
import Foundation
import FirebaseAuth

@MainActor
class ProfileViewModel: ObservableObject {
    @Published var appUser: AppUser?
    @Published var isLoading = false

    func fetchProfile() {
        guard let uid = Auth.auth().currentUser?.uid else { return }
        isLoading = true
        FirestoreService.shared.fetchUser(userId: uid) { [weak self] user in
            Task { @MainActor in
                self?.appUser = user
                self?.isLoading = false
            }
        }
    }
}
