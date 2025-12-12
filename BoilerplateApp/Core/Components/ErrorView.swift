import SwiftUI

/// A reusable error view component with retry functionality
/// Based on patterns from IceCubesApp, Jellyfin Swiftfin, and Aidoku
public struct ErrorView: View {
    let title: String
    let message: String
    let systemImage: String
    let retryAction: (() async -> Void)?

    @State private var isRetrying = false

    public init(
        title: String = "Something went wrong",
        message: String,
        systemImage: String = "exclamationmark.triangle.fill",
        retryAction: (() async -> Void)? = nil
    ) {
        self.title = title
        self.message = message
        self.systemImage = systemImage
        self.retryAction = retryAction
    }

    public init(
        error: Error,
        retryAction: (() async -> Void)? = nil
    ) {
        self.title = "Something went wrong"
        self.message = error.localizedDescription
        self.systemImage = "exclamationmark.triangle.fill"
        self.retryAction = retryAction
    }

    public var body: some View {
        VStack(spacing: 16) {
            Image(systemName: systemImage)
                .font(.system(size: 48))
                .foregroundStyle(.secondary)

            VStack(spacing: 8) {
                Text(title)
                    .font(.headline)

                Text(message)
                    .font(.subheadline)
                    .foregroundStyle(.secondary)
                    .multilineTextAlignment(.center)
                    .padding(.horizontal)
            }

            if let retryAction {
                Button {
                    Task {
                        isRetrying = true
                        await retryAction()
                        isRetrying = false
                    }
                } label: {
                    if isRetrying {
                        ProgressView()
                            .frame(width: 100, height: 44)
                    } else {
                        Text("Try Again")
                            .fontWeight(.semibold)
                            .frame(width: 100, height: 44)
                    }
                }
                .buttonStyle(.borderedProminent)
                .disabled(isRetrying)
            }
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity)
        .padding()
    }
}

/// Compact error banner for inline display
public struct ErrorBanner: View {
    let message: String
    let dismissAction: (() -> Void)?

    public init(message: String, dismissAction: (() -> Void)? = nil) {
        self.message = message
        self.dismissAction = dismissAction
    }

    public var body: some View {
        HStack(spacing: 12) {
            Image(systemName: "exclamationmark.circle.fill")
                .foregroundStyle(.white)

            Text(message)
                .font(.subheadline)
                .foregroundStyle(.white)
                .lineLimit(2)

            Spacer()

            if let dismissAction {
                Button {
                    dismissAction()
                } label: {
                    Image(systemName: "xmark")
                        .font(.caption)
                        .foregroundStyle(.white.opacity(0.8))
                }
            }
        }
        .padding()
        .background(Color.red.gradient, in: RoundedRectangle(cornerRadius: 12))
        .padding(.horizontal)
    }
}

// MARK: - Preview

#Preview("Error View") {
    ErrorView(
        title: "Connection Failed",
        message: "Unable to connect to the server. Please check your internet connection and try again."
    ) {
        try? await Task.sleep(seconds: 2)
    }
}

#Preview("Error Banner") {
    VStack {
        Spacer()
        ErrorBanner(message: "Failed to save changes") {}
    }
}
