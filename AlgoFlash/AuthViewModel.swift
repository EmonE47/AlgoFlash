import Foundation
import Combine
import FirebaseAuth

@MainActor
class AuthViewModel: ObservableObject {
    @Published var userSession: FirebaseAuth.User?
    @Published var currentRole: UserRole?
    @Published var appUser: AppUser?
    @Published var errorMessage: String = ""
    @Published var isLoading: Bool = false
    
    private var authStateListenerHandle: AuthStateDidChangeListenerHandle?
    
    init() {
        self.userSession = AuthService.shared.getCurrentUser()
        if let user = self.userSession {
            fetchCurrentUser(userId: user.uid)
        }
        
        // Listen for changes in login state
        authStateListenerHandle = Auth.auth().addStateDidChangeListener { [weak self] _, user in
            Task { @MainActor in
                self?.userSession = user
                if let user = user {
                    self?.fetchCurrentUser(userId: user.uid)
                } else {
                    self?.currentRole = nil
                    self?.appUser = nil
                }
            }
        }
    }
    
    deinit {
        if let handle = authStateListenerHandle {
            Auth.auth().removeStateDidChangeListener(handle)
        }
    }
    
    func fetchCurrentUser(userId: String) {
        currentRole = nil
        FirestoreService.shared.fetchUser(userId: userId) { [weak self] user in
            Task { @MainActor in
                self?.appUser = user
                self?.currentRole = user?.userRole ?? .user
            }
        }
    }
    
    func login(email: String, password: String) {
        isLoading = true
        currentRole = nil
        AuthService.shared.signIn(email: email, password: password) { [weak self] result, error in
            Task { @MainActor in
                self?.isLoading = false
                if let error = error {
                    self?.errorMessage = error.localizedDescription
                    return
                }
                self?.errorMessage = ""
                // fetchCurrentUser will be called by auth state listener
            }
        }
    }
    
    func register(email: String, password: String, fullName: String, role: UserRole) {
        isLoading = true
        currentRole = nil
        AuthService.shared.signUp(email: email, password: password) { [weak self] result, error in
            if let error = error {
                Task { @MainActor in
                    self?.isLoading = false
                    self?.errorMessage = error.localizedDescription
                }
                return
            }
            
            // If auth succeeds, save the user to Firestore
            guard let uid = result?.user.uid else {
                Task { @MainActor in
                    self?.isLoading = false
                    self?.errorMessage = "Failed to create account."
                }
                return
            }
            
            FirestoreService.shared.saveUser(id: uid, email: email, fullName: fullName, role: role.rawValue) { error in
                Task { @MainActor in
                    self?.isLoading = false
                    if let error = error {
                        self?.errorMessage = "Failed to save user data: \(error.localizedDescription)"
                    } else {
                        self?.errorMessage = ""
                        self?.fetchCurrentUser(userId: uid)
                    }
                }
            }
        }
    }
    
    func logOut() {
        do {
            try AuthService.shared.signOut()
            self.userSession = nil
            self.currentRole = nil
            self.appUser = nil
        } catch {
            self.errorMessage = "Failed to log out."
        }
    }
}
