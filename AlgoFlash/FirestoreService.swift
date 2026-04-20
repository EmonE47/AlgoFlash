import Foundation
import FirebaseFirestore

struct QuizResult: Identifiable {
    let id: String
    let userId: String
    let userName: String
    let userEmail: String
    let score: Int
    let total: Int
    let date: Date

    var displayName: String {
        if !userName.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty {
            return userName
        }

        if !userEmail.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty {
            return userEmail
        }

        return "Unknown User"
    }
}

class FirestoreService {
    static let shared = FirestoreService()

    private let db = Firestore.firestore()

    private init() {}

    // MARK: - User

    func saveUser(
        id: String,
        email: String,
        fullName: String,
        role: String = UserRole.user.rawValue,
        completion: @escaping (Error?) -> Void
    ) {
        let userData: [String: Any] = [
            "id": id,
            "email": email,
            "fullName": fullName,
            "role": role,
            "score": 0,
            "quizzesTaken": 0,
            "favourites": []
        ]

        db.collection("users").document(id).setData(userData, completion: completion)
    }

    func fetchUser(userId: String, completion: @escaping (AppUser?) -> Void) {
        db.collection("users").document(userId).getDocument { snapshot, _ in
            guard let snapshot, snapshot.exists, let data = snapshot.data() else {
                completion(nil)
                return
            }

            let user = AppUser(
                id: data["id"] as? String ?? userId,
                email: data["email"] as? String ?? "",
                fullName: data["fullName"] as? String ?? "",
                role: data["role"] as? String ?? UserRole.user.rawValue,
                score: data["score"] as? Int ?? 0,
                quizzesTaken: data["quizzesTaken"] as? Int ?? 0,
                favourites: data["favourites"] as? [Int] ?? []
            )
            completion(user)
        }
    }

    func fetchFavourites(userId: String, completion: @escaping ([Int]) -> Void) {
        db.collection("users").document(userId).getDocument { snapshot, _ in
            completion(snapshot?.data()?["favourites"] as? [Int] ?? [])
        }
    }

    func updateFavourites(userId: String, ids: [Int], completion: @escaping (Error?) -> Void) {
        db.collection("users").document(userId).updateData(["favourites": ids], completion: completion)
    }

    func saveFavourites(userId: String, favouriteIDs: [Int], completion: @escaping (Error?) -> Void) {
        updateFavourites(userId: userId, ids: favouriteIDs, completion: completion)
    }

    // MARK: - Algorithms

    func fetchAlgorithms(completion: @escaping ([Algorithm]) -> Void) {
        db.collection("algorithms").getDocuments { snapshot, _ in
            guard let documents = snapshot?.documents else {
                completion([])
                return
            }

            let algorithms = documents.compactMap { doc -> Algorithm? in
                let data = doc.data()
                return Algorithm(
                    id: data["id"] as? Int ?? 0,
                    title: data["title"] as? String ?? "",
                    category: data["category"] as? String ?? "",
                    definition: data["definition"] as? String ?? "",
                    timeComplexity: data["timeComplexity"] as? String ?? "",
                    pseudocode: data["pseudocode"] as? String ?? "",
                    difficulty: data["difficulty"] as? String ?? ""
                )
            }
            .sorted { $0.id < $1.id }

            completion(algorithms)
        }
    }

    func addAlgorithm(algorithm: Algorithm, completion: @escaping (Error?) -> Void) {
        let data: [String: Any] = [
            "id": algorithm.id,
            "title": algorithm.title,
            "category": algorithm.category,
            "definition": algorithm.definition,
            "timeComplexity": algorithm.timeComplexity,
            "pseudocode": algorithm.pseudocode,
            "difficulty": algorithm.difficulty
        ]

        db.collection("algorithms").document(String(algorithm.id)).setData(data, completion: completion)
    }

    func updateAlgorithm(id: Int, data: [String: Any], completion: @escaping (Error?) -> Void) {
        db.collection("algorithms").document(String(id)).setData(data, merge: true, completion: completion)
    }

    func updateAlgorithm(algorithmId: Int, algorithm: Algorithm, completion: @escaping (Error?) -> Void) {
        let data: [String: Any] = [
            "id": algorithm.id,
            "title": algorithm.title,
            "category": algorithm.category,
            "definition": algorithm.definition,
            "timeComplexity": algorithm.timeComplexity,
            "pseudocode": algorithm.pseudocode,
            "difficulty": algorithm.difficulty
        ]

        updateAlgorithm(id: algorithmId, data: data, completion: completion)
    }

    func deleteAlgorithm(algorithmId: Int, completion: @escaping (Error?) -> Void) {
        db.collection("algorithms").document(String(algorithmId)).delete(completion: completion)
    }

    // MARK: - Quiz Questions

