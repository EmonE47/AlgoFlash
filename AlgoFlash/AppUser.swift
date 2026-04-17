import Foundation

struct AppUser: Codable {
    let id: String
    let email: String
    let fullName: String
    let role: String  // "admin" or "user"
    var score: Int
    var quizzesTaken: Int
    var favourites: [Int]
}

enum UserRole: String {
    case admin = "admin"
    case user = "user"
}
