import SwiftUI

struct FavouritesView: View {
    @EnvironmentObject var vm: FlashcardViewModel
    @State private var currentIndex: Int = 0
    @State private var isFlipped = false

    private var cards: [Algorithm] { vm.favouriteAlgorithms }

    var body: some View {
        NavigationStack {
            ZStack {
                AppBackground()

                if cards.isEmpty {
                    EmptyStateView(
                        icon: "heart.slash.fill",
                        title: "Nothing Saved Yet",
                        subtitle: "Tap the heart on any flashcard to keep important algorithms here."
                    )
                } else {
                    VStack(spacing: 0) {
                        SectionHeader(
                            title: "\(cards.count) Saved Algorithms",
                            subtitle: "Review the cards you marked as important."
                        )
                        .padding(.horizontal, 20)
                        .padding(.top, 12)

                        Text("\(min(currentIndex + 1, cards.count)) of \(cards.count)")
                            .font(.caption.weight(.semibold))
                            .foregroundStyle(.secondary)
                            .padding(.horizontal, 14)
                            .padding(.vertical, 8)
                            .background(.thinMaterial)
                            .clipShape(Capsule())
                            .padding(.top, 12)

                        Spacer()

                        FlashCard(algorithm: cards[safeIndex], isFlipped: $isFlipped)
                            .padding(.horizontal, 24)
                            .overlay(alignment: .topTrailing) {
                                Button {
                                    HapticManager.impact(.medium)
                                    vm.toggleFavourite(cards[safeIndex])
                                    if currentIndex >= vm.favouriteAlgorithms.count {
                                        currentIndex = max(0, vm.favouriteAlgorithms.count - 1)
                                    }
                                    isFlipped = false
                                } label: {
                                    Image(systemName: "heart.fill")
                                        .font(.title2)
                                        .foregroundStyle(Color.danger)
                                        .frame(width: 52, height: 52)
                                        .background(.ultraThinMaterial)
                                        .clipShape(Circle())
                                        .padding(18)
                                }
                                .accessibilityLabel("Remove favourite")
                            }

                        Text("Tap card to flip")
                            .font(.caption)
                            .foregroundStyle(.secondary)
                            .padding(.top, 12)

                        Spacer()

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
                            .accessibilityLabel("Previous favourite")

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
                            .accessibilityLabel("Next favourite")
                        }
                        .padding(.bottom, 24)
                    }
                }
            }
            .navigationTitle("Favourites")
            .navigationBarTitleDisplayMode(.large)
        }
        .onChange(of: cards.count) { _ in
            if currentIndex >= cards.count {
                currentIndex = max(0, cards.count - 1)
            }
            isFlipped = false
        }
    }

    private var safeIndex: Int {
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
}