    func fetchQuizQuestions(completion: @escaping ([QuizQuestion]) -> Void) {
        db.collection("quiz_questions").getDocuments { snapshot, _ in
            guard let documents = snapshot?.documents else {
                completion([])
                return
            }

            let questions = documents.compactMap { doc -> QuizQuestion? in
                let data = doc.data()
                return QuizQuestion(
                    id: data["id"] as? Int ?? 0,
                    documentID: doc.documentID,
                    algorithmId: data["algorithmId"] as? Int ?? 0,
                    question: data["question"] as? String ?? "",
                    options: data["options"] as? [String] ?? [],
                    correctIndex: data["correctIndex"] as? Int ?? 0,
                    explanation: data["explanation"] as? String ?? ""
                )
            }
            .sorted { $0.id < $1.id }

            completion(questions)
        }
    }

    func addQuizQuestion(question: QuizQuestion, completion: @escaping (Error?) -> Void) {
        let data: [String: Any] = [
            "id": question.id,
            "algorithmId": question.algorithmId,
            "question": question.question,
            "options": question.options,
            "correctIndex": question.correctIndex,
            "explanation": question.explanation
        ]

        db.collection("quiz_questions").addDocument(data: data, completion: completion)
    }

    func updateQuizQuestion(question: QuizQuestion, completion: @escaping (Error?) -> Void) {
        let data: [String: Any] = [
            "id": question.id,
            "algorithmId": question.algorithmId,
            "question": question.question,
            "options": question.options,
            "correctIndex": question.correctIndex,
            "explanation": question.explanation
        ]

        let documentID = question.documentID ?? String(question.id)
        db.collection("quiz_questions").document(documentID).setData(data, merge: true, completion: completion)
    }

    func deleteQuizQuestion(question: QuizQuestion, completion: @escaping (Error?) -> Void) {
        let documentID = question.documentID ?? String(question.id)
        db.collection("quiz_questions").document(documentID).delete(completion: completion)
    }

    // MARK: - Quiz Results

    func saveResult(userId: String, score: Int, total: Int, completion: @escaping (Error?) -> Void) {
        fetchUser(userId: userId) { [weak self] user in
            guard let self else { return }

            let result: [String: Any] = [
                "userId": userId,
                "userName": user?.fullName ?? "",
                "userEmail": user?.email ?? "",
                "score": score,
                "total": total,
                "date": Timestamp(date: Date())
            ]

            self.db.collection("quiz_results").addDocument(data: result) { error in
                if let error {
                    completion(error)
                    return
                }

                self.updateUserStats(userId: userId, score: score)
                completion(nil)
            }
        }
    }

    func saveScore(userId: String, score: Int, total: Int, completion: @escaping (Error?) -> Void) {
        saveResult(userId: userId, score: score, total: total, completion: completion)
    }

    func fetchAllResults(completion: @escaping ([QuizResult]) -> Void) {
        db.collection("quiz_results").order(by: "date", descending: true).getDocuments { snapshot, _ in
            guard let documents = snapshot?.documents else {
                completion([])
                return
            }

            guard !documents.isEmpty else {
                completion([])
                return
            }

            var results = documents.map { document in
                let data = document.data()
                let timestamp = data["date"] as? Timestamp

                return QuizResult(
                    id: document.documentID,
                    userId: data["userId"] as? String ?? "",
                    userName: (data["userName"] as? String) ?? (data["userFullName"] as? String) ?? "",
                    userEmail: data["userEmail"] as? String ?? "",
                    score: data["score"] as? Int ?? 0,
                    total: data["total"] as? Int ?? 0,
                    date: timestamp?.dateValue() ?? Date()
                )
            }

            let group = DispatchGroup()

            for index in results.indices {
                guard results[index].userName.isEmpty, !results[index].userId.isEmpty else { continue }

                group.enter()
                self.fetchUser(userId: results[index].userId) { user in
                    if let user {
                        results[index] = QuizResult(
                            id: results[index].id,
                            userId: results[index].userId,
                            userName: user.fullName,
                            userEmail: results[index].userEmail.isEmpty ? user.email : results[index].userEmail,
                            score: results[index].score,
                            total: results[index].total,
                            date: results[index].date
                        )
                    }
                    group.leave()
                }
            }

            group.notify(queue: .main) {
                completion(results)
            }
        }
    }

    func fetchAllQuizResults(completion: @escaping ([QuizResult]) -> Void) {
        fetchAllResults(completion: completion)
    }

    private func updateUserStats(userId: String, score: Int) {
        let userRef = db.collection("users").document(userId)

        userRef.getDocument { snapshot, _ in
            let currentBest = snapshot?.data()?["score"] as? Int ?? 0
            let quizzesTaken = snapshot?.data()?["quizzesTaken"] as? Int ?? 0

            userRef.updateData([
                "score": max(currentBest, score),
                "quizzesTaken": quizzesTaken + 1
            ]) { _ in }
        }
    }
}
