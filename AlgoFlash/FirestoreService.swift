import Foundation
import FirebaseFirestore

class FirestoreService {
    static let shared = FirestoreService()
    private let db = Firestore.firestore()

    // MARK: - User

    func saveUser(id: String, email: String, fullName: String, completion: @escaping (Error?) -> Void) {
        let userData: [String: Any] = [
            "id": id,
            "email": email,
            "fullName": fullName,
            "score": 0,
            "quizzesTaken": 0
        ]
        db.collection("users").document(id).setData(userData, completion: completion)
    }

    func fetchUser(userId: String, completion: @escaping (AppUser?) -> Void) {
        db.collection("users").document(userId).getDocument { snapshot, _ in
            guard let data = snapshot?.data() else {
                completion(nil)
                return
            }
            let user = AppUser(
                id: data["id"] as? String ?? userId,
                fullName: data["fullName"] as? String ?? "",
                email: data["email"] as? String ?? "",
                score: data["score"] as? Int ?? 0,
                quizzesTaken: data["quizzesTaken"] as? Int ?? 0
            )
            completion(user)
        }
    }

    // MARK: - Favourites

    func fetchFavourites(userId: String, completion: @escaping ([Int]) -> Void) {
        db.collection("users").document(userId).getDocument { snapshot, _ in
            let ids = snapshot?.data()?["favourites"] as? [Int] ?? []
            completion(ids)
        }
    }

    func saveFavourites(userId: String, favouriteIDs: [Int], completion: @escaping (Error?) -> Void) {
        db.collection("users").document(userId).updateData(["favourites": favouriteIDs], completion: completion)
    }

    // MARK: - Quiz

    func saveScore(userId: String, score: Int, total: Int, completion: @escaping (Error?) -> Void) {
        let result: [String: Any] = [
            "userId": userId,
            "score": score,
            "total": total,
            "date": Timestamp(date: Date())
        ]
        db.collection("quiz_results").addDocument(data: result, completion: completion)
        // Also update best score on user doc
        db.collection("users").document(userId).getDocument { snapshot, _ in
            let currentBest = snapshot?.data()?["score"] as? Int ?? 0
            if score > currentBest {
                self.db.collection("users").document(userId).updateData(["score": score]) { _ in }
            }
            let taken = (snapshot?.data()?["quizzesTaken"] as? Int ?? 0) + 1
            self.db.collection("users").document(userId).updateData(["quizzesTaken": taken]) { _ in }
        }
    }
}
