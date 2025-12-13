import SwiftUI

/// Manages app theming including dark/light/system mode
/// Publishes changes to update all observing views
@MainActor
final class ThemeManager: ObservableObject {

    // MARK: - Published Properties

    @Published var currentMode: ThemeMode {
        didSet {
            UserDefaults.standard.set(currentMode.rawValue, forKey: "selectedTheme")
        }
    }

    // MARK: - Computed Properties

    /// Returns the appropriate ColorScheme based on current mode
    var colorScheme: ColorScheme? {
        switch currentMode {
        case .light:
            return .light
        case .dark:
            return .dark
        case .system:
            return nil // Let system decide
        }
    }

    /// Accent color for the app
    var accentColor: Color {
        Color.accentColor
    }

    // MARK: - Initialization

    init() {
        if let savedMode = UserDefaults.standard.string(forKey: "selectedTheme"),
           let mode = ThemeMode(rawValue: savedMode) {
            self.currentMode = mode
        } else {
            self.currentMode = .system
        }
    }

    // MARK: - Methods

    func setTheme(_ mode: ThemeMode) {
        withAnimation(.easeInOut(duration: 0.3)) {
            currentMode = mode
        }
    }

    func toggleDarkMode() {
        switch currentMode {
        case .light:
            setTheme(.dark)
        case .dark:
            setTheme(.light)
        case .system:
            setTheme(.dark)
        }
    }
}

// MARK: - Theme Mode Enum

enum ThemeMode: String, CaseIterable, Identifiable {
    case system
    case light
    case dark

    var id: String { rawValue }

    var displayName: String {
        switch self {
        case .system:
            return "System"
        case .light:
            return "Light"
        case .dark:
            return "Dark"
        }
    }

    var icon: String {
        switch self {
        case .system:
            return "circle.lefthalf.filled"
        case .light:
            return "sun.max.fill"
        case .dark:
            return "moon.fill"
        }
    }
}
