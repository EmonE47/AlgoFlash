import SwiftUI

struct AddQuestionSheet: View {
    @Environment(\.dismiss) var dismiss
    @ObservedObject var viewModel: AdminQuizViewModel

    @State private var algorithmId: Int = 1
    @State private var question: String = ""
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
                    TextField("Question", text: $question, axis: .vertical)
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
            .scrollContentBackground(.hidden)
            .background(AppBackground())
            .tint(Color.warning)
            .navigationTitle("Add Question")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .topBarLeading) {
                    Button("Cancel") {
                        dismiss()
                    }
                }
                ToolbarItem(placement: .topBarTrailing) {
                    Button("Save") {
                        saveQuestion()
                    }
                    .disabled(question.isEmpty || option1.isEmpty || option2.isEmpty || option3.isEmpty || option4.isEmpty)
                }
            }
        }
    }

    private func saveQuestion() {
        let newId = (viewModel.questions.max { $0.id < $1.id }?.id ?? 0) + 1
        let options = [option1, option2, option3, option4]
        
        let question = QuizQuestion(
            id: newId,
            documentID: nil,
            algorithmId: algorithmId,
            question: self.question,
            options: options,
            correctIndex: correctIndex,
            explanation: explanation
        )
        
        viewModel.add(question: question)
        dismiss()
    }
}

#Preview {
    AddQuestionSheet(viewModel: AdminQuizViewModel())
}
