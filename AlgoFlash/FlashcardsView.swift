import SwiftUI

struct FlashcardsView: View {
    @EnvironmentObject var vm: FlashcardViewModel
    @State private var currentIndex: Int = 0
    @State private var isFlipped = false
    @State private var dragOffset: CGFloat = 0

    private var cards: [Algorithm] { vm.filteredAlgorithms }

    var body: some View {
        NavigationStack {
            VStack(spacing: 0) {
                // Category filter
                categoryPicker

                if cards.isEmpty {
                    Spacer()
                    Text("No algorithms in this category.")
                        .foregroundColor(.secondary)
                    Spacer()
                } else {
                    // Card counter
                    Text("\(min(currentIndex + 1, cards.count)) / \(cards.count)")
                        .font(.caption)
                        .foregroundColor(.secondary)
                        .padding(.top, 8)

                    Spacer()

                    // Flashcard
                    ZStack {
                        // Shadow card behind
                        if safeCurrentIndex + 1 < cards.count {
                            FlashCard(algorithm: cards[safeCurrentIndex + 1], isFlipped: .constant(false))
                                .scaleEffect(0.95)
                                .offset(y: 10)
                        }

                        FlashCard(algorithm: cards[safeCurrentIndex], isFlipped: $isFlipped)
                            .offset(x: safeDragOffset)
                            .rotationEffect(.degrees(Double(safeDragOffset) / 20))
                            .gesture(
                                DragGesture()
                                    .onChanged { value in
                                        let width = value.translation.width
                                        dragOffset = width.isFinite ? width.clamped(to: -240...240) : 0
                                    }
                                    .onEnded { value in
                                        handleSwipe(value.translation.width)
                                    }
                            )
                            .overlay(alignment: .topTrailing) {
                                Button {
                                    vm.toggleFavourite(cards[safeCurrentIndex])
                                } label: {
                                    Image(systemName: vm.isFavourite(cards[safeCurrentIndex]) ? "heart.fill" : "heart")
                                        .font(.title2)
                                        .foregroundColor(vm.isFavourite(cards[safeCurrentIndex]) ? .red : .gray)
                                        .padding(20)
                                }
                            }
                    }
                    .padding(.horizontal, 24)

                    // Tap hint
                    Text("Tap card to flip • Swipe to navigate")
                        .font(.caption2)
                        .foregroundColor(.secondary)
                        .padding(.top, 12)

                    Spacer()

                    // Navigation arrows
                    HStack(spacing: 48) {
                        Button {
                            navigate(by: -1)
                        } label: {
                            Image(systemName: "arrow.left.circle.fill")
                                .font(.largeTitle)
                                .foregroundColor(currentIndex > 0 ? .blue : .gray.opacity(0.3))
                        }
                        .disabled(currentIndex == 0)

                        Button {
                            navigate(by: 1)
                        } label: {
                            Image(systemName: "arrow.right.circle.fill")
                                .font(.largeTitle)
                                .foregroundColor(currentIndex < cards.count - 1 ? .blue : .gray.opacity(0.3))
                        }
                        .disabled(currentIndex == cards.count - 1)
                    }
                    .padding(.bottom, 24)
                }
            }
            .navigationTitle("Flashcards")
            .onChange(of: vm.selectedCategory) { _ in
                currentIndex = 0
                isFlipped = false
                dragOffset = 0
            }
            .onChange(of: cards.count) { _ in
                if cards.isEmpty {
                    currentIndex = 0
                } else if currentIndex >= cards.count {
                    currentIndex = cards.count - 1
                }
                isFlipped = false
                dragOffset = 0
            }
        }
    }

    private var categoryPicker: some View {
        ScrollView(.horizontal, showsIndicators: false) {
            HStack(spacing: 10) {
                ForEach(vm.categories, id: \.self) { cat in
                    Button(cat) {
                        vm.selectedCategory = cat
                    }
                    .font(.subheadline.weight(.medium))
                    .padding(.horizontal, 14)
                    .padding(.vertical, 7)
                    .background(vm.selectedCategory == cat ? Color.blue : Color(.systemGray5))
                    .foregroundColor(vm.selectedCategory == cat ? .white : .primary)
                    .clipShape(Capsule())
                }
            }
            .padding(.horizontal, 16)
            .padding(.vertical, 10)
        }
    }

    private var safeDragOffset: CGFloat {
        dragOffset.isFinite ? dragOffset.clamped(to: -240...240) : 0
    }

