import Foundation
import Combine
import FirebaseAuth

@MainActor
class QuizViewModel: ObservableObject {
    @Published var questions: [QuizQuestion] = []
    @Published var currentIndex: Int = 0
    @Published var selectedOption: Int? = nil
    @Published var isAnswered: Bool = false
    @Published var score: Int = 0
    @Published var isFinished: Bool = false
    @Published var timeRemaining: Int = 0
    @Published var isLoading: Bool = false

    private var timer: Timer?
    private var hasScoredCurrentQuestion = false
    private var userID: String? { Auth.auth().currentUser?.uid }
    let timePerQuestion = 30

    func loadQuestions() {
        isLoading = true
        FirestoreService.shared.fetchQuizQuestions { [weak self] questions in
            Task { @MainActor in
                self?.questions = questions.sorted { $0.id < $1.id }
                self?.isLoading = false
                if !questions.isEmpty {
                    self?.startQuiz()
                }
            }
        }
    }

    func startQuiz() {
        currentIndex = 0
        selectedOption = nil
        isAnswered = false
        score = 0
        isFinished = false
        timeRemaining = timePerQuestion
        hasScoredCurrentQuestion = false
        startTimer()
    }

    func selectOption(_ index: Int) {
        if !isAnswered {
            selectedOption = index
            isAnswered = true
            stopTimer()
            checkAnswer()
        }
    }

    func nextQuestion() {
        currentIndex += 1
        selectedOption = nil
        isAnswered = false
        timeRemaining = timePerQuestion
        hasScoredCurrentQuestion = false

        if currentIndex >= questions.count {
            finishQuiz()
        } else {
            startTimer()
        }
    }

    func finishQuiz() {
        isFinished = true
        stopTimer()
        
        guard let uid = userID else { return }
        FirestoreService.shared.saveResult(userId: uid, score: score, total: questions.count) { _ in }
    }

    private func startTimer() {
        stopTimer()
        timer = Timer.scheduledTimer(withTimeInterval: 1.0, repeats: true) { [weak self] _ in
            Task { @MainActor in
                self?.timeRemaining -= 1
                if self?.timeRemaining == 0 {
                    self?.nextQuestion()
                }
            }
        }
    }

    private func stopTimer() {
        timer?.invalidate()
        timer = nil
    }

    deinit {
        stopTimer()
    }

    var currentQuestion: QuizQuestion? {
        guard currentIndex < questions.count else { return nil }
        return questions[currentIndex]
    }

    func checkAnswer() {
        guard let currentQuestion = currentQuestion,
              let selectedOption = selectedOption,
              !hasScoredCurrentQuestion else { return }
        
        if selectedOption == currentQuestion.correctIndex {
            score += 1
        }

        hasScoredCurrentQuestion = true
    }
}
