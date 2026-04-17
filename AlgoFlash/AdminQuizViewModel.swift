import Foundation
import Combine

@MainActor
class AdminQuizViewModel: ObservableObject {
    @Published var questions: [QuizQuestion] = []
    @Published var isLoading: Bool = false
    @Published var errorMessage: String = ""

    func fetchAll() {
        isLoading = true
        FirestoreService.shared.fetchQuizQuestions { [weak self] questions in
            Task { @MainActor in
                self?.questions = questions
                self?.isLoading = false
            }
        }
    }

    func add(question: QuizQuestion) {
        isLoading = true
        FirestoreService.shared.addQuizQuestion(question: question) { [weak self] error in
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

    func update(question: QuizQuestion) {
        isLoading = true
        FirestoreService.shared.updateQuizQuestion(question: question) { [weak self] error in
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

    func delete(question: QuizQuestion) {
        isLoading = true
        FirestoreService.shared.deleteQuizQuestion(question: question) { [weak self] error in
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