    private var safeCurrentIndex: Int {
        guard !cards.isEmpty else { return 0 }
        return min(max(currentIndex, 0), cards.count - 1)
    }

    private func navigate(by delta: Int) {
        withAnimation(.spring(response: 0.3)) {
            let next = currentIndex + delta
            guard next >= 0, next < cards.count else { return }
            currentIndex = next
            isFlipped = false
        }
    }

    private func handleSwipe(_ width: CGFloat) {
        let threshold: CGFloat = 80
        let safeWidth = width.isFinite ? width : 0
        if safeWidth < -threshold {
            withAnimation(.spring(response: 0.3)) {
                if currentIndex < cards.count - 1 {
                    currentIndex += 1
                    isFlipped = false
                }
                dragOffset = 0
            }
        } else if safeWidth > threshold {
            withAnimation(.spring(response: 0.3)) {
                if currentIndex > 0 {
                    currentIndex -= 1
                    isFlipped = false
                }
                dragOffset = 0
            }
        } else {
            withAnimation(.spring(response: 0.3)) { dragOffset = 0 }
        }
    }
}

// MARK: - Flash Card

struct FlashCard: View {
    let algorithm: Algorithm
    @Binding var isFlipped: Bool

    var body: some View {
        ZStack {
            if !isFlipped {
                frontFace
            } else {
                backFace
            }
        }
        .frame(height: 340)
        .background(Color(.systemBackground))
        .clipShape(RoundedRectangle(cornerRadius: 20))
        .shadow(color: .black.opacity(0.12), radius: 12, x: 0, y: 6)
        .rotation3DEffect(
            .degrees(isFlipped ? 180 : 0),
            axis: (x: 0, y: 1, z: 0),
            perspective: 0.5
        )
        .onTapGesture {
            withAnimation(.spring(response: 0.4)) {
                isFlipped.toggle()
            }
        }
    }

    private var frontFace: some View {
        VStack(spacing: 16) {
            difficultyBadge

            Text(algorithm.title)
                .font(.title.bold())
                .multilineTextAlignment(.center)

            Text(algorithm.category)
                .font(.subheadline)
                .foregroundColor(.secondary)
                .padding(.horizontal, 12)
                .padding(.vertical, 5)
                .background(Color(.systemGray6))
                .clipShape(Capsule())

            Spacer()

            Text("Tap to see details")
                .font(.caption)
                .foregroundColor(.secondary)
        }
        .padding(24)
        .rotation3DEffect(.degrees(0), axis: (x: 0, y: 1, z: 0))
    }

    private var backFace: some View {
        VStack(alignment: .leading, spacing: 14) {
            Label(algorithm.timeComplexity, systemImage: "clock")
                .font(.headline)
                .foregroundColor(.blue)

            Divider()

            Text("Definition")
                .font(.caption.weight(.semibold))
                .foregroundColor(.secondary)
            Text(algorithm.definition)
                .font(.subheadline)
                .lineLimit(5)
                .minimumScaleFactor(0.85)

            Divider()

            Text("Pseudocode")
                .font(.caption.weight(.semibold))
                .foregroundColor(.secondary)
            Text(algorithm.pseudocode)
                .font(.system(size: 12, design: .monospaced))
                .lineLimit(9)
                .minimumScaleFactor(0.8)
                .padding(10)
                .frame(maxWidth: .infinity, alignment: .leading)
                .background(Color(.systemGray6))
                .clipShape(RoundedRectangle(cornerRadius: 8))

            Spacer(minLength: 0)
        }
        .padding(24)
        .frame(maxWidth: .infinity, maxHeight: .infinity, alignment: .topLeading)
        .rotation3DEffect(.degrees(180), axis: (x: 0, y: 1, z: 0))
    }

    private var difficultyBadge: some View {
        Text(algorithm.difficulty)
            .font(.caption.weight(.semibold))
            .padding(.horizontal, 12)
            .padding(.vertical, 5)
            .background(difficultyColor.opacity(0.15))
            .foregroundColor(difficultyColor)
            .clipShape(Capsule())
            .frame(maxWidth: .infinity, alignment: .trailing)
    }

    private var difficultyColor: Color {
        switch algorithm.difficulty {
        case "Easy": return .green
        case "Medium": return .orange
        case "Hard": return .red
        default: return .gray
        }
    }
}

private extension Comparable {
    func clamped(to range: ClosedRange<Self>) -> Self {
        min(max(self, range.lowerBound), range.upperBound)
    }
}
