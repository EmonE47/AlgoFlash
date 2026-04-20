import SwiftUI

struct AddAlgorithmSheet: View {
    @Environment(\.dismiss) var dismiss
    @ObservedObject var viewModel: AdminFlashcardViewModel

    @State private var title: String = ""
    @State private var category: String = ""
    @State private var definition: String = ""
    @State private var timeComplexity: String = ""
    @State private var pseudocode: String = ""
    @State private var difficulty: String = "Medium"

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
            .scrollContentBackground(.hidden)
            .background(AppBackground())
            .tint(Color.warning)
            .navigationTitle("Add Flashcard")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .topBarLeading) {
                    Button("Cancel") {
                        dismiss()
                    }
                }
                ToolbarItem(placement: .topBarTrailing) {
                    Button("Save") {
                        saveAlgorithm()
                    }
                    .disabled(title.isEmpty || category.isEmpty)
                }
            }
        }
    }

    private func saveAlgorithm() {
        // Generate a new ID (in production, use server-generated IDs)
        let newId = (viewModel.algorithms.max { $0.id < $1.id }?.id ?? 0) + 1
        
        let algorithm = Algorithm(
            id: newId,
            title: title,
            category: category,
            definition: definition,
            timeComplexity: timeComplexity,
            pseudocode: pseudocode,
            difficulty: difficulty
        )
        
        viewModel.add(algorithm: algorithm)
        dismiss()
    }
}

#Preview {
    AddAlgorithmSheet(viewModel: AdminFlashcardViewModel())
}
