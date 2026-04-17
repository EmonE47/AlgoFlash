import SwiftUI

struct ManageFlashcardsView: View {
    @StateObject private var viewModel = AdminFlashcardViewModel()
    @State private var showingAddSheet = false
    @State private var editingAlgorithm: Algorithm? = nil

    var body: some View {
        NavigationStack {
            ZStack {
                if viewModel.isLoading {
                    ProgressView()
                } else if viewModel.algorithms.isEmpty {
                    VStack(spacing: 16) {
                        Image(systemName: "rectangle.on.rectangle")
                            .font(.system(size: 48))
                            .foregroundColor(.gray)
                        Text("No flashcards yet")
                            .font(.headline)
                        Text("Create your first algorithm flashcard")
                            .font(.subheadline)
                            .foregroundColor(.gray)
                    }
                } else {
                    List {
                        ForEach(viewModel.algorithms, id: \.id) { algorithm in
                            VStack(alignment: .leading, spacing: 4) {
                                Text(algorithm.title)
                                    .font(.headline)
                                Text(algorithm.category)
                                    .font(.caption)
                                    .foregroundColor(.gray)
                            }
                            .contentShape(Rectangle())
                            .onTapGesture {
                                editingAlgorithm = algorithm
                            }
                            .swipeActions(edge: .trailing, allowsFullSwipe: false) {
                                Button(role: .destructive) {
                                    viewModel.delete(algorithmId: algorithm.id)
                                } label: {
                                    Label("Delete", systemImage: "trash")
                                }
                            }
                        }
                    }
                }
            }
            .navigationTitle("Manage Flashcards")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .topBarTrailing) {
                    Button(action: { showingAddSheet = true }) {
                        Image(systemName: "plus")
                    }
                }
            }
            .sheet(isPresented: $showingAddSheet) {
                AddAlgorithmSheet(viewModel: viewModel)
            }
            .sheet(item: $editingAlgorithm) { algorithm in
                EditAlgorithmSheet(viewModel: viewModel, algorithm: algorithm)
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
    ManageFlashcardsView()
}
