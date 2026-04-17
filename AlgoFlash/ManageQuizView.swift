import SwiftUI

struct ManageQuizView: View {
    @StateObject private var viewModel = AdminQuizViewModel()
    @State private var showingAddSheet = false
    @State private var editingQuestion: QuizQuestion? = nil

    var body: some View {
        NavigationStack {
            ZStack {
                if viewModel.isLoading {
                    ProgressView()
                } else if viewModel.questions.isEmpty {
                    VStack(spacing: 16) {
                        Image(systemName: "questionmark.circle")
                            .font(.system(size: 48))
                            .foregroundColor(.gray)
                        Text("No quiz questions yet")
                            .font(.headline)
                        Text("Create your first quiz question")
                            .font(.subheadline)
                            .foregroundColor(.gray)
                    }
                } else {
                    List {
                        ForEach(viewModel.questions, id: \.id) { question in
                            VStack(alignment: .leading, spacing: 4) {
                                Text(question.question)
                                    .font(.headline)
                                    .lineLimit(2)
                                Text("Algorithm ID: \(question.algorithmId)")
                                    .font(.caption)
                                    .foregroundColor(.gray)
                            }
                            .contentShape(Rectangle())
                            .onTapGesture {
                                editingQuestion = question
                            }
                            .swipeActions(edge: .trailing, allowsFullSwipe: false) {
                                Button(role: .destructive) {
                                    viewModel.delete(questionId: question.id)
                                } label: {
                                    Label("Delete", systemImage: "trash")
                                }
                            }
                        }
                    }
                }
            }
            .navigationTitle("Manage Quiz")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .topBarTrailing) {
                    Button(action: { showingAddSheet = true }) {
                        Image(systemName: "plus")
                    }
                }
            }
            .sheet(isPresented: $showingAddSheet) {
                AddQuestionSheet(viewModel: viewModel)
            }
            .sheet(item: $editingQuestion) { question in
                EditQuestionSheet(viewModel: viewModel, question: question)
            }
            .alert("Error", isPresented: .constant(!viewModel.errorMessage.isEmpty)) {
                Button("OK") {
                    viewModel.errorMessage = ""
                }
            } message: {
                Text(viewModel.errorMessage)
            }
        }
        .onAppear {
            viewModel.fetchAll()
        }
    }
}

#Preview {
    ManageQuizView()
}
