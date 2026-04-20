import SwiftUI

struct FlashcardsView: View {
    @EnvironmentObject var vm: FlashcardViewModel
    @State private var currentIndex: Int = 0
    @State private var isFlipped = false
    @State private var dragOffset: CGFloat = 0

    private var cards: [Algorithm] { vm.filteredAlgorithms }

    var body: some View {
        NavigationStack {
            ZStack {
                AppBackground()

                VStack(spacing: 0) {
                    categoryPicker

                    if cards.isEmpty {
                        EmptyStateView(
                            icon: "square.stack.3d.up.slash",
                            title: "No Algorithms",
                            subtitle: "Try another category or ask an admin to add flashcards."
                        )
                    } else {
                        progressLozenge
                            .padding(.top, 8)

                        Spacer()

                        ZStack {
                            if safeCurrentIndex + 1 < cards.count {
                                FlashCard(algorithm: cards[safeCurrentIndex + 1], isFlipped: .constant(false))
                                    .scaleEffect(0.94)
                                    .offset(y: 16)
                                    .opacity(0.42)
                                    .allowsHitTesting(false)
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
                                        HapticManager.impact(.medium)
                                        vm.toggleFavourite(cards[safeCurrentIndex])
                                    } label: {
                                        Image(systemName: vm.isFavourite(cards[safeCurrentIndex]) ? "heart.fill" : "heart")
                                            .font(.title2)
                                            .foregroundStyle(vm.isFavourite(cards[safeCurrentIndex]) ? Color.danger : Color.white.opacity(0.82))
                                            .frame(width: 52, height: 52)
                                            .background(.ultraThinMaterial)
                                            .clipShape(Circle())
                                            .padding(18)
                                    }
                                    .accessibilityLabel(vm.isFavourite(cards[safeCurrentIndex]) ? "Remove favourite" : "Add favourite")
                                }
                        }
                        .padding(.horizontal, 24)

                        Text("Tap to flip. Swipe to navigate.")
                            .font(.caption)
                            .foregroundStyle(.secondary)
                            .padding(.top, 12)

                        Spacer()

                        navigationControls
                            .padding(.bottom, 24)
                    }
                }
            }
            .navigationTitle("Flashcards")
            .navigationBarTitleDisplayMode(.large)
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
                ForEach(vm.categories, id: \.self) { category in
                    CategoryPill(title: category, isSelected: vm.selectedCategory == category) {
                        vm.selectedCategory = category
                    }
                }
            }
            .padding(.horizontal, 16)
            .padding(.vertical, 12)
        }
    }

    private var progressLozenge: some View {
        HStack(spacing: 10) {
            Text("\(min(currentIndex + 1, cards.count)) of \(cards.count)")
                .font(.caption.weight(.semibold))
                .foregroundStyle(.secondary)

            HStack(spacing: 6) {
                ForEach(0..<min(cards.count, 7), id: \.self) { index in
                    Capsule()
                        .fill(index == min(currentIndex, 6) ? Color.brand : Color.secondary.opacity(0.25))
                        .frame(width: index == min(currentIndex, 6) ? 20 : 6, height: 6)
                        .animation(Motion.spring, value: currentIndex)
                }

                if cards.count > 7 {
                    Text("...")
                        .font(.caption2)
                        .foregroundStyle(.secondary)
                }
            }
        }
        .padding(.horizontal, 14)
        .padding(.vertical, 8)
        .background(.thinMaterial)
        .clipShape(Capsule())
    }

    private var navigationControls: some View {
        HStack(spacing: 56) {
            Button {
                navigate(by: -1)
            } label: {
                Image(systemName: "chevron.left")
                    .font(.title2.weight(.bold))
                    .foregroundStyle(currentIndex > 0 ? Color.brand : Color.secondary.opacity(0.45))
                    .frame(width: 56, height: 56)
                    .background(.ultraThinMaterial)
                    .clipShape(Circle())
            }
            .disabled(currentIndex == 0)
            .accessibilityLabel("Previous flashcard")

            Button {
                navigate(by: 1)
            } label: {
                Image(systemName: "chevron.right")
                    .font(.title2.weight(.bold))
                    .foregroundStyle(currentIndex < cards.count - 1 ? Color.brand : Color.secondary.opacity(0.45))
                    .frame(width: 56, height: 56)
                    .background(.ultraThinMaterial)
                    .clipShape(Circle())
            }
            .disabled(currentIndex == cards.count - 1)
            .accessibilityLabel("Next flashcard")
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
        HapticManager.impact()
        withAnimation(Motion.spring) {
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
            HapticManager.impact()
            withAnimation(Motion.spring) {
                if currentIndex < cards.count - 1 {
                    currentIndex += 1
                    isFlipped = false
                }
                dragOffset = 0
            }
        } else if safeWidth > threshold {
            HapticManager.impact()
            withAnimation(Motion.spring) {
                if currentIndex > 0 {
                    currentIndex -= 1
                    isFlipped = false
                }
                dragOffset = 0
            }
        } else {
            withAnimation(Motion.spring) { dragOffset = 0 }
        }
    }
}

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
        .frame(height: 360)
        .clipShape(RoundedRectangle(cornerRadius: 24, style: .continuous))
        .shadow(color: categoryGradient(algorithm.category).0.opacity(0.24), radius: 26, x: 0, y: 14)
        .rotation3DEffect(
            .degrees(isFlipped ? 180 : 0),
            axis: (x: 0, y: 1, z: 0),
            perspective: 0.5
        )
        .onTapGesture {
            HapticManager.impact(.medium)
            withAnimation(Motion.flip) {
                isFlipped.toggle()
            }
        }
    }

    private var frontFace: some View {
        let gradient = categoryGradient(algorithm.category)

        return ZStack {
            LinearGradient(colors: [gradient.0, gradient.1], startPoint: .topLeading, endPoint: .bottomTrailing)

            VStack(spacing: 18) {
                HStack {
                    Text(algorithm.difficulty)
                        .font(.caption.weight(.bold))
                        .padding(.horizontal, 12)
                        .padding(.vertical, 6)
                        .background(difficultyColor(algorithm.difficulty).opacity(0.28))
                        .foregroundStyle(.white)
                        .clipShape(Capsule())
                    Spacer()
                }

                Spacer()

                Text(algorithm.title)
                    .font(.title.bold())
                    .foregroundStyle(.white)
                    .multilineTextAlignment(.center)
                    .minimumScaleFactor(0.78)

                Text(algorithm.category)
                    .font(.subheadline.weight(.semibold))
                    .foregroundStyle(.white.opacity(0.9))
                    .padding(.horizontal, 14)
                    .padding(.vertical, 7)
                    .background(.white.opacity(0.18))
                    .clipShape(Capsule())

                Spacer()

                Text("Tap to flip")
                    .font(.caption.weight(.medium))
                    .foregroundStyle(.white.opacity(0.70))
            }
            .padding(26)
        }
        .rotation3DEffect(.degrees(0), axis: (x: 0, y: 1, z: 0))
    }

    private var backFace: some View {
        let gradient = categoryGradient(algorithm.category)

        return ZStack {
            LinearGradient(colors: [gradient.0, gradient.1], startPoint: .topLeading, endPoint: .bottomTrailing)

            VStack(alignment: .leading, spacing: 14) {
                Label(algorithm.timeComplexity, systemImage: "clock.fill")
                    .font(.headline)
                    .foregroundStyle(.white)

                Divider()
                    .overlay(Color.white.opacity(0.3))

                DetailBlock(title: "Definition") {
                    Text(algorithm.definition)
                        .font(.subheadline)
                        .foregroundStyle(.white.opacity(0.92))
                        .lineLimit(5)
                        .minimumScaleFactor(0.85)
                }

                DetailBlock(title: "Pseudocode") {
                    Text(algorithm.pseudocode)
                        .font(.system(size: 12, design: .monospaced))
                        .foregroundStyle(.white)
                        .lineLimit(9)
                        .minimumScaleFactor(0.8)
                        .padding(10)
                        .frame(maxWidth: .infinity, alignment: .leading)
                        .background(Color.black.opacity(0.28))
                        .clipShape(RoundedRectangle(cornerRadius: 10, style: .continuous))
                }

                Spacer(minLength: 0)
            }
            .padding(24)
            .frame(maxWidth: .infinity, maxHeight: .infinity, alignment: .topLeading)
            .background(.ultraThinMaterial)
        }
        .rotation3DEffect(.degrees(180), axis: (x: 0, y: 1, z: 0))
    }
}

private struct DetailBlock<Content: View>: View {
    let title: String
    let content: () -> Content

    init(title: String, @ViewBuilder content: @escaping () -> Content) {
        self.title = title
        self.content = content
    }

    var body: some View {
        VStack(alignment: .leading, spacing: 6) {
            Text(title.uppercased())
                .font(.caption.weight(.bold))
                .foregroundStyle(.white.opacity(0.65))
            content()
        }
    }
}

private extension Comparable {
    func clamped(to range: ClosedRange<Self>) -> Self {
        min(max(self, range.lowerBound), range.upperBound)
    }
}
