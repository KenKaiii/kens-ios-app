import SwiftUI

/// Centralized color definitions for the app
/// Uses semantic naming for consistency
enum AppColors {

    // MARK: - Primary Colors

    /// Primary brand color
    static let primary = Color("Primary", bundle: .main)

    /// Secondary brand color
    static let secondary = Color("Secondary", bundle: .main)

    /// Accent color for interactive elements
    static let accent = Color.accentColor

    // MARK: - Semantic Colors

    /// Success state color
    static let success = Color.green

    /// Warning state color
    static let warning = Color.orange

    /// Error/destructive state color
    static let error = Color.red

    /// Informational state color
    static let info = Color.blue

    // MARK: - Background Colors

    /// Primary background
    static var background: Color {
        Color(uiColor: .systemBackground)
    }

    /// Secondary/grouped background
    static var secondaryBackground: Color {
        Color(uiColor: .secondarySystemBackground)
    }

    /// Tertiary background
    static var tertiaryBackground: Color {
        Color(uiColor: .tertiarySystemBackground)
    }

    // MARK: - Text Colors

    /// Primary text color
    static var textPrimary: Color {
        Color(uiColor: .label)
    }

    /// Secondary text color
    static var textSecondary: Color {
        Color(uiColor: .secondaryLabel)
    }

    /// Tertiary text color
    static var textTertiary: Color {
        Color(uiColor: .tertiaryLabel)
    }

    /// Placeholder text color
    static var textPlaceholder: Color {
        Color(uiColor: .placeholderText)
    }

    // MARK: - Border & Separator

    /// Default separator color
    static var separator: Color {
        Color(uiColor: .separator)
    }

    /// Opaque separator color
    static var opaqueSeparator: Color {
        Color(uiColor: .opaqueSeparator)
    }

    // MARK: - Fill Colors

    /// Primary fill color
    static var fill: Color {
        Color(uiColor: .systemFill)
    }

    /// Secondary fill color
    static var secondaryFill: Color {
        Color(uiColor: .secondarySystemFill)
    }
}

// MARK: - Color Extensions

extension Color {

    /// Initialize from hex string
    init(hex: String) {
        let hex = hex.trimmingCharacters(in: CharacterSet.alphanumerics.inverted)
        var int: UInt64 = 0
        Scanner(string: hex).scanHexInt64(&int)
        let a, r, g, b: UInt64
        switch hex.count {
        case 3: // RGB (12-bit)
            (a, r, g, b) = (255, (int >> 8) * 17, (int >> 4 & 0xF) * 17, (int & 0xF) * 17)
        case 6: // RGB (24-bit)
            (a, r, g, b) = (255, int >> 16, int >> 8 & 0xFF, int & 0xFF)
        case 8: // ARGB (32-bit)
            (a, r, g, b) = (int >> 24, int >> 16 & 0xFF, int >> 8 & 0xFF, int & 0xFF)
        default:
            (a, r, g, b) = (255, 0, 0, 0)
        }

        self.init(
            .sRGB,
            red: Double(r) / 255,
            green: Double(g) / 255,
            blue: Double(b) / 255,
            opacity: Double(a) / 255
        )
    }
}
