import SwiftUI

struct ManageFlashcardsView: View {
    @StateObject private var viewModel = AdminFlashcardViewModel()
    @State private var showingAddSheet = false
    @State private var editingAlgorithm: Algorithm? = nil
    @State private var algorithmPendingDeletion: Algorithm? = nil

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
                            HStack(spacing: 12) {
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

                                Spacer()

                                Button(role: .destructive) {
                                    algorithmPendingDeletion = algorithm
                                } label: {
                                    Image(systemName: "trash")
                                        .foregroundColor(.red)
                                        .padding(8)
                                }
                                .buttonStyle(.borderless)
                                .accessibilityLabel("Delete \(algorithm.title)")
                            }
                            .swipeActions(edge: .trailing, allowsFullSwipe: false) {
                                Button(role: .destructive) {
                                    algorithmPendingDeletion = algorithm
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
            .confirmationDialog(
                "Delete Flashcard",
                isPresented: deleteConfirmationBinding,
                titleVisibility: .visible
            ) {
                if let algorithm = algorithmPendingDeletion {
                    Button("Delete \(algorithm.title)", role: .destructive) {
                        viewModel.delete(algorithmId: algorithm.id)
                        algorithmPendingDeletion = nil
                    }
                }
                Button("Cancel", role: .cancel) {
                    algorithmPendingDeletion = nil
                }
            } message: {
                if let algorithm = algorithmPendingDeletion {
                    Text("This will permanently delete \(algorithm.title).")
                }
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
            get: { algorithmPendingDeletion != nil },
            set: { isPresented in
                if !isPresented {
                    algorithmPendingDeletion = nil
                }
            }
        )
    }
}

#Preview {
    ManageFlashcardsView()
}
