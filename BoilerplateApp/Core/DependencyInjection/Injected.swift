import Foundation

/// Property wrapper for dependency injection
/// Usage: @Injected var networkClient: NetworkClient
@propertyWrapper
struct Injected<T> {

    private var value: T

    var wrappedValue: T {
        get { value }
        mutating set { value = newValue }
    }

    init() {
        self.value = DependencyContainer.shared.resolve(T.self)
    }
}

/// Property wrapper for optional dependency injection
/// Returns nil if dependency is not registered
@propertyWrapper
struct OptionalInjected<T> {

    private var value: T?

    var wrappedValue: T? {
        get { value }
        mutating set { value = newValue }
    }

    init() {
        self.value = DependencyContainer.shared.tryResolve(T.self)
    }
}

/// Property wrapper for lazy dependency injection
/// Dependency is resolved on first access
@propertyWrapper
struct LazyInjected<T> {

    private var value: T?

    var wrappedValue: T {
        mutating get {
            if let existing = value {
                return existing
            }
            let resolved = DependencyContainer.shared.resolve(T.self)
            value = resolved
            return resolved
        }
        set {
            value = newValue
        }
    }

    init() {
        self.value = nil
    }
}

// MARK: - Dependency Keys

/// Key path-based dependency injection for SwiftUI-style syntax
/// Usage: @Injected(\.authService) var authService
extension Injected {
    init(_ keyPath: KeyPath<DependencyValues, T>) {
        self.value = DependencyValues.current[keyPath: keyPath]
    }
}

/// Container for dependency values accessed via key paths
struct DependencyValues {
    static var current = DependencyValues()

    @MainActor var authService: AuthServiceProtocol {
        AuthService.shared
    }

    var networkClient: NetworkClient {
        DependencyContainer.shared.resolve(NetworkClient.self)
    }

    var keychain: KeychainManager {
        DependencyContainer.shared.resolve(KeychainManager.self)
    }

    var userDefaults: UserDefaultsManager {
        DependencyContainer.shared.resolve(UserDefaultsManager.self)
    }
}
