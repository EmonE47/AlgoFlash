import SwiftUI

struct QuizView: View {
    @StateObject private var viewModel = QuizViewModel()
    @State private var showingStartButton = true

    var body: some View {
        NavigationStack {
            ZStack {
                if viewModel.isLoading {
                    ProgressView()
                } else if showingStartButton {
                    VStack(spacing: 20) {
                        Image(systemName: "questionmark.circle")
                            .font(.system(size: 70))
                            .foregroundColor(.blue.opacity(0.6))

                        Text("Quiz Mode")
                            .font(.title.bold())

                        Text("Test Your Knowledge")
                            .font(.headline)
                            .foregroundColor(.secondary)

                        Text("Answer multiple choice questions about algorithms. You have \(viewModel.timePerQuestion) seconds per question.")
                            .font(.subheadline)
                            .foregroundColor(.secondary)
                            .multilineTextAlignment(.center)
                            .padding(.horizontal, 20)

                        Spacer()

                        Button(action: {
                            showingStartButton = false
                            viewModel.loadQuestions()
                        }) {
                            Text("Start Quiz")
                                .frame(maxWidth: .infinity)
                                .padding(12)
                                .background(Color.blue)
                                .foregroundColor(.white)
                                .cornerRadius(8)
                        }
                        .padding(.horizontal, 40)
                    }
                    .padding(24)
                } else if viewModel.isFinished {
                    QuizResultView(viewModel: viewModel, onRetry: {
                        showingStartButton = true
                        viewModel.score = 0
                    })
                } else if viewModel.questions.isEmpty {
                    ContentUnavailableView(
                        "No Quiz Questions",
                        systemImage: "questionmark.circle",
                        description: Text("Ask an admin to add quiz questions in the Manage Quiz tab.")
                    )
                } else if let currentQuestion = viewModel.currentQuestion {
                    QuizQuestionView(viewModel: viewModel, question: currentQuestion)
                } else {
                    ProgressView()
                }
            }
            .navigationTitle("Quiz")
            .navigationBarTitleDisplayMode(.inline)
        }
    }
    
}

struct QuizQuestionView: View {
    @ObservedObject var viewModel: QuizViewModel
    let question: QuizQuestion

    var body: some View {
        VStack(spacing: 20) {
            // Progress
            HStack {
                Text("Question \(viewModel.currentIndex + 1) of \(viewModel.questions.count)")
                    .font(.caption)
                    .foregroundColor(.gray)
                Spacer()
                Text("\(viewModel.timeRemaining)s")
                    .font(.caption)
                    .foregroundColor(viewModel.timeRemaining < 10 ? .red : .blue)
            }

            ProgressView(value: Double(viewModel.currentIndex + 1) / Double(viewModel.questions.count))

            // Question
            VStack(alignment: .leading, spacing: 12) {
                Text(question.question)
                    .font(.headline)
                    .lineLimit(3)

                VStack(spacing: 10) {
                    ForEach(0..<question.options.count, id: \.self) { index in
                        OptionButton(
                            text: question.options[index],
                            isSelected: viewModel.selectedOption == index,
                            isCorrect: index == question.correctIndex && viewModel.isAnswered,
                            isWrong: viewModel.selectedOption == index && index != question.correctIndex && viewModel.isAnswered,
                            isDisabled: viewModel.isAnswered
                        ) {
                            viewModel.selectOption(index)
                        }
                    }
                }
            }

            Spacer()

            // Explanation (if answered)
            if viewModel.isAnswered {
                VStack(alignment: .leading, spacing: 8) {
                    Text(viewModel.selectedOption == question.correctIndex ? "Correct!" : "Incorrect!")
                        .font(.headline)
                        .foregroundColor(viewModel.selectedOption == question.correctIndex ? .green : .red)
                    
                    Text(question.explanation)
                        .font(.subheadline)
                        .foregroundColor(.gray)
                }
                .frame(maxWidth: .infinity, alignment: .leading)
                .padding(12)
                .background(Color(.systemGray6))
                .cornerRadius(8)

                Button(action: {
                    viewModel.nextQuestion()
                }) {
                    Text(viewModel.currentIndex + 1 == viewModel.questions.count ? "Finish" : "Next")
                        .frame(maxWidth: .infinity)
                        .padding(12)
                        .background(Color.blue)
                        .foregroundColor(.white)
                        .cornerRadius(8)
                }
            }
        }
        .padding(16)
    }
}

struct OptionButton: View {
    let text: String
    let isSelected: Bool
    let isCorrect: Bool
    let isWrong: Bool
    let isDisabled: Bool
    let action: () -> Void

    var body: some View {
        Button(action: action) {
            HStack {
                Text(text)
                    .lineLimit(2)
                Spacer()
                if isCorrect {
                    Image(systemName: "checkmark.circle.fill")
                        .foregroundColor(.green)
                } else if isWrong {
                    Image(systemName: "xmark.circle.fill")
                        .foregroundColor(.red)
                }
            }
            .padding(12)
            .frame(maxWidth: .infinity, alignment: .leading)
            .background(
                isCorrect ? Color.green.opacity(0.1) :
                    isWrong ? Color.red.opacity(0.1) :
                    isSelected ? Color.blue.opacity(0.1) :
                    Color(.systemGray6)
            )
            .foregroundColor(.primary)
            .cornerRadius(8)
        }
        .disabled(isDisabled)
    }
}

struct QuizResultView: View {
    @ObservedObject var viewModel: QuizViewModel
    let onRetry: () -> Void

    var scorePercentage: Int {
        guard viewModel.questions.count > 0 else { return 0 }
        return (viewModel.score * 100) / viewModel.questions.count
    }

    var body: some View {
        VStack(spacing: 24) {
            Image(systemName: scorePercentage >= 70 ? "star.circle.fill" : "circle.fill")
                .font(.system(size: 60))
                .foregroundColor(scorePercentage >= 70 ? .yellow : .gray)

            VStack(spacing: 8) {
                Text("Quiz Complete!")
                    .font(.headline)

                Text("Your Score")
                    .font(.subheadline)
                    .foregroundColor(.gray)

                HStack(spacing: 8) {
                    Text("\(viewModel.score)")
                        .font(.title.bold())
                    Text("/ \(viewModel.questions.count)")
                        .font(.headline)
                        .foregroundColor(.gray)
                }

                Text("\(scorePercentage)%")
                    .font(.headline)
                    .foregroundColor(scorePercentage >= 70 ? .green : .orange)
            }

            Spacer()

            Button(action: onRetry) {
                Text("Retake Quiz")
                    .frame(maxWidth: .infinity)
                    .padding(12)
                    .background(Color.blue)
                    .foregroundColor(.white)
                    .cornerRadius(8)
            }
        }
        .padding(24)
    }
}
