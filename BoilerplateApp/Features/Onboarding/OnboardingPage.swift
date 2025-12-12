import SwiftUI

/// Represents a single onboarding page
/// Based on patterns from Trust Wallet, OnboardKit, and Pocket Poster
struct OnboardingPage: Identifiable, Equatable {
    let id = UUID()
    let title: String
    let description: String
    let imageName: String
    let imageIsSystemName: Bool

    init(
        title: String,
        description: String,
        systemImage: String
    ) {
        self.title = title
        self.description = description
        self.imageName = systemImage
        self.imageIsSystemName = true
    }

    init(
        title: String,
        description: String,
        imageName: String
    ) {
        self.title = title
        self.description = description
        self.imageName = imageName
        self.imageIsSystemName = false
    }
}

// MARK: - Default Pages

extension OnboardingPage {
    /// Default onboarding pages - customize these for your app
    static let defaultPages: [OnboardingPage] = [
        OnboardingPage(
            title: "Welcome",
            description: "Thanks for choosing our app. Let's get you started with a quick tour.",
            systemImage: "hand.wave.fill"
        ),
        OnboardingPage(
            title: "Stay Organized",
            description: "Keep all your important information in one place, accessible anytime.",
            systemImage: "folder.fill"
        ),
        OnboardingPage(
            title: "Sync Everywhere",
            description: "Your data syncs seamlessly across all your devices.",
            systemImage: "icloud.fill"
        ),
        OnboardingPage(
            title: "Private & Secure",
            description: "Your privacy matters. Your data is encrypted and never shared.",
            systemImage: "lock.shield.fill"
        )
    ]
}
