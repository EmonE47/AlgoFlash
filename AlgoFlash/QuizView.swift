import SwiftUI

struct QuizView: View {
    @StateObject private var viewModel = QuizViewModel()
    @State private var showingStartButton = true

    var body: some View {
        NavigationStack {
            ZStack {
                AppBackground()

                if viewModel.isLoading {
                    ProgressView("Loading quiz...")
                        .padding(18)
                        .background(.thinMaterial)
                        .clipShape(RoundedRectangle(cornerRadius: 18, style: .continuous))
                } else if showingStartButton {
                    QuizStartView(timePerQuestion: viewModel.timePerQuestion) {
                        HapticManager.impact()
                        showingStartButton = false
                        viewModel.loadQuestions()
                    }
                } else if viewModel.isFinished {
                    QuizResultView(viewModel: viewModel, onRetry: {
                        HapticManager.impact()
                        showingStartButton = true
                        viewModel.score = 0
                    })
                } else if viewModel.questions.isEmpty {
                    EmptyStateView(
                        icon: "questionmark.circle",
                        title: "No Quiz Questions",
                        subtitle: "Ask an admin to add quiz questions in the Manage Quiz tab."
                    )
                } else if let currentQuestion = viewModel.currentQuestion {
                    QuizQuestionView(viewModel: viewModel, question: currentQuestion)
                } else {
                    ProgressView()
                }
            }
            .navigationTitle("Quiz")
            .navigationBarTitleDisplayMode(.inline)
        }
    }
}

private struct QuizStartView: View {
    let timePerQuestion: Int
    let start: () -> Void

    var body: some View {
        ZStack {
            BrandGradient(colors: [Color.brandDark, Color.brand, Color.brandLight])
                .ignoresSafeArea()

            VStack(spacing: 30) {
                Spacer()

                Image(systemName: "brain.head.profile")
                    .font(.system(size: 88))
                    .foregroundStyle(.white)
                    .symbolEffect(.pulse)
                    .accessibilityHidden(true)

                VStack(spacing: 10) {
                    Text("Quiz Mode")
                        .font(.largeTitle.bold())
                        .foregroundStyle(.white)

                    Text("Test your algorithm knowledge under time pressure.")
                        .font(.headline)
                        .foregroundStyle(.white.opacity(0.78))
                        .multilineTextAlignment(.center)
                        .padding(.horizontal, 28)
                }

                HStack(spacing: 10) {
                    MetricPill(title: "All Questions", icon: "list.bullet")
                    MetricPill(title: "\(timePerQuestion)s Each", icon: "timer")
                    MetricPill(title: "Scored", icon: "checkmark.seal")
                }

                Spacer()

                AlgoButton(title: "Start Quiz", icon: "play.fill", action: start)
                    .padding(.horizontal, 34)
                    .padding(.bottom, 28)
            }
            .padding(24)
        }
    }
}

struct QuizQuestionView: View {
    @ObservedObject var viewModel: QuizViewModel
    let question: QuizQuestion

    var body: some View {
        VStack(spacing: 18) {
            header

            ProgressView(value: Double(viewModel.currentIndex + 1) / Double(viewModel.questions.count))
                .tint(Color.brand)
                .scaleEffect(x: 1, y: 1.8, anchor: .center)
                .clipShape(Capsule())

            VStack(alignment: .leading, spacing: 18) {
                Text(question.question)
                    .font(.title3.weight(.semibold))
                    .lineLimit(4)
                    .minimumScaleFactor(0.86)

                VStack(spacing: 12) {
                    ForEach(0..<question.options.count, id: \.self) { index in
                        OptionButton(
                            letter: optionLetter(for: index),
                            text: question.options[index],
                            isSelected: viewModel.selectedOption == index,
                            isCorrect: index == question.correctIndex && viewModel.isAnswered,
                            isWrong: viewModel.selectedOption == index && index != question.correctIndex && viewModel.isAnswered,
                            isDisabled: viewModel.isAnswered
                        ) {
                            HapticManager.impact()
                            viewModel.selectOption(index)
                            HapticManager.notification(index == question.correctIndex ? .success : .error)
                        }
                    }
                }
            }
            .padding(20)
            .background(Color.surface0)
            .clipShape(RoundedRectangle(cornerRadius: 20, style: .continuous))
            .shadow(color: .black.opacity(0.08), radius: 16, x: 0, y: 8)

            Spacer()

            if viewModel.isAnswered {
                explanationCard

                AlgoButton(
                    title: viewModel.currentIndex + 1 == viewModel.questions.count ? "Finish" : "Next",
                    icon: viewModel.currentIndex + 1 == viewModel.questions.count ? "flag.checkered" : "arrow.right"
                ) {
                    HapticManager.impact()
                    viewModel.nextQuestion()
                }
            }
        }
        .padding(18)
    }

