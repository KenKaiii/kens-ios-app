import SwiftUI

/// Empty state view for when there's no content to display
public struct EmptyStateView: View {
    let title: String
    let message: String
    let systemImage: String
    let actionTitle: String?
    let action: (() -> Void)?

    public init(
        title: String,
        message: String,
        systemImage: String,
        actionTitle: String? = nil,
        action: (() -> Void)? = nil
    ) {
        self.title = title
        self.message = message
        self.systemImage = systemImage
        self.actionTitle = actionTitle
        self.action = action
    }

    public var body: some View {
        VStack(spacing: 16) {
            Image(systemName: systemImage)
                .font(.system(size: 56))
                .foregroundStyle(.secondary)

            VStack(spacing: 8) {
                Text(title)
                    .font(.headline)

                Text(message)
                    .font(.subheadline)
                    .foregroundStyle(.secondary)
                    .multilineTextAlignment(.center)
            }

            if let actionTitle, let action {
                Button(actionTitle, action: action)
                    .buttonStyle(.borderedProminent)
                    .padding(.top, 8)
            }
        }
        .padding(32)
        .frame(maxWidth: .infinity, maxHeight: .infinity)
    }
}

// MARK: - Common Empty States

extension EmptyStateView {
    /// Empty search results
    public static func noSearchResults(query: String) -> EmptyStateView {
        EmptyStateView(
            title: "No Results",
            message: "No results found for \"\(query)\"",
            systemImage: "magnifyingglass"
        )
    }

    /// Empty list
    public static func noItems(itemName: String, action: (() -> Void)? = nil) -> EmptyStateView {
        EmptyStateView(
            title: "No \(itemName)",
            message: "You don't have any \(itemName.lowercased()) yet.",
            systemImage: "tray",
            actionTitle: action != nil ? "Add \(itemName)" : nil,
            action: action
        )
    }

    /// No network
    public static func noNetwork(retryAction: @escaping () -> Void) -> EmptyStateView {
        EmptyStateView(
            title: "No Connection",
            message: "Please check your internet connection and try again.",
            systemImage: "wifi.slash",
            actionTitle: "Retry",
            action: retryAction
        )
    }
}

// MARK: - Preview

#Preview("Empty State") {
    EmptyStateView(
        title: "No Items",
        message: "You don't have any items yet. Tap the button below to create your first item.",
        systemImage: "doc.text",
        actionTitle: "Create Item"
    ) {}
}

#Preview("No Search Results") {
    EmptyStateView.noSearchResults(query: "test search")
}
