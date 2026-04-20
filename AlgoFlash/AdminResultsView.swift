import SwiftUI

struct AdminResultsView: View {
    @StateObject private var viewModel = AdminResultsViewModel()

    var body: some View {
        NavigationStack {
            ZStack {
                AppBackground()

                if viewModel.isLoading {
                    ProgressView("Loading results...")
                        .padding(18)
                        .background(.thinMaterial)
                        .clipShape(RoundedRectangle(cornerRadius: 18, style: .continuous))
                } else if viewModel.results.isEmpty {
                    EmptyStateView(
                        icon: "chart.bar.fill",
                        title: "No Quiz Results Yet",
                        subtitle: "Scores will appear after learners complete quizzes."
                    )
                } else {
                    List {
                        ForEach(viewModel.results) { result in
                            VStack(alignment: .leading, spacing: 8) {
                                HStack(alignment: .top) {
                                    VStack(alignment: .leading, spacing: 4) {
                                        Text(result.displayName)
                                            .font(.headline)
                                        if !result.userEmail.isEmpty && result.userEmail != result.displayName {
                                            Text(result.userEmail)
                                                .font(.caption)
                                                .foregroundStyle(.secondary)
                                        }
                                    }

                                    Spacer()

                                    Text("\(result.score)/\(result.total)")
                                        .font(.headline.weight(.bold))
                                        .foregroundStyle(scoreColor(result))
                                }

                                GeometryReader { proxy in
                                    ZStack(alignment: .leading) {
                                        Capsule()
                                            .fill(Color.surface1)
                                        Capsule()
                                            .fill(scoreColor(result))
                                            .frame(width: proxy.size.width * scoreRatio(result))
                                    }
                                }
                                .frame(height: 8)

                                HStack(spacing: 6) {
                                    Image(systemName: "calendar")
                                    Text(formattedDate(result.date))
                                }
                                .font(.caption)
                                .foregroundStyle(.secondary)
                            }
                            .padding(.vertical, 8)
                            .listRowBackground(Color.surface0)
                        }
                    }
                    .scrollContentBackground(.hidden)
                }
            }
            .navigationTitle("Quiz Results")
            .navigationBarTitleDisplayMode(.inline)
        }
        .onAppear {
            viewModel.fetchAll()
        }
    }

    private func scoreRatio(_ result: QuizResult) -> CGFloat {
        guard result.total > 0 else { return 0 }
        return CGFloat(result.score) / CGFloat(result.total)
    }

