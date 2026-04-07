import Foundation

struct Algorithm: Identifiable, Codable, Equatable {
    let id: Int
    let title: String
    let category: String
    let definition: String
    let timeComplexity: String
    let pseudocode: String
    let difficulty: String
}
