import SwiftUI

struct ManageFlashcardsView: View {
    @StateObject private var viewModel = AdminFlashcardViewModel()
    @State private var showingAddSheet = false
    @State private var editingAlgorithm: Algorithm? = nil
    @State private var algorithmPendingDeletion: Algorithm? = nil

    var body: some View {
        NavigationStack {
            ZStack {
                AppBackground()

                if viewModel.isLoading {
                    ProgressView("Loading cards...")
                        .padding(18)
                        .background(.thinMaterial)
                        .clipShape(RoundedRectangle(cornerRadius: 18, style: .continuous))
                } else if viewModel.algorithms.isEmpty {
                    EmptyStateView(
                        icon: "square.stack.3d.up",
                        title: "No Flashcards Yet",
                        subtitle: "Create the first algorithm card for learners.",
                        actionTitle: "Add Flashcard"
                    ) {
                        showingAddSheet = true
                    }
                } else {
                    List {
                        ForEach(viewModel.algorithms, id: \.id) { algorithm in
                            HStack(spacing: 12) {
                                ZStack {
                                    Circle()
                                        .fill(categoryGradient(algorithm.category).0.opacity(0.14))
                                        .frame(width: 42, height: 42)
                                    Image(systemName: "bolt.fill")
                                        .foregroundStyle(categoryGradient(algorithm.category).0)
                                }

                                VStack(alignment: .leading, spacing: 4) {
                                    Text(algorithm.title)
                                        .font(.headline)
                                    HStack(spacing: 8) {
                                        Text(algorithm.category)
                                        Text(algorithm.difficulty)
                                    }
                                    .font(.caption.weight(.medium))
                                    .foregroundStyle(.secondary)
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
                            .padding(.vertical, 6)
                            .listRowBackground(Color.surface0)
                        }
                    }
                    .scrollContentBackground(.hidden)
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
