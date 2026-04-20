import Foundation
import FirebaseAuth

class AuthService {
    static let shared = AuthService()
    
    func signIn(email: String, password: String, completion: @escaping (AuthDataResult?, Error?) -> Void) {
        Auth.auth().signIn(withEmail: email, password: password, completion: completion)
    }
    
    func signUp(email: String, password: String, completion: @escaping (AuthDataResult?, Error?) -> Void) {
        Auth.auth().createUser(withEmail: email, password: password, completion: completion)
    }
    
    func signOut() throws {
        try Auth.auth().signOut()
    }
    
    func getCurrentUser() -> User? {
        return Auth.auth().currentUser
    }

    func updateDisplayName(_ fullName: String, completion: @escaping (Error?) -> Void) {
        guard let user = Auth.auth().currentUser else {
            completion(AuthServiceError.noCurrentUser)
            return
        }

        let changeRequest = user.createProfileChangeRequest()
        changeRequest.displayName = fullName
        changeRequest.commitChanges(completion: completion)
    }

    func updateEmail(_ email: String, completion: @escaping (Error?) -> Void) {
        guard let user = Auth.auth().currentUser else {
            completion(AuthServiceError.noCurrentUser)
            return
        }

        user.updateEmail(to: email, completion: completion)
    }

}

enum AuthServiceError: LocalizedError {
    case noCurrentUser

    var errorDescription: String? {
        switch self {
        case .noCurrentUser:
            return "No signed-in user found."
        }
    }
}