    private var header: some View {
        HStack {
            Text("Question \(viewModel.currentIndex + 1) of \(viewModel.questions.count)")
                .font(.caption.weight(.bold))
                .foregroundStyle(.white)
                .padding(.horizontal, 12)
                .padding(.vertical, 8)
                .background(Color.brand)
                .clipShape(Capsule())

            Spacer()

            TimerRing(timeRemaining: viewModel.timeRemaining, totalTime: viewModel.timePerQuestion)
        }
    }

    private var explanationCard: some View {
        HStack(alignment: .top, spacing: 12) {
            Rectangle()
                .fill(viewModel.selectedOption == question.correctIndex ? Color.success : Color.danger)
                .frame(width: 4)
                .clipShape(Capsule())

            VStack(alignment: .leading, spacing: 8) {
                Text(viewModel.selectedOption == question.correctIndex ? "Correct" : "Incorrect")
                    .font(.headline)
                    .foregroundStyle(viewModel.selectedOption == question.correctIndex ? Color.success : Color.danger)

                Text(question.explanation)
                    .font(.subheadline)
                    .foregroundStyle(.secondary)
            }
            Spacer(minLength: 0)
        }
        .padding(14)
        .background(Color.surface0)
        .clipShape(RoundedRectangle(cornerRadius: 14, style: .continuous))
        .shadow(color: .black.opacity(0.06), radius: 10, x: 0, y: 4)
    }

    private func optionLetter(for index: Int) -> String {
        guard let scalar = UnicodeScalar(65 + index) else { return "\(index + 1)" }
        return String(Character(scalar))
    }
}

private struct TimerRing: View {
    let timeRemaining: Int
    let totalTime: Int

    var body: some View {
        ZStack {
            Circle()
                .stroke(Color.secondary.opacity(0.18), lineWidth: 4)
            Circle()
                .trim(from: 0, to: CGFloat(max(timeRemaining, 0)) / CGFloat(max(totalTime, 1)))
                .stroke(
                    timeRemaining < 10 ? Color.danger : Color.success,
                    style: StrokeStyle(lineWidth: 4, lineCap: .round)
                )
                .rotationEffect(.degrees(-90))
                .animation(Motion.easeOut, value: timeRemaining)
            Text("\(max(timeRemaining, 0))")
                .font(.caption.weight(.bold))
                .foregroundStyle(timeRemaining < 10 ? Color.danger : Color.primary)
        }
        .frame(width: 46, height: 46)
        .accessibilityLabel("\(max(timeRemaining, 0)) seconds remaining")
    }
}

struct OptionButton: View {
    let letter: String
    let text: String
    let isSelected: Bool
    let isCorrect: Bool
    let isWrong: Bool
    let isDisabled: Bool
    let action: () -> Void

    var body: some View {
        Button(action: action) {
            HStack(spacing: 12) {
                Text(letter)
                    .font(.headline.weight(.bold))
                    .foregroundStyle(letterForeground)
                    .frame(width: 34, height: 34)
                    .background(letterBackground)
                    .clipShape(Circle())

                Text(text)
                    .font(.body)
                    .lineLimit(3)
                    .multilineTextAlignment(.leading)

                Spacer(minLength: 8)

                if isCorrect {
                    Image(systemName: "checkmark.circle.fill")
                        .foregroundStyle(Color.success)
                } else if isWrong {
                    Image(systemName: "xmark.circle.fill")
                        .foregroundStyle(Color.danger)
                }
            }
            .padding(14)
            .frame(maxWidth: .infinity, alignment: .leading)
            .background(optionBackground)
            .foregroundStyle(.primary)
            .clipShape(RoundedRectangle(cornerRadius: 14, style: .continuous))
            .overlay(
                RoundedRectangle(cornerRadius: 14, style: .continuous)
                    .stroke(borderColor, lineWidth: isSelected || isCorrect || isWrong ? 2 : 1)
            )
        }
        .buttonStyle(ScaleButtonStyle())
        .disabled(isDisabled)
        .animation(Motion.springFast, value: isSelected)
        .animation(Motion.springFast, value: isCorrect)
        .animation(Motion.springFast, value: isWrong)
    }

