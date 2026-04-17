import Foundation
import Combine
import FirebaseFirestore

@MainActor
class AdminResultsViewModel: ObservableObject {
    @Published var results: [QuizResult] = []
    @Published var isLoading: Bool = false

    func fetchAll() {
        isLoading = true
        FirestoreService.shared.fetchAllQuizResults { [weak self] resultData in
            Task { @MainActor in
                self?.results = resultData.compactMap { data in
                    guard let userId = data["userId"] as? String,
                          let score = data["score"] as? Int,
                          let total = data["total"] as? Int else {
                        return nil
                    }
                    let timestamp = data["date"] as? Timestamp
                    let date = timestamp?.dateValue() ?? Date()
                    return QuizResult(userId: userId, score: score, total: total, date: date)
                }
                self?.isLoading = false
            }
        }
    }
}

struct QuizResult: Identifiable {
    var id: String { userId + String(date.timeIntervalSince1970) }
    let userId: String
    let score: Int
    let total: Int
    let date: Date
}
