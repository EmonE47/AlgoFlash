import Foundation

struct AppUser: Codable, Identifiable {
    let id: String
    let email: String
    let fullName: String
    let role: String
    var score: Int
    var quizzesTaken: Int
    var favourites: [Int]

    var userRole: UserRole {
        UserRole(rawValue: role) ?? .user
    }
}

enum UserRole: String, Codable {
    case admin = "admin"
    case user = "user"
}
