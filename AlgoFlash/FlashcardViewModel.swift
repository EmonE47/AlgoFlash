import Foundation
import Combine
import FirebaseAuth

@MainActor
class FlashcardViewModel: ObservableObject {
    @Published var algorithms: [Algorithm] = []
    @Published var favouriteIDs: Set<Int> = []
    @Published var selectedCategory: String = "All"
    @Published var isLoading: Bool = false

    let categories = ["All", "Searching", "Sorting", "Graph", "Dynamic Programming"]

    var filteredAlgorithms: [Algorithm] {
        selectedCategory == "All"
            ? algorithms
            : algorithms.filter { $0.category == selectedCategory }
    }

    var favouriteAlgorithms: [Algorithm] {
        algorithms.filter { favouriteIDs.contains($0.id) }
    }

    private var userID: String? { Auth.auth().currentUser?.uid }

    init() {
        loadAlgorithms()
        fetchFavourites()
    }

    func loadAlgorithms() {
        isLoading = true
        FirestoreService.shared.fetchAlgorithms { [weak self] algorithms in
            Task { @MainActor in
                self?.algorithms = algorithms
                self?.isLoading = false
            }
        }
    }

    func toggleFavourite(_ algorithm: Algorithm) {
        if favouriteIDs.contains(algorithm.id) {
            favouriteIDs.remove(algorithm.id)
        } else {
            favouriteIDs.insert(algorithm.id)
        }
        saveFavourites()
    }

    func isFavourite(_ algorithm: Algorithm) -> Bool {
        favouriteIDs.contains(algorithm.id)
    }

    private func fetchFavourites() {
        guard let uid = userID else { return }
        FirestoreService.shared.fetchFavourites(userId: uid) { [weak self] ids in
            Task { @MainActor in
                self?.favouriteIDs = Set(ids)
            }
        }
    }

    private func saveFavourites() {
        guard let uid = userID else { return }
        FirestoreService.shared.updateFavourites(userId: uid, ids: Array(favouriteIDs)) { _ in }
    }
}
