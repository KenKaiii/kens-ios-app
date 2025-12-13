import UIKit

/// Haptic feedback utility
/// Based on patterns from Signal iOS, Telegram iOS, and GitHawk
public enum Haptic {

    // MARK: - Generators

    private static let selectionGenerator = UISelectionFeedbackGenerator()
    private static let notificationGenerator = UINotificationFeedbackGenerator()

    // MARK: - Impact Feedback

    /// Trigger impact feedback
    public static func impact(_ style: UIImpactFeedbackGenerator.FeedbackStyle) {
        let generator = UIImpactFeedbackGenerator(style: style)
        generator.impactOccurred()
    }

    /// Light impact feedback
    public static func lightImpact() {
        impact(.light)
    }

    /// Medium impact feedback
    public static func mediumImpact() {
        impact(.medium)
    }

    /// Heavy impact feedback
    public static func heavyImpact() {
        impact(.heavy)
    }

    /// Soft impact feedback (iOS 13+)
    public static func softImpact() {
        impact(.soft)
    }

    /// Rigid impact feedback (iOS 13+)
    public static func rigidImpact() {
        impact(.rigid)
    }

    // MARK: - Selection Feedback

    /// Trigger selection changed feedback
    public static func selection() {
        selectionGenerator.selectionChanged()
    }

    // MARK: - Notification Feedback

    /// Trigger notification feedback
    public static func notification(_ type: UINotificationFeedbackGenerator.FeedbackType) {
        notificationGenerator.notificationOccurred(type)
    }

    /// Success notification feedback
    public static func success() {
        notification(.success)
    }

    /// Warning notification feedback
    public static func warning() {
        notification(.warning)
    }

    /// Error notification feedback
    public static func error() {
        notification(.error)
    }

    // MARK: - Preparation

    /// Prepare generators for upcoming feedback
    public static func prepare() {
        selectionGenerator.prepare()
        notificationGenerator.prepare()
    }
}

// MARK: - View Modifier

import SwiftUI

/// View modifier for haptic feedback on tap
struct HapticFeedbackModifier: ViewModifier {
    let style: UIImpactFeedbackGenerator.FeedbackStyle

    func body(content: Content) -> some View {
        content.onTapGesture {
            Haptic.impact(style)
        }
    }
}

extension View {
    /// Adds haptic feedback on tap
    public func hapticFeedback(_ style: UIImpactFeedbackGenerator.FeedbackStyle = .light) -> some View {
        modifier(HapticFeedbackModifier(style: style))
    }

    /// Triggers haptic feedback when a value changes
    public func hapticOnChange<V: Equatable>(
        of value: V,
        _ feedbackType: UINotificationFeedbackGenerator.FeedbackType = .success
    ) -> some View {
        onChange(of: value) { _, _ in
            Haptic.notification(feedbackType)
        }
    }
}