    private var optionBackground: Color {
        if isCorrect { return Color.success.opacity(0.10) }
        if isWrong { return Color.danger.opacity(0.10) }
        if isSelected { return Color.brand.opacity(0.10) }
        return Color.surface1
    }

    private var borderColor: Color {
        if isCorrect { return Color.success }
        if isWrong { return Color.danger }
        if isSelected { return Color.brand }
        return Color.secondary.opacity(0.08)
    }

    private var letterBackground: Color {
        if isCorrect { return Color.success.opacity(0.18) }
        if isWrong { return Color.danger.opacity(0.18) }
        return Color.brand.opacity(0.12)
    }

    private var letterForeground: Color {
        if isCorrect { return Color.success }
        if isWrong { return Color.danger }
        return Color.brand
    }
}

struct QuizResultView: View {
    @ObservedObject var viewModel: QuizViewModel
    let onRetry: () -> Void
    @State private var animatedProgress = 0.0

    var scorePercentage: Int {
        guard viewModel.questions.count > 0 else { return 0 }
        return (viewModel.score * 100) / viewModel.questions.count
    }

    var body: some View {
        VStack(spacing: 0) {
            ZStack {
                BrandGradient(colors: [Color.brandDark, Color.brand, Color.brandLight])
                    .ignoresSafeArea(edges: .top)

                VStack(spacing: 18) {
                    ZStack {
                        Circle()
                            .stroke(Color.white.opacity(0.18), lineWidth: 14)
                        Circle()
                            .trim(from: 0, to: animatedProgress)
                            .stroke(
                                AngularGradient(colors: [Color.white, Color.brandLight, Color.white], center: .center),
                                style: StrokeStyle(lineWidth: 14, lineCap: .round)
                            )
                            .rotationEffect(.degrees(-90))

                        VStack(spacing: 4) {
                            Text("\(viewModel.score)")
                                .font(.system(size: 48, weight: .bold))
                            Text("/ \(viewModel.questions.count)")
                                .font(.headline)
                        }
                        .foregroundStyle(.white)
                    }
                    .frame(width: 170, height: 170)

                    VStack(spacing: 6) {
                        Text(performanceLabel)
                            .font(.title.bold())
                            .foregroundStyle(.white)
                        Text("\(scorePercentage)%")
                            .font(.headline)
                            .foregroundStyle(.white.opacity(0.78))
                    }
                }
                .padding(.top, 34)
                .padding(.bottom, 34)
            }
            .frame(maxHeight: 320)

            VStack(spacing: 20) {
                HStack(spacing: 12) {
                    ResultStat(title: "Correct", value: "\(viewModel.score)", color: Color.success)
                    ResultStat(title: "Wrong", value: "\(max(viewModel.questions.count - viewModel.score, 0))", color: Color.danger)
                    ResultStat(title: "Total", value: "\(viewModel.questions.count)", color: Color.brand)
                }

                GeometryReader { proxy in
                    ZStack(alignment: .leading) {
                        Capsule()
                            .fill(Color.surface1)
                        Capsule()
                            .fill(LinearGradient(colors: [Color.brand, Color.brandLight], startPoint: .leading, endPoint: .trailing))
                            .frame(width: proxy.size.width * animatedProgress)
                    }
                }
                .frame(height: 10)

                AlgoButton(title: "Retake Quiz", icon: "arrow.clockwise", action: onRetry)
            }
            .padding(24)
            .frame(maxWidth: .infinity, maxHeight: .infinity, alignment: .top)
            .background(Color.surface0)
        }
        .onAppear {
            animatedProgress = 0
            withAnimation(.easeOut(duration: 1.1).delay(0.2)) {
                animatedProgress = Double(scorePercentage) / 100.0
            }
        }
    }

    private var performanceLabel: String {
        if scorePercentage >= 80 { return "Excellent" }
        if scorePercentage >= 60 { return "Good Work" }
        return "Keep Practicing"
    }
}

private struct ResultStat: View {
    let title: String
    let value: String
    let color: Color

    var body: some View {
        VStack(spacing: 8) {
            Rectangle()
                .fill(color)
                .frame(height: 3)
                .clipShape(Capsule())
            Text(value)
                .font(.title2.bold())
            Text(title)
                .font(.caption)
                .foregroundStyle(.secondary)
        }
        .frame(maxWidth: .infinity)
        .padding(14)
        .background(Color.surface1)
        .clipShape(RoundedRectangle(cornerRadius: 14, style: .continuous))
    }
}
