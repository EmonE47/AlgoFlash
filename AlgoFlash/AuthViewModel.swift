import Foundation
import FirebaseAuth

@MainActor
class AuthViewModel: ObservableObject {
    @Published var userSession: FirebaseAuth.User?
    @Published var errorMessage: String = ""
    @Published var isLoading: Bool = false
    
    init() {
        self.userSession = AuthService.shared.getCurrentUser()
        
        // Listen for changes in login state
        Auth.auth().addStateDidChangeListener { [weak self] _, user in
            self?.userSession = user
        }
    }
    
    func login(email: String, password: String) {
        isLoading = true
        AuthService.shared.signIn(email: email, password: password) { [weak self] result, error in
            self?.isLoading = false
            if let error = error {
                self?.errorMessage = error.localizedDescription
                return
            }
            self?.errorMessage = ""
        }
    }
    
    func register(email: String, password: String, fullName: String) {
        isLoading = true
        AuthService.shared.signUp(email: email, password: password) { [weak self] result, error in
            if let error = error {
                self?.isLoading = false
                self?.errorMessage = error.localizedDescription
                return
            }
            
            // If auth succeeds, save the user to Firestore
            guard let uid = result?.user.uid else { return }
            
            FirestoreService.shared.saveUser(id: uid, email: email, fullName: fullName) { error in
                self?.isLoading = false
                if let error = error {
                    self?.errorMessage = "Failed to save user data: \(error.localizedDescription)"
                } else {
                    self?.errorMessage = ""
                }
            }
        }
    }
    
    func logOut() {
        do {
            try AuthService.shared.signOut()
            self.userSession = nil
        } catch {
            self.errorMessage = "Failed to log out."
        }
    }
}