import SwiftUI

/// A reusable loading view component
/// Based on patterns from EhPanda, QuickSummary, and PocketCasts
public struct LoadingView: View {
    let message: String

    public init(message: String = "Loading...") {
        self.message = message
    }

    public var body: some View {
        VStack(spacing: 16) {
            ProgressView()
                .progressViewStyle(CircularProgressViewStyle())
                .scaleEffect(1.2)

            Text(message)
                .font(.subheadline)
                .foregroundStyle(.secondary)
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity)
    }
}

/// Full-screen loading overlay
public struct LoadingOverlay: View {
    let message: String
    let isPresented: Bool

    public init(message: String = "Loading...", isPresented: Bool = true) {
        self.message = message
        self.isPresented = isPresented
    }

    public var body: some View {
        if isPresented {
            ZStack {
                Color.black.opacity(0.3)
                    .ignoresSafeArea()

                VStack(spacing: 16) {
                    ProgressView()
                        .progressViewStyle(CircularProgressViewStyle())
                        .scaleEffect(1.2)
                        .tint(.white)

                    Text(message)
                        .font(.subheadline)
                        .foregroundStyle(.white)
                }
                .padding(24)
                .background(.ultraThinMaterial, in: RoundedRectangle(cornerRadius: 16))
            }
        }
    }
}

// MARK: - View Modifier

extension View {
    /// Adds a loading overlay to the view
    public func loadingOverlay(isLoading: Bool, message: String = "Loading...") -> some View {
        ZStack {
            self
            LoadingOverlay(message: message, isPresented: isLoading)
        }
    }
}

// MARK: - Preview

#Preview("Loading View") {
    LoadingView()
}

#Preview("Loading Overlay") {
    Text("Content behind overlay")
        .loadingOverlay(isLoading: true)
}
