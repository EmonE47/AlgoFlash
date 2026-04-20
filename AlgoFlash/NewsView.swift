import SwiftUI
import Combine

struct NewsAPIResponse: Decodable {
    let status: String
    let totalResults: Int
    let articles: [NewsArticle]
}

struct NewsSource: Decodable, Equatable {
    let id: String?
    let name: String
}

struct NewsArticle: Decodable, Identifiable, Equatable {
    let source: NewsSource
    let author: String?
    let title: String
    let description: String?
    let url: String
    let urlToImage: String?
    let publishedAt: String
    let content: String?

    var id: String { url }

    var imageURL: URL? {
        guard let urlToImage else { return nil }
        return URL(string: urlToImage)
    }

    var articleURL: URL? {
        URL(string: url)
    }

    var formattedDate: String {
        NewsDateFormatter.formattedDate(from: publishedAt)
    }

    var cleanContent: String {
        let text = content ?? description ?? "No preview content is available for this article."
        guard let range = text.range(of: #" \[\+\d+ chars\]"#, options: .regularExpression) else {
            return text
        }
        return String(text[..<range.lowerBound])
    }
}

enum NewsServiceError: LocalizedError {
    case invalidURL
    case emptyResponse
    case apiFailure

    var errorDescription: String? {
        switch self {
        case .invalidURL:
            return "The news URL is invalid."
        case .emptyResponse:
            return "No news data was returned."
        case .apiFailure:
            return "News could not be loaded right now."
        }
    }
}

class NewsService {
    static let shared = NewsService()

    private let endpoint = "https://newsapi.org/v2/everything?q=apple&from=2026-04-19&to=2026-04-19&sortBy=popularity&apiKey=30c6f20921d248e7a901752b756c1313"

    private init() {}

    func fetchNews(completion: @escaping (Result<[NewsArticle], Error>) -> Void) {
        guard let url = URL(string: endpoint) else {
            completion(.failure(NewsServiceError.invalidURL))
            return
        }

        URLSession.shared.dataTask(with: url) { data, _, error in
            if let error {
                completion(.failure(error))
                return
            }

            guard let data else {
                completion(.failure(NewsServiceError.emptyResponse))
                return
            }

            do {
                let response = try JSONDecoder().decode(NewsAPIResponse.self, from: data)
                guard response.status == "ok" else {
                    completion(.failure(NewsServiceError.apiFailure))
                    return
                }
                completion(.success(response.articles))
            } catch {
                completion(.failure(error))
            }
        }
        .resume()
    }
}

@MainActor
class NewsViewModel: ObservableObject {
    @Published var articles: [NewsArticle] = []
    @Published var isLoading = false
    @Published var errorMessage = ""

    func loadNews() {
        isLoading = true
        errorMessage = ""

        NewsService.shared.fetchNews { [weak self] result in
            Task { @MainActor in
                guard let self else { return }
                self.isLoading = false

                switch result {
                case .success(let articles):
                    self.articles = articles.filter { !$0.title.isEmpty && !$0.url.isEmpty }
                    if self.articles.isEmpty {
                        self.errorMessage = "No articles found."
                    }
                case .failure(let error):
                    self.errorMessage = error.localizedDescription
                }
            }
        }
    }
}

struct NewsView: View {
    @StateObject private var viewModel = NewsViewModel()

    var body: some View {
        NavigationStack {
            ZStack {
                newsBackground

                if viewModel.isLoading && viewModel.articles.isEmpty {
                    ProgressView("Loading news...")
                        .padding()
                        .background(.thinMaterial)
                        .clipShape(RoundedRectangle(cornerRadius: 16))
                } else if !viewModel.errorMessage.isEmpty && viewModel.articles.isEmpty {
                    NewsErrorView(message: viewModel.errorMessage) {
                        viewModel.loadNews()
                    }
                    .padding(20)
                } else {
                    ScrollView {
                        LazyVStack(spacing: 18) {
                            header

                            if let featured = viewModel.articles.first {
                                NavigationLink {
                                    NewsDetailView(article: featured)
                                } label: {
                                    FeaturedNewsCard(article: featured)
                                }
                                .buttonStyle(.plain)
                            }

                            ForEach(Array(viewModel.articles.dropFirst()), id: \.id) { article in
                                NavigationLink {
                                    NewsDetailView(article: article)
                                } label: {
                                    NewsCard(article: article)
                                }
                                .buttonStyle(.plain)
                            }
                        }
                        .padding(.horizontal, 16)
                        .padding(.vertical, 18)
                    }
                    .refreshable {
                        viewModel.loadNews()
                    }
                }
            }
            .navigationTitle("News")
            .navigationBarTitleDisplayMode(.inline)
            .onAppear {
                if viewModel.articles.isEmpty {
                    viewModel.loadNews()
                }
            }
        }
    }

