import Foundation

struct QuizQuestion: Identifiable, Codable {
    let id: Int
    let algorithmId: Int
    let question: String
    let options: [String]
    let correctIndex: Int
    let explanation: String
}
