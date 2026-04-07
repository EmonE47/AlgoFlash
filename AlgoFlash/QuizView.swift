import SwiftUI

struct QuizView: View {
    var body: some View {
        NavigationStack {
            VStack(spacing: 20) {
                Image(systemName: "questionmark.circle")
                    .font(.system(size: 70))
                    .foregroundColor(.blue.opacity(0.6))

                Text("Quiz Mode")
                    .font(.title.bold())

                Text("Coming Soon")
                    .font(.headline)
                    .foregroundColor(.secondary)

                Text("Test your algorithm knowledge with timed MCQ questions and track your score on the leaderboard.")
                    .font(.subheadline)
                    .foregroundColor(.secondary)
                    .multilineTextAlignment(.center)
                    .padding(.horizontal, 40)
            }
            .navigationTitle("Quiz")
        }
    }
}