    private var header: some View {
        VStack(alignment: .leading, spacing: 8) {
            Text("Tech News")
                .font(.largeTitle.bold())
            Text("Powered by NewsAPI")
                .font(.caption.weight(.semibold))
                .foregroundColor(Color.brand)
            Text("Popular technology stories for quick reading.")
                .font(.subheadline)
                .foregroundColor(.secondary)
        }
        .frame(maxWidth: .infinity, alignment: .leading)
        .padding(.bottom, 4)
    }

    private var newsBackground: some View {
        LinearGradient(
            colors: [
                Color.brand.opacity(0.12),
                Color(.systemBackground),
                Color.warning.opacity(0.08)
            ],
            startPoint: .topLeading,
            endPoint: .bottomTrailing
        )
        .ignoresSafeArea()
    }
}

struct FeaturedNewsCard: View {
    let article: NewsArticle

    var body: some View {
        VStack(alignment: .leading, spacing: 0) {
            ZStack(alignment: .bottomLeading) {
                AsyncImage(url: article.imageURL) { phase in
                    switch phase {
                    case .empty:
                        Rectangle()
                            .fill(Color.brand.opacity(0.12))
                            .overlay(ProgressView())
                    case .success(let image):
                        image
                            .resizable()
                            .scaledToFill()
                    case .failure:
                        NewsImageFallback()
                    @unknown default:
                        NewsImageFallback()
                    }
                }
                .frame(height: 240)
                .clipped()

                LinearGradient(
                    colors: [.black.opacity(0.02), .black.opacity(0.58)],
                    startPoint: .top,
                    endPoint: .bottom
                )

                HStack(spacing: 8) {
                    Text(article.source.name)
                        .font(.caption.weight(.semibold))
                        .padding(.horizontal, 10)
                        .padding(.vertical, 6)
                        .background(.ultraThinMaterial)
                        .clipShape(Capsule())

                    Text(article.formattedDate)
                        .font(.caption.weight(.medium))
                        .foregroundColor(.white.opacity(0.9))
                }
                .padding(14)
            }

            VStack(alignment: .leading, spacing: 10) {
                Text(article.title)
                    .font(.title3.weight(.bold))
                    .foregroundColor(.primary)
                    .lineLimit(3)

                if let description = article.description, !description.isEmpty {
                    Text(description)
                        .font(.subheadline)
                        .foregroundColor(.secondary)
                        .lineLimit(3)
                }

                HStack {
                    if let author = article.author, !author.isEmpty {
                        Label(author, systemImage: "person.crop.circle")
                            .lineLimit(1)
                    }

                    Spacer()

                    Label("Read", systemImage: "arrow.right.circle.fill")
                }
                .font(.caption.weight(.medium))
                .foregroundColor(Color.brand)
            }
            .padding(16)
        }
        .background(Color(.systemBackground))
        .clipShape(RoundedRectangle(cornerRadius: 26, style: .continuous))
        .shadow(color: .black.opacity(0.12), radius: 18, x: 0, y: 10)
        .overlay {
            RoundedRectangle(cornerRadius: 26, style: .continuous)
                .stroke(Color.white.opacity(0.35), lineWidth: 1)
        }
    }
}

struct NewsCard: View {
    let article: NewsArticle

    var body: some View {
        HStack(spacing: 12) {
            AsyncImage(url: article.imageURL) { phase in
                switch phase {
                case .empty:
                    Rectangle()
                        .fill(Color.brand.opacity(0.10))
                        .overlay(ProgressView().scaleEffect(0.75))
                case .success(let image):
                    image
                        .resizable()
                        .scaledToFill()
                case .failure:
                    NewsImageFallback()
                @unknown default:
                    NewsImageFallback()
                }
            }
            .frame(width: 76, height: 76)
            .clipShape(RoundedRectangle(cornerRadius: 16, style: .continuous))

            VStack(alignment: .leading, spacing: 7) {
                HStack(spacing: 8) {
                    Text(article.source.name)
                        .font(.caption2.weight(.bold))
                        .foregroundStyle(Color.brand)
                        .lineLimit(1)

                    Text(article.formattedDate)
                        .font(.caption2)
                        .foregroundStyle(.secondary)
                        .lineLimit(1)
                }

                Text(article.title)
                    .font(.headline)
                    .foregroundStyle(.primary)
                    .lineLimit(3)

                if let description = article.description, !description.isEmpty {
                    Text(description)
                        .font(.caption)
                        .foregroundStyle(.secondary)
                        .lineLimit(2)
                }
            }

            Spacer(minLength: 0)
        }
        .padding(12)
        .background(Color.surface0)
        .clipShape(RoundedRectangle(cornerRadius: 20, style: .continuous))
        .shadow(color: .black.opacity(0.08), radius: 12, x: 0, y: 6)
    }
}

