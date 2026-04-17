import SwiftUI

struct EditAlgorithmSheet: View {
    @Environment(\.dismiss) var dismiss
    @ObservedObject var viewModel: AdminFlashcardViewModel
    
    let algorithm: Algorithm

    @State private var title: String = ""
    @State private var category: String = ""
    @State private var definition: String = ""
    @State private var timeComplexity: String = ""
    @State private var pseudocode: String = ""
    @State private var difficulty: String = ""

    let difficulties = ["Easy", "Medium", "Hard"]

    var body: some View {
        NavigationStack {
            Form {
                Section("Basic Info") {
                    TextField("Title", text: $title)
                    Picker("Category", selection: $category) {
                        Text("Select").tag("")
                        Text("Searching").tag("Searching")
                        Text("Sorting").tag("Sorting")
                        Text("Graph").tag("Graph")
                        Text("Dynamic Programming").tag("Dynamic Programming")
                        Text("String").tag("String")
                    }
                }

                Section("Details") {
                    TextField("Definition", text: $definition, axis: .vertical)
                        .lineLimit(3...6)
                    TextField("Time Complexity", text: $timeComplexity)
                    Picker("Difficulty", selection: $difficulty) {
                        ForEach(difficulties, id: \.self) { diff in
                            Text(diff).tag(diff)
                        }
                    }
                }

                Section("Pseudocode") {
                    TextField("Pseudocode", text: $pseudocode, axis: .vertical)
                        .lineLimit(4...8)
                }
            }
            .navigationTitle("Edit Flashcard")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .topBarLeading) {
                    Button("Cancel") {
                        dismiss()
                    }
                }
                ToolbarItem(placement: .topBarTrailing) {
                    Button("Save") {
                        updateAlgorithm()
                    }
                    .disabled(title.isEmpty || category.isEmpty)
                }
            }
            .onAppear {
                title = algorithm.title
                category = algorithm.category
                definition = algorithm.definition
                timeComplexity = algorithm.timeComplexity
                pseudocode = algorithm.pseudocode
                difficulty = algorithm.difficulty
            }
        }
    }

    private func updateAlgorithm() {
        let updatedAlgorithm = Algorithm(
            id: algorithm.id,
            title: title,
            category: category,
            definition: definition,
            timeComplexity: timeComplexity,
            pseudocode: pseudocode,
            difficulty: difficulty
        )
        
        viewModel.update(algorithm: updatedAlgorithm)
        dismiss()
    }
}

#Preview {
    EditAlgorithmSheet(viewModel: AdminFlashcardViewModel(), algorithm: Algorithm(id: 1, title: "Binary Search", category: "Searching", definition: "Search in sorted array", timeComplexity: "O(log n)", pseudocode: "code", difficulty: "Easy"))
}
