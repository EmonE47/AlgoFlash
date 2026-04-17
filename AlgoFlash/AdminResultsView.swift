import SwiftUI

struct AdminResultsView: View {
    @StateObject private var viewModel = AdminResultsViewModel()

    var body: some View {
        NavigationStack {
            ZStack {
                if viewModel.isLoading {
                    ProgressView()
                } else if viewModel.results.isEmpty {
                    VStack(spacing: 16) {
                        Image(systemName: "chart.bar")
                            .font(.system(size: 48))
                            .foregroundColor(.gray)
                        Text("No quiz results yet")
                            .font(.headline)
                        Text("Quiz results will appear here")
                            .font(.subheadline)
                            .foregroundColor(.gray)
                    }
                } else {
                    List {
                        ForEach(viewModel.results) { result in
                            VStack(alignment: .leading, spacing: 8) {
                                Text(result.userId)
                                    .font(.headline)
                                HStack {
                                    Text("Score: \(result.score)/\(result.total)")
                                        .font(.subheadline)
                                    Spacer()
                                    Text(formattedDate(result.date))
                                        .font(.caption)
                                        .foregroundColor(.gray)
                                }
                            }
                            .padding(.vertical, 4)
                        }
                    }
                }
            }
            .navigationTitle("Quiz Results")
            .navigationBarTitleDisplayMode(.inline)
        }
        .onAppear {
            viewModel.fetchAll()
        }
    }

    private func formattedDate(_ date: Date) -> String {
        let formatter = DateFormatter()
        formatter.dateStyle = .short
        formatter.timeStyle = .short
        return formatter.string(from: date)
    }
}

#Preview {
    AdminResultsView()
}
