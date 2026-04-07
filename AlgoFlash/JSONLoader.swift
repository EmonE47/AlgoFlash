import Foundation

class JSONLoader {
    static func loadAlgorithms() -> [Algorithm] {
        guard let url = Bundle.main.url(forResource: "algorithms", withExtension: "json"),
              let data = try? Data(contentsOf: url),
              let algorithms = try? JSONDecoder().decode([Algorithm].self, from: data) else {
            return []
        }
        return algorithms
    }
}
