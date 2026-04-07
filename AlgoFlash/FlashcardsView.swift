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
                        if currentIndex + 1 < cards.count {
                            FlashCard(algorithm: cards[currentIndex + 1], isFlipped: .constant(false))
                                .scaleEffect(0.95)
                                .offset(y: 10)
                        }

                        FlashCard(algorithm: cards[currentIndex], isFlipped: $isFlipped)
                            .offset(x: dragOffset)
                            .rotationEffect(.degrees(Double(dragOffset) / 20))
                            .gesture(
                                DragGesture()
                                    .onChanged { value in
                                        dragOffset = value.translation.width
                                    }
                                    .onEnded { value in
                                        handleSwipe(value.translation.width)
                                    }
                            )
                            .overlay(alignment: .topTrailing) {
                                Button {
                                    vm.toggleFavourite(cards[currentIndex])
                                } label: {
                                    Image(systemName: vm.isFavourite(cards[currentIndex]) ? "heart.fill" : "heart")
                                        .font(.title2)
                                        .foregroundColor(vm.isFavourite(cards[currentIndex]) ? .red : .gray)
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
        if width < -threshold {
            withAnimation(.spring(response: 0.3)) {
                if currentIndex < cards.count - 1 {
                    currentIndex += 1
                    isFlipped = false
                }
                dragOffset = 0
            }
        } else if width > threshold {
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
        ScrollView {
            VStack(alignment: .leading, spacing: 16) {
                Label(algorithm.timeComplexity, systemImage: "clock")
                    .font(.headline)
                    .foregroundColor(.blue)

                Divider()

                Text("Definition")
                    .font(.caption.weight(.semibold))
                    .foregroundColor(.secondary)
                Text(algorithm.definition)
                    .font(.subheadline)

                Divider()

                Text("Pseudocode")
                    .font(.caption.weight(.semibold))
                    .foregroundColor(.secondary)
                Text(algorithm.pseudocode)
                    .font(.system(.caption, design: .monospaced))
                    .padding(10)
                    .background(Color(.systemGray6))
                    .clipShape(RoundedRectangle(cornerRadius: 8))
            }
            .padding(24)
        }
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
