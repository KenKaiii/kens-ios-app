import SwiftUI

/// Async image view with caching support
/// Based on patterns from Exyte/Chat, Tuist, and Omnivore
public struct CachedAsyncImage<Content: View, Placeholder: View>: View {
    private let url: URL?
    private let scale: CGFloat
    private let transaction: Transaction
    private let content: (Image) -> Content
    private let placeholder: () -> Placeholder

    @State private var phase: AsyncImagePhase = .empty

    public init(
        url: URL?,
        scale: CGFloat = 1.0,
        transaction: Transaction = Transaction(),
        @ViewBuilder content: @escaping (Image) -> Content,
        @ViewBuilder placeholder: @escaping () -> Placeholder
    ) {
        self.url = url
        self.scale = scale
        self.transaction = transaction
        self.content = content
        self.placeholder = placeholder
    }

    public var body: some View {
        Group {
            switch phase {
            case .empty:
                placeholder()
            case .success(let image):
                content(image)
            case .failure:
                placeholder()
            @unknown default:
                placeholder()
            }
        }
        .task(id: url) {
            await load()
        }
    }

    private func load() async {
        guard let url else {
            phase = .empty
            return
        }

        // Check cache first
        if let cachedImage = ImageCache.shared.get(for: url) {
            withTransaction(transaction) {
                phase = .success(Image(uiImage: cachedImage))
            }
            return
        }

        // Download image
        do {
            let (data, _) = try await URLSession.shared.data(from: url)
            guard let uiImage = UIImage(data: data) else {
                phase = .failure(ImageError.invalidData)
                return
            }

            // Cache the image
            ImageCache.shared.set(uiImage, for: url)

            withTransaction(transaction) {
                phase = .success(Image(uiImage: uiImage))
            }
        } catch {
            phase = .failure(error)
        }
    }
}

// MARK: - Convenience Initializers

extension CachedAsyncImage where Placeholder == ProgressView<EmptyView, EmptyView> {
    public init(
        url: URL?,
        scale: CGFloat = 1.0,
        @ViewBuilder content: @escaping (Image) -> Content
    ) {
        self.init(
            url: url,
            scale: scale,
            content: content,
            placeholder: { ProgressView() }
        )
    }
}

extension CachedAsyncImage where Content == Image, Placeholder == ProgressView<EmptyView, EmptyView> {
    public init(url: URL?, scale: CGFloat = 1.0) {
        self.init(
            url: url,
            scale: scale,
            content: { $0 },
            placeholder: { ProgressView() }
        )
    }
}

// MARK: - Image Cache

/// In-memory image cache using NSCache
final class ImageCache: @unchecked Sendable {
    static let shared = ImageCache()

    private let cache = NSCache<NSURL, UIImage>()

    private init() {
        cache.countLimit = 100
        cache.totalCostLimit = 50 * 1024 * 1024 // 50 MB
    }

    func get(for url: URL) -> UIImage? {
        cache.object(forKey: url as NSURL)
    }

    func set(_ image: UIImage, for url: URL) {
        let cost = image.cgImage.map { $0.bytesPerRow * $0.height } ?? 0
        cache.setObject(image, forKey: url as NSURL, cost: cost)
    }

    func remove(for url: URL) {
        cache.removeObject(forKey: url as NSURL)
    }

    func clearAll() {
        cache.removeAllObjects()
    }
}

// MARK: - Image Error

enum ImageError: LocalizedError {
    case invalidData
    case downloadFailed

    var errorDescription: String? {
        switch self {
        case .invalidData:
            return "Invalid image data"
        case .downloadFailed:
            return "Failed to download image"
        }
    }
}

// MARK: - Preview

#Preview {
    VStack {
        CachedAsyncImage(
            url: URL(string: "https://picsum.photos/200")
        ) { image in
            image
                .resizable()
                .scaledToFit()
        } placeholder: {
            ProgressView()
        }
        .frame(width: 200, height: 200)
        .clipShape(RoundedRectangle(cornerRadius: 12))
    }
}
