import Combine
import Foundation

@MainActor
class AdminResultsViewModel: ObservableObject {
    @Published var results: [QuizResult] = []
    @Published var isLoading = false
    @Published var errorMessage = ""

    func fetchAll() {
        isLoading = true
        errorMessage = ""

        FirestoreService.shared.fetchAllResults { [weak self] results in
            Task { @MainActor in
                self?.results = results
                self?.isLoading = false
            }
        }
    }
}
