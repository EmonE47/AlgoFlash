import Foundation
import Combine

@MainActor
class AdminFlashcardViewModel: ObservableObject {
    @Published var algorithms: [Algorithm] = []
    @Published var isLoading: Bool = false
    @Published var errorMessage: String = ""

    func fetchAll() {
        isLoading = true
        FirestoreService.shared.fetchAlgorithms { [weak self] algorithms in
            Task { @MainActor in
                self?.algorithms = algorithms.sorted { $0.id < $1.id }
                self?.isLoading = false
            }
        }
    }

    func add(algorithm: Algorithm) {
        isLoading = true
        FirestoreService.shared.addAlgorithm(algorithm: algorithm) { [weak self] error in
            Task { @MainActor in
                self?.isLoading = false
                if let error = error {
                    self?.errorMessage = error.localizedDescription
                } else {
                    self?.errorMessage = ""
                    self?.fetchAll()
                }
            }
        }
    }

    func update(algorithm: Algorithm) {
        isLoading = true
        FirestoreService.shared.updateAlgorithm(algorithmId: algorithm.id, algorithm: algorithm) { [weak self] error in
            Task { @MainActor in
                self?.isLoading = false
                if let error = error {
                    self?.errorMessage = error.localizedDescription
                } else {
                    self?.errorMessage = ""
                    self?.fetchAll()
                }
            }
        }
    }

    func delete(algorithmId: Int) {
        isLoading = true
        FirestoreService.shared.deleteAlgorithm(algorithmId: algorithmId) { [weak self] error in
            Task { @MainActor in
                self?.isLoading = false
                if let error = error {
                    self?.errorMessage = error.localizedDescription
                } else {
                    self?.errorMessage = ""
                    self?.fetchAll()
                }
            }
        }
    }
}
