import Foundation

/// Type-safe wrapper for UserDefaults
/// Provides centralized access to all app preferences
final class UserDefaultsManager {

    // MARK: - Keys

    private enum Keys {
        static let hasCompletedOnboarding = "hasCompletedOnboarding"
        static let selectedTheme = "selectedTheme"
        static let isNotificationsEnabled = "isNotificationsEnabled"
        static let lastSyncDate = "lastSyncDate"
        static let userPreferences = "userPreferences"
        // Add more keys as needed
    }

    // MARK: - Properties

    private let defaults: UserDefaults

    // MARK: - Initialization

    init(defaults: UserDefaults = .standard) {
        self.defaults = defaults
        registerDefaults()
    }

    // MARK: - Default Values

    private func registerDefaults() {
        defaults.register(defaults: [
            Keys.hasCompletedOnboarding: false,
            Keys.selectedTheme: ThemeMode.system.rawValue,
            Keys.isNotificationsEnabled: true
        ])
    }

    // MARK: - Onboarding

    var hasCompletedOnboarding: Bool {
        get { defaults.bool(forKey: Keys.hasCompletedOnboarding) }
        set { defaults.set(newValue, forKey: Keys.hasCompletedOnboarding) }
    }

    // MARK: - Theme

    var selectedTheme: ThemeMode {
        get {
            guard let rawValue = defaults.string(forKey: Keys.selectedTheme),
                  let theme = ThemeMode(rawValue: rawValue) else {
                return .system
            }
            return theme
        }
        set {
            defaults.set(newValue.rawValue, forKey: Keys.selectedTheme)
        }
    }

    // MARK: - Notifications

    var isNotificationsEnabled: Bool {
        get { defaults.bool(forKey: Keys.isNotificationsEnabled) }
        set { defaults.set(newValue, forKey: Keys.isNotificationsEnabled) }
    }

    // MARK: - Sync

    var lastSyncDate: Date? {
        get { defaults.object(forKey: Keys.lastSyncDate) as? Date }
        set { defaults.set(newValue, forKey: Keys.lastSyncDate) }
    }

    // MARK: - Complex Objects

    var userPreferences: UserPreferences? {
        get {
            guard let data = defaults.data(forKey: Keys.userPreferences) else {
                return nil
            }
            return try? JSONDecoder().decode(UserPreferences.self, from: data)
        }
        set {
            if let newValue = newValue,
               let data = try? JSONEncoder().encode(newValue) {
                defaults.set(data, forKey: Keys.userPreferences)
            } else {
                defaults.removeObject(forKey: Keys.userPreferences)
            }
        }
    }

    // MARK: - Utility

    /// Clear all stored preferences
    func clearAll() {
        guard let domain = Bundle.main.bundleIdentifier else { return }
        defaults.removePersistentDomain(forName: domain)
        defaults.synchronize()
        registerDefaults()
    }
}

// MARK: - Supporting Types

struct UserPreferences: Codable {
    var displayName: String?
    var preferredLanguage: String?
    var fontSize: Int
    var compactMode: Bool

    init(
        displayName: String? = nil,
        preferredLanguage: String? = nil,
        fontSize: Int = 16,
        compactMode: Bool = false
    ) {
        self.displayName = displayName
        self.preferredLanguage = preferredLanguage
        self.fontSize = fontSize
        self.compactMode = compactMode
    }
}