struct NewsDetailView: View {
    let article: NewsArticle

    var body: some View {
        GeometryReader { proxy in
            ScrollView(.vertical, showsIndicators: true) {
                VStack(alignment: .leading, spacing: 18) {
                    AsyncImage(url: article.imageURL) { phase in
                        switch phase {
                        case .empty:
                            Rectangle()
                                .fill(Color.brand.opacity(0.12))
                                .overlay(ProgressView())
                        case .success(let image):
                            image
                                .resizable()
                                .scaledToFill()
                        case .failure:
                            NewsImageFallback()
                        @unknown default:
                            NewsImageFallback()
                        }
                    }
                    .frame(width: detailContentWidth(for: proxy.size.width), height: 230)
                    .clipped()
                    .clipShape(RoundedRectangle(cornerRadius: 22, style: .continuous))
                    .shadow(color: .black.opacity(0.14), radius: 14, x: 0, y: 8)

                    VStack(alignment: .leading, spacing: 10) {
                        Text(article.source.name.uppercased())
                            .font(.caption.weight(.bold))
                            .foregroundColor(Color.brand)
                            .fixedSize(horizontal: false, vertical: true)

                        Text(article.title)
                            .font(.title.weight(.bold))
                            .lineSpacing(3)
                            .fixedSize(horizontal: false, vertical: true)

                        VStack(alignment: .leading, spacing: 4) {
                            Text(article.formattedDate)
                            if let author = article.author, !author.isEmpty {
                                Text("by \(author)")
                                    .fixedSize(horizontal: false, vertical: true)
                            }
                        }
                        .font(.caption)
                        .foregroundColor(.secondary)
                    }
                    .frame(maxWidth: .infinity, alignment: .leading)

                    if let description = article.description, !description.isEmpty {
                        Text(description)
                            .font(.title3.weight(.medium))
                            .foregroundColor(.secondary)
                            .lineSpacing(4)
                            .fixedSize(horizontal: false, vertical: true)
                    }

                    Text(article.cleanContent)
                        .font(.body)
                        .lineSpacing(7)
                        .fixedSize(horizontal: false, vertical: true)

                    if let url = article.articleURL {
                        Link(destination: url) {
                            Label("Open Full Article", systemImage: "safari")
                                .frame(maxWidth: .infinity)
                                .padding()
                                .background(Color.brand)
                                .foregroundColor(.white)
                                .clipShape(RoundedRectangle(cornerRadius: 14))
                        }
                        .padding(.top, 6)
                    }
                }
                .frame(width: detailContentWidth(for: proxy.size.width), alignment: .leading)
                .padding(.horizontal, 16)
                .padding(.vertical, 18)
            }
            .scrollDisabled(false)
            .background(
                LinearGradient(
                    colors: [Color(.systemBackground), Color.brand.opacity(0.08)],
                    startPoint: .top,
                    endPoint: .bottom
                )
                .ignoresSafeArea()
            )
            .navigationTitle("Read")
            .navigationBarTitleDisplayMode(.inline)
        }
    }

    private func detailContentWidth(for screenWidth: CGFloat) -> CGFloat {
        max(0, screenWidth - 32)
    }
}

struct NewsImageFallback: View {
    var body: some View {
        Rectangle()
            .fill(
                LinearGradient(
                    colors: [Color.brand.opacity(0.55), Color.warning.opacity(0.45)],
                    startPoint: .topLeading,
                    endPoint: .bottomTrailing
                )
            )
            .overlay {
                Image(systemName: "newspaper.fill")
                    .font(.system(size: 44))
                    .foregroundColor(.white.opacity(0.9))
            }
    }
}

struct NewsErrorView: View {
    let message: String
    let retry: () -> Void

    var body: some View {
        VStack(spacing: 14) {
            Image(systemName: "wifi.exclamationmark")
                .font(.system(size: 48))
                .foregroundColor(Color.warning)

            Text("News Unavailable")
                .font(.title2.bold())

            Text(message)
                .font(.subheadline)
                .foregroundColor(.secondary)
                .multilineTextAlignment(.center)

            AlgoButton(title: "Try Again", icon: "arrow.clockwise", style: .secondary, action: retry)
        }
        .frame(maxWidth: .infinity)
        .padding(24)
        .background(Color(.systemBackground))
        .clipShape(RoundedRectangle(cornerRadius: 22))
        .shadow(color: .black.opacity(0.12), radius: 18, x: 0, y: 10)
    }
}

enum NewsDateFormatter {
    static func formattedDate(from value: String) -> String {
        let parser = ISO8601DateFormatter()
        guard let date = parser.date(from: value) else {
            return value
        }

        let formatter = DateFormatter()
        formatter.dateStyle = .medium
        formatter.timeStyle = .short
        return formatter.string(from: date)
    }
}
