import Foundation

/// Analytics event protocol
/// Based on patterns from xcore and IndieBuilderKit
public protocol AnalyticsEvent {
    var name: String { get }
    var parameters: [String: Any]? { get }
}

/// Common analytics events
public enum AppEvent: AnalyticsEvent {
    case screenView(name: String)
    case buttonTapped(name: String, screen: String)
    case login(method: String)
    case signup(method: String)
    case logout
    case purchase(productId: String, value: Double, currency: String)
    case error(message: String, screen: String)
    case custom(name: String, parameters: [String: Any]?)

    public var name: String {
        switch self {
        case .screenView: return "screen_view"
        case .buttonTapped: return "button_tapped"
        case .login: return "login"
        case .signup: return "signup"
        case .logout: return "logout"
        case .purchase: return "purchase"
        case .error: return "error"
        case .custom(let name, _): return name
        }
    }

    public var parameters: [String: Any]? {
        switch self {
        case .screenView(let name):
            return ["screen_name": name]
        case let .buttonTapped(name, screen):
            return ["button_name": name, "screen_name": screen]
        case .login(let method):
            return ["method": method]
        case .signup(let method):
            return ["method": method]
        case .logout:
            return nil
        case let .purchase(productId, value, currency):
            return ["product_id": productId, "value": value, "currency": currency]
        case let .error(message, screen):
            return ["error_message": message, "screen_name": screen]
        case .custom(_, let parameters):
            return parameters
        }
    }
}

/// Analytics provider protocol
/// Implement this for different analytics services (Firebase, Mixpanel, etc.)
public protocol AnalyticsProvider: Sendable {
    /// Unique identifier for this provider
    var id: String { get }

    /// Track an event
    func track(_ event: AnalyticsEvent)

    /// Identify a user
    func identify(userId: String?, traits: [String: Any]?)

    /// Reset/logout
    func reset()

    /// Set a user property
    func setUserProperty(_ value: String?, forKey key: String)
}

/// Analytics manager that dispatches to multiple providers
@MainActor
public final class Analytics {
    public static let shared = Analytics()

    private var providers: [AnalyticsProvider] = []
    private var isEnabled = true

    private init() {}

    /// Register an analytics provider
    public func register(_ provider: AnalyticsProvider) {
        providers.append(provider)
        Log.debug("Registered analytics provider: \(provider.id)")
    }

    /// Remove all providers
    public func removeAllProviders() {
        providers.removeAll()
    }

    /// Enable/disable analytics
    public func setEnabled(_ enabled: Bool) {
        isEnabled = enabled
    }

    /// Track an event
    public func track(_ event: AnalyticsEvent) {
        guard isEnabled else { return }

        Log.debug("Analytics: \(event.name) - \(event.parameters ?? [:])")

        for provider in providers {
            provider.track(event)
        }
    }

    /// Identify a user
    public func identify(userId: String?, traits: [String: Any]? = nil) {
        guard isEnabled else { return }

        for provider in providers {
            provider.identify(userId: userId, traits: traits)
        }
    }

    /// Reset user (on logout)
    public func reset() {
        for provider in providers {
            provider.reset()
        }
    }

    /// Set a user property
    public func setUserProperty(_ value: String?, forKey key: String) {
        guard isEnabled else { return }

        for provider in providers {
            provider.setUserProperty(value, forKey: key)
        }
    }
}

// MARK: - Console Analytics Provider (for debugging)

/// Debug analytics provider that logs to console
public struct ConsoleAnalyticsProvider: AnalyticsProvider {
    public let id = "console"

    public init() {}

    public func track(_ event: AnalyticsEvent) {
        let params = event.parameters?.map { "\($0): \($1)" }.joined(separator: ", ") ?? "none"
        Log.debug("[Analytics] \(event.name) | params: \(params)")
    }

    public func identify(userId: String?, traits: [String: Any]?) {
        Log.debug("[Analytics] Identify: \(userId ?? "nil") | traits: \(traits ?? [:])")
    }

    public func reset() {
        Log.debug("[Analytics] Reset")
    }

    public func setUserProperty(_ value: String?, forKey key: String) {
        Log.debug("[Analytics] Set property \(key): \(value ?? "nil")")
    }
}

// MARK: - View Extension

import SwiftUI

extension View {
    /// Track screen view when this view appears
    public func trackScreenView(_ screenName: String) -> some View {
        onAppear {
            Analytics.shared.track(AppEvent.screenView(name: screenName))
        }
    }
}
