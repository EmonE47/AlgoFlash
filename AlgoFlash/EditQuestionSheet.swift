import SwiftUI

struct EditQuestionSheet: View {
    @Environment(\.dismiss) var dismiss
    @ObservedObject var viewModel: AdminQuizViewModel
    
    let question: QuizQuestion

    @State private var algorithmId: Int = 1
    @State private var questionText: String = ""
    @State private var option1: String = ""
    @State private var option2: String = ""
    @State private var option3: String = ""
    @State private var option4: String = ""
    @State private var correctIndex: Int = 0
    @State private var explanation: String = ""

    var body: some View {
        NavigationStack {
            Form {
                Section("Algorithm") {
                    Stepper("Algorithm ID: \(algorithmId)", value: $algorithmId, in: 1...1000)
                }

                Section("Question") {
                    TextField("Question", text: $questionText, axis: .vertical)
                        .lineLimit(2...5)
                }

                Section("Options") {
                    TextField("Option 1", text: $option1)
                    TextField("Option 2", text: $option2)
                    TextField("Option 3", text: $option3)
                    TextField("Option 4", text: $option4)
                    
                    Picker("Correct Answer", selection: $correctIndex) {
                        Text("Option 1").tag(0)
                        Text("Option 2").tag(1)
                        Text("Option 3").tag(2)
                        Text("Option 4").tag(3)
                    }
                }

                Section("Explanation") {
                    TextField("Explanation", text: $explanation, axis: .vertical)
                        .lineLimit(3...6)
                }
            }
            .navigationTitle("Edit Question")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .topBarLeading) {
                    Button("Cancel") {
                        dismiss()
                    }
                }
                ToolbarItem(placement: .topBarTrailing) {
                    Button("Save") {
                        updateQuestion()
                    }
                    .disabled(questionText.isEmpty || option1.isEmpty || option2.isEmpty || option3.isEmpty || option4.isEmpty)
                }
            }
            .onAppear {
                algorithmId = question.algorithmId
                questionText = question.question
                option1 = question.options[safe: 0] ?? ""
                option2 = question.options[safe: 1] ?? ""
                option3 = question.options[safe: 2] ?? ""
                option4 = question.options[safe: 3] ?? ""
                correctIndex = question.correctIndex
                explanation = question.explanation
            }
        }
    }

    private func updateQuestion() {
        let options = [option1, option2, option3, option4]
        
        let updatedQuestion = QuizQuestion(
            id: question.id,
            algorithmId: algorithmId,
            question: questionText,
            options: options,
            correctIndex: correctIndex,
            explanation: explanation
        )
        
        viewModel.update(question: updatedQuestion)
        dismiss()
    }
}

extension Array {
    subscript(safe index: Int) -> Element? {
        return indices.contains(index) ? self[index] : nil
    }
}

#Preview {
    EditQuestionSheet(viewModel: AdminQuizViewModel(), question: QuizQuestion(id: 1, algorithmId: 1, question: "Test?", options: ["A", "B", "C", "D"], correctIndex: 0, explanation: "Explanation"))
}