    private func scoreColor(_ result: QuizResult) -> Color {
        let ratio = scoreRatio(result)
        if ratio >= 0.75 { return Color.success }
        if ratio >= 0.5 { return Color.warning }
        return Color.danger
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
import SwiftUI

struct AdminResultsView: View {
    @StateObject private var viewModel = AdminResultsViewModel()

    var body: some View {
        NavigationStack {
            ZStack {
                AppBackground()

                if viewModel.isLoading {
                    ProgressView("Loading results...")
                        .padding(18)
                        .background(.thinMaterial)
                        .clipShape(RoundedRectangle(cornerRadius: 18, style: .continuous))
                } else if viewModel.results.isEmpty {
                    EmptyStateView(
                        icon: "chart.bar.fill",
                        title: "No Quiz Results Yet",
                        subtitle: "Scores will appear after learners complete quizzes."
                    )
                } else {
                    List {
                        ForEach(viewModel.results) { result in
                            VStack(alignment: .leading, spacing: 8) {
                                HStack(alignment: .top) {
                                    VStack(alignment: .leading, spacing: 4) {
                                        Text(result.displayName)
                                            .font(.headline)
                                        if !result.userEmail.isEmpty && result.userEmail != result.displayName {
                                            Text(result.userEmail)
                                                .font(.caption)
                                                .foregroundStyle(.secondary)
                                        }
                                    }

                                    Spacer()

                                    Text("\(result.score)/\(result.total)")
                                        .font(.headline.weight(.bold))
                                        .foregroundStyle(scoreColor(result))
                                }

                                GeometryReader { proxy in
                                    ZStack(alignment: .leading) {
                                        Capsule()
                                            .fill(Color.surface1)
                                        Capsule()
                                            .fill(scoreColor(result))
                                            .frame(width: proxy.size.width * scoreRatio(result))
                                    }
                                }
                                .frame(height: 8)

                                HStack(spacing: 6) {
                                    Image(systemName: "calendar")
                                    Text(formattedDate(result.date))
                                }
                                .font(.caption)
                                .foregroundStyle(.secondary)
                            }
                            .padding(.vertical, 8)
                            .listRowBackground(Color.surface0)
                        }
                    }
                    .scrollContentBackground(.hidden)
                }
            }
            .navigationTitle("Quiz Results")
            .navigationBarTitleDisplayMode(.inline)
        }
        .onAppear {
            viewModel.fetchAll()
        }
    }

    private func scoreRatio(_ result: QuizResult) -> CGFloat {
        guard result.total > 0 else { return 0 }
        return CGFloat(result.score) / CGFloat(result.total)
    }

    private func scoreColor(_ result: QuizResult) -> Color {
        let ratio = scoreRatio(result)
        if ratio >= 0.75 { return Color.success }
        if ratio >= 0.5 { return Color.warning }
        return Color.danger
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
import SwiftUI

struct AdminResultsView: View {
    @StateObject private var viewModel = AdminResultsViewModel()

    var body: some View {
        NavigationStack {
            ZStack {
                AppBackground()

                if viewModel.isLoading {
                    ProgressView("Loading results...")
                        .padding(18)
                        .background(.thinMaterial)
                        .clipShape(RoundedRectangle(cornerRadius: 18, style: .continuous))
                } else if viewModel.results.isEmpty {
                    EmptyStateView(
                        icon: "chart.bar.fill",
                        title: "No Quiz Results Yet",
                        subtitle: "Scores will appear after learners complete quizzes."
                    )
                } else {
                    List {
                        ForEach(viewModel.results) { result in
                            VStack(alignment: .leading, spacing: 8) {
                                HStack(alignment: .top) {
                                    VStack(alignment: .leading, spacing: 4) {
                                        Text(result.displayName)
                                            .font(.headline)
                                        if !result.userEmail.isEmpty && result.userEmail != result.displayName {
                                            Text(result.userEmail)
                                                .font(.caption)
                                                .foregroundStyle(.secondary)
                                        }
                                    }

                                    Spacer()

                                    Text("\(result.score)/\(result.total)")
                                        .font(.headline.weight(.bold))
                                        .foregroundStyle(scoreColor(result))
                                }

                                GeometryReader { proxy in
                                    ZStack(alignment: .leading) {
                                        Capsule()
                                            .fill(Color.surface1)
                                        Capsule()
                                            .fill(scoreColor(result))
                                            .frame(width: proxy.size.width * scoreRatio(result))
                                    }
                                }
                                .frame(height: 8)

                                HStack(spacing: 6) {
                                    Image(systemName: "calendar")
                                    Text(formattedDate(result.date))
                                }
                                .font(.caption)
                                .foregroundStyle(.secondary)
                            }
                            .padding(.vertical, 8)
                            .listRowBackground(Color.surface0)
                        }
                    }
                    .scrollContentBackground(.hidden)
                }
            }
            .navigationTitle("Quiz Results")
            .navigationBarTitleDisplayMode(.inline)
        }
        .onAppear {
            viewModel.fetchAll()
        }
    }

    private func scoreRatio(_ result: QuizResult) -> CGFloat {
        guard result.total > 0 else { return 0 }
        return CGFloat(result.score) / CGFloat(result.total)
    }

    private func scoreColor(_ result: QuizResult) -> Color {
        let ratio = scoreRatio(result)
        if ratio >= 0.75 { return Color.success }
        if ratio >= 0.5 { return Color.warning }
        return Color.danger
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
import SwiftUI

struct AdminResultsView: View {
    @StateObject private var viewModel = AdminResultsViewModel()

    var body: some View {
        NavigationStack {
            ZStack {
                AppBackground()

                if viewModel.isLoading {
                    ProgressView("Loading results...")
                        .padding(18)
                        .background(.thinMaterial)
                        .clipShape(RoundedRectangle(cornerRadius: 18, style: .continuous))
                } else if viewModel.results.isEmpty {
                    EmptyStateView(
                        icon: "chart.bar.fill",
                        title: "No Quiz Results Yet",
                        subtitle: "Scores will appear after learners complete quizzes."
                    )
                } else {
                    List {
                        ForEach(viewModel.results) { result in
                            VStack(alignment: .leading, spacing: 8) {
                                HStack(alignment: .top) {
                                    VStack(alignment: .leading, spacing: 4) {
                                        Text(result.displayName)
                                            .font(.headline)
                                        if !result.userEmail.isEmpty && result.userEmail != result.displayName {
                                            Text(result.userEmail)
                                                .font(.caption)
                                                .foregroundStyle(.secondary)
                                        }
                                    }

                                    Spacer()

                                    Text("\(result.score)/\(result.total)")
                                        .font(.headline.weight(.bold))
                                        .foregroundStyle(scoreColor(result))
                                }

                                GeometryReader { proxy in
                                    ZStack(alignment: .leading) {
                                        Capsule()
                                            .fill(Color.surface1)
                                        Capsule()
                                            .fill(scoreColor(result))
                                            .frame(width: proxy.size.width * scoreRatio(result))
                                    }
                                }
                                .frame(height: 8)

                                HStack(spacing: 6) {
                                    Image(systemName: "calendar")
                                    Text(formattedDate(result.date))
                                }
                                .font(.caption)
                                .foregroundStyle(.secondary)
                            }
                            .padding(.vertical, 8)
                            .listRowBackground(Color.surface0)
                        }
                    }
                    .scrollContentBackground(.hidden)
                }
            }
            .navigationTitle("Quiz Results")
            .navigationBarTitleDisplayMode(.inline)
        }
        .onAppear {
            viewModel.fetchAll()
        }
    }

    private func scoreRatio(_ result: QuizResult) -> CGFloat {
        guard result.total > 0 else { return 0 }
        return CGFloat(result.score) / CGFloat(result.total)
    }

    private func scoreColor(_ result: QuizResult) -> Color {
        let ratio = scoreRatio(result)
        if ratio >= 0.75 { return Color.success }
        if ratio >= 0.5 { return Color.warning }
        return Color.danger
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
