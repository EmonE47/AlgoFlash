import SwiftUI

struct FavouritesView: View {
    @EnvironmentObject var vm: FlashcardViewModel
    @State private var currentIndex: Int = 0
    @State private var isFlipped = false

    private var cards: [Algorithm] { vm.favouriteAlgorithms }

    var body: some View {
        NavigationStack {
            if cards.isEmpty {
                VStack(spacing: 16) {
                    Image(systemName: "heart.slash")
                        .font(.system(size: 60))
                        .foregroundColor(.gray.opacity(0.4))
                    Text("No Favourites Yet")
                        .font(.title2.bold())
                    Text("Tap the heart icon on any flashcard to save it here.")
                        .font(.subheadline)
                        .foregroundColor(.secondary)
                        .multilineTextAlignment(.center)
                        .padding(.horizontal, 40)
                }
                .navigationTitle("Favourites")
            } else {
                VStack(spacing: 0) {
                    Text("\(min(currentIndex + 1, cards.count)) / \(cards.count)")
                        .font(.caption)
                        .foregroundColor(.secondary)
                        .padding(.top, 12)

                    Spacer()

                    FlashCard(algorithm: cards[currentIndex], isFlipped: $isFlipped)
                        .padding(.horizontal, 24)
                        .overlay(alignment: .topTrailing) {
                            Button {
                                vm.toggleFavourite(cards[currentIndex])
                                // Card removed — adjust index
                                if currentIndex >= vm.favouriteAlgorithms.count {
                                    currentIndex = max(0, vm.favouriteAlgorithms.count - 1)
                                }
                                isFlipped = false
                            } label: {
                                Image(systemName: "heart.fill")
                                    .font(.title2)
                                    .foregroundColor(.red)
                                    .padding(44)
                            }
                        }

                    Text("Tap card to flip")
                        .font(.caption2)
                        .foregroundColor(.secondary)
                        .padding(.top, 12)

                    Spacer()

                    HStack(spacing: 48) {
                        Button {
                            withAnimation(.spring(response: 0.3)) {
                                if currentIndex > 0 { currentIndex -= 1; isFlipped = false }
                            }
                        } label: {
                            Image(systemName: "arrow.left.circle.fill")
                                .font(.largeTitle)
                                .foregroundColor(currentIndex > 0 ? .blue : .gray.opacity(0.3))
                        }
                        .disabled(currentIndex == 0)

                        Button {
                            withAnimation(.spring(response: 0.3)) {
                                if currentIndex < cards.count - 1 { currentIndex += 1; isFlipped = false }
                            }
                        } label: {
                            Image(systemName: "arrow.right.circle.fill")
                                .font(.largeTitle)
                                .foregroundColor(currentIndex < cards.count - 1 ? .blue : .gray.opacity(0.3))
                        }
                        .disabled(currentIndex == cards.count - 1)
                    }
                    .padding(.bottom, 24)
                }
                .navigationTitle("Favourites")
            }
        }
        .onChange(of: cards.count) { _ in
            if currentIndex >= cards.count {
                currentIndex = max(0, cards.count - 1)
            }
        }
    }
}
