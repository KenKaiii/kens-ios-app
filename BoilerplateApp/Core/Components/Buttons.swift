import SwiftUI

// MARK: - Primary Button

/// Primary action button with loading state support
public struct PrimaryButton: View {
    let title: String
    let isLoading: Bool
    let isDisabled: Bool
    let action: () -> Void

    public init(
        _ title: String,
        isLoading: Bool = false,
        isDisabled: Bool = false,
        action: @escaping () -> Void
    ) {
        self.title = title
        self.isLoading = isLoading
        self.isDisabled = isDisabled
        self.action = action
    }

    public var body: some View {
        Button(action: action) {
            Group {
                if isLoading {
                    ProgressView()
                        .tint(.white)
                } else {
                    Text(title)
                        .fontWeight(.semibold)
                }
            }
            .frame(maxWidth: .infinity)
            .padding(.vertical, 16)
        }
        .background(isDisabled ? Color.gray.opacity(0.5) : Color.accentColor)
        .foregroundStyle(.white)
        .clipShape(RoundedRectangle(cornerRadius: 12))
        .disabled(isDisabled || isLoading)
    }
}

// MARK: - Secondary Button

/// Secondary action button (outlined style)
public struct SecondaryButton: View {
    let title: String
    let isLoading: Bool
    let isDisabled: Bool
    let action: () -> Void

    public init(
        _ title: String,
        isLoading: Bool = false,
        isDisabled: Bool = false,
        action: @escaping () -> Void
    ) {
        self.title = title
        self.isLoading = isLoading
        self.isDisabled = isDisabled
        self.action = action
    }

    public var body: some View {
        Button(action: action) {
            Group {
                if isLoading {
                    ProgressView()
                        .tint(.accentColor)
                } else {
                    Text(title)
                        .fontWeight(.semibold)
                }
            }
            .frame(maxWidth: .infinity)
            .padding(.vertical, 16)
        }
        .foregroundStyle(isDisabled ? Color.secondary : Color.accentColor)
        .overlay {
            RoundedRectangle(cornerRadius: 12)
                .stroke(isDisabled ? Color.secondary : Color.accentColor, lineWidth: 2)
        }
        .disabled(isDisabled || isLoading)
    }
}

// MARK: - Destructive Button

/// Destructive action button (red)
public struct DestructiveButton: View {
    let title: String
    let isLoading: Bool
    let action: () -> Void

    public init(
        _ title: String,
        isLoading: Bool = false,
        action: @escaping () -> Void
    ) {
        self.title = title
        self.isLoading = isLoading
        self.action = action
    }

    public var body: some View {
        Button(action: action) {
            Group {
                if isLoading {
                    ProgressView()
                        .tint(.white)
                } else {
                    Text(title)
                        .fontWeight(.semibold)
                }
            }
            .frame(maxWidth: .infinity)
            .padding(.vertical, 16)
        }
        .background(Color.red)
        .foregroundStyle(.white)
        .clipShape(RoundedRectangle(cornerRadius: 12))
        .disabled(isLoading)
    }
}

// MARK: - Icon Button

/// Circular icon button
public struct IconButton: View {
    let systemName: String
    let size: CGFloat
    let action: () -> Void

    public init(
        systemName: String,
        size: CGFloat = 44,
        action: @escaping () -> Void
    ) {
        self.systemName = systemName
        self.size = size
        self.action = action
    }

    public var body: some View {
        Button(action: action) {
            Image(systemName: systemName)
                .font(.system(size: size * 0.4))
                .frame(width: size, height: size)
                .background(Color(.secondarySystemBackground))
                .clipShape(Circle())
        }
    }
}

// MARK: - Async Button

/// Button that handles async actions with automatic loading state
public struct AsyncButton<Label: View>: View {
    let action: () async -> Void
    let label: () -> Label

    @State private var isLoading = false

    public init(
        action: @escaping () async -> Void,
        @ViewBuilder label: @escaping () -> Label
    ) {
        self.action = action
        self.label = label
    }

    public var body: some View {
        Button {
            Task {
                isLoading = true
                await action()
                isLoading = false
            }
        } label: {
            if isLoading {
                ProgressView()
            } else {
                label()
            }
        }
        .disabled(isLoading)
    }
}

// MARK: - Preview

#Preview("Buttons") {
    ScrollView {
        VStack(spacing: 20) {
            PrimaryButton("Primary Button") {}
            PrimaryButton("Loading", isLoading: true) {}
            PrimaryButton("Disabled", isDisabled: true) {}

            SecondaryButton("Secondary Button") {}
            SecondaryButton("Disabled", isDisabled: true) {}

            DestructiveButton("Delete Account") {}

            HStack {
                IconButton(systemName: "heart") {}
                IconButton(systemName: "square.and.arrow.up") {}
                IconButton(systemName: "ellipsis") {}
            }
        }
        .padding()
    }
}
