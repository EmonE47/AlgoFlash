import Foundation
import FirebaseFirestore

class FirestoreService {
    static let shared = FirestoreService()
    private let db = Firestore.firestore()

    // MARK: - User

    func saveUser(id: String, email: String, fullName: String, role: String = "user", completion: @escaping (Error?) -> Void) {
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
            guard let data = snapshot?.data() else {
                completion(nil)
                return
            }
            let user = AppUser(
                id: data["id"] as? String ?? userId,
                email: data["email"] as? String ?? "",
                fullName: data["fullName"] as? String ?? "",
                role: data["role"] as? String ?? "user",
                score: data["score"] as? Int ?? 0,
                quizzesTaken: data["quizzesTaken"] as? Int ?? 0,
                favourites: data["favourites"] as? [Int] ?? []
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

    // MARK: - Algorithms (CRUD for Admin)

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
        db.collection("algorithms").document(String(algorithmId)).setData(data, merge: true, completion: completion)
    }

    func deleteAlgorithm(algorithmId: Int, completion: @escaping (Error?) -> Void) {
        db.collection("algorithms").document(String(algorithmId)).delete(completion: completion)
    }

    // MARK: - Quiz Questions (CRUD for Admin)

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
                    algorithmId: data["algorithmId"] as? Int ?? 0,
                    question: data["question"] as? String ?? "",
                    options: data["options"] as? [String] ?? [],
                    correctIndex: data["correctIndex"] as? Int ?? 0,
                    explanation: data["explanation"] as? String ?? ""
                )
            }
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

    func updateQuizQuestion(questionId: Int, question: QuizQuestion, completion: @escaping (Error?) -> Void) {
        let data: [String: Any] = [
            "id": question.id,
            "algorithmId": question.algorithmId,
            "question": question.question,
            "options": question.options,
            "correctIndex": question.correctIndex,
            "explanation": question.explanation
        ]
        db.collection("quiz_questions").document(String(questionId)).setData(data, merge: true, completion: completion)
    }

    func deleteQuizQuestion(questionId: Int, completion: @escaping (Error?) -> Void) {
        db.collection("quiz_questions").document(String(questionId)).delete(completion: completion)
    }

    // MARK: - Quiz Results

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

    func fetchAllQuizResults(completion: @escaping ([[String: Any]]) -> Void) {
        db.collection("quiz_results").order(by: "date", descending: true).getDocuments { snapshot, _ in
            guard let documents = snapshot?.documents else {
                completion([])
                return
            }
            let results = documents.map { $0.data() }
            completion(results)
        }
    }
}
