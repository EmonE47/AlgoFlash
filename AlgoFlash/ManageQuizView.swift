import SwiftUI

struct ManageQuizView: View {
    @StateObject private var viewModel = AdminQuizViewModel()
    @State private var showingAddSheet = false
    @State private var editingQuestion: QuizQuestion? = nil
    @State private var questionPendingDeletion: QuizQuestion? = nil

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
                            HStack(spacing: 12) {
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

                                Spacer()

                                Button(role: .destructive) {
                                    questionPendingDeletion = question
                                } label: {
                                    Image(systemName: "trash")
                                        .foregroundColor(.red)
                                        .padding(8)
                                }
                                .buttonStyle(.borderless)
                                .accessibilityLabel("Delete quiz question")
                            }
                            .swipeActions(edge: .trailing, allowsFullSwipe: false) {
                                Button(role: .destructive) {
                                    questionPendingDeletion = question
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
            .confirmationDialog(
                "Delete Quiz Question",
                isPresented: deleteConfirmationBinding,
                titleVisibility: .visible
            ) {
                if let question = questionPendingDeletion {
                    Button("Delete Question", role: .destructive) {
                        viewModel.delete(question: question)
                        questionPendingDeletion = nil
                    }
                }
                Button("Cancel", role: .cancel) {
                    questionPendingDeletion = nil
                }
            } message: {
                Text("This will permanently delete this quiz question.")
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

    private var deleteConfirmationBinding: Binding<Bool> {
        Binding(
            get: { questionPendingDeletion != nil },
            set: { isPresented in
                if !isPresented {
                    questionPendingDeletion = nil
                }
            }
        )
    }
}

#Preview {
    ManageQuizView()
}
