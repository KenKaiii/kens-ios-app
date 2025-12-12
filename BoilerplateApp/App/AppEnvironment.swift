import Foundation

/// Represents different build environments
enum AppEnvironment {
    case debug
    case staging
    case production

    /// Current environment based on build configuration
    static var current: AppEnvironment {
        #if DEBUG
        return .debug
        #elseif STAGING
        return .staging
        #else
        return .production
        #endif
    }

    /// Environment display name
    var name: String {
        switch self {
        case .debug:
            return "Debug"
        case .staging:
            return "Staging"
        case .production:
            return "Production"
        }
    }

    /// Base URL for API requests
    var baseURL: URL {
        let urlString: String
        switch self {
        case .debug:
            urlString = "https://api.dev.example.com"
        case .staging:
            urlString = "https://api.staging.example.com"
        case .production:
            urlString = "https://api.example.com"
        }
        // These URLs are hardcoded and known valid, so force unwrap is safe here
        // swiftlint:disable:next force_unwrapping
        return URL(string: urlString)!
    }

    /// Whether verbose logging is enabled
    var isLoggingEnabled: Bool {
        switch self {
        case .debug, .staging:
            return true
        case .production:
            return false
        }
    }

    /// Whether analytics are enabled
    var isAnalyticsEnabled: Bool {
        switch self {
        case .debug:
            return false
        case .staging, .production:
            return true
        }
    }

    /// API timeout interval in seconds
    var apiTimeoutInterval: TimeInterval {
        switch self {
        case .debug:
            return 60
        case .staging:
            return 30
        case .production:
            return 15
        }
    }
}
