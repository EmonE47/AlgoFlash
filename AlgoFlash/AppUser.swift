import Foundation

struct AppUser: Codable {
    let id: String
    let fullName: String
    let email: String
    var score: Int
    var quizzesTaken: Int
}
