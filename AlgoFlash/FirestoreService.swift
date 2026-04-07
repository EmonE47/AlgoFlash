import Foundation
import FirebaseFirestore

class FirestoreService {
    static let shared = FirestoreService()
    private let db = Firestore.firestore()
    
    // Save new user profile to Firestore
    func saveUser(id: String, email: String, fullName: String, completion: @escaping (Error?) -> Void) {
        let userData: [String: Any] = [
            "id": id,
            "email": email,
            "fullName": fullName,
            "score": 0 // default starting score
        ]
        
        db.collection("users").document(id).setData(userData) { error in
            completion(error)
        }
    }
    
    // Add saveScore() here later for the Quiz!
}