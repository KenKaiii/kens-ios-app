import Foundation

/// Lightweight dependency injection container
/// Provides compile-time safe dependency resolution
final class DependencyContainer {

    // MARK: - Singleton

    static let shared = DependencyContainer()

    // MARK: - Storage

    private var factories: [String: () -> Any] = [:]
    private var singletons: [String: Any] = [:]

    // MARK: - Registration

    /// Register all dependencies
    func register() {
        // Network
        registerSingleton(NetworkClient.self) { NetworkClient.shared }

        // Storage
        registerSingleton(KeychainManager.self) { KeychainManager() }
        registerSingleton(UserDefaultsManager.self) { UserDefaultsManager() }

        // Add more dependencies as needed
    }

    /// Register a factory that creates a new instance each time
    func registerFactory<T>(_ type: T.Type, factory: @escaping () -> T) {
        let key = String(describing: type)
        factories[key] = factory
    }

    /// Register a singleton that is created once and reused
    func registerSingleton<T>(_ type: T.Type, factory: @escaping () -> T) {
        let key = String(describing: type)
        factories[key] = { [weak self] in
            if let existing = self?.singletons[key] as? T {
                return existing
            }
            let instance = factory()
            self?.singletons[key] = instance
            return instance
        }
    }

    // MARK: - Resolution

    /// Resolve a dependency
    func resolve<T>(_ type: T.Type) -> T {
        let key = String(describing: type)
        guard let factory = factories[key], let instance = factory() as? T else {
            fatalError("No dependency registered for type: \(key)")
        }
        return instance
    }

    /// Try to resolve a dependency, returning nil if not found
    func tryResolve<T>(_ type: T.Type) -> T? {
        let key = String(describing: type)
        guard let factory = factories[key], let instance = factory() as? T else {
            return nil
        }
        return instance
    }

    // MARK: - Testing Support

    /// Clear all registrations (useful for testing)
    func reset() {
        factories.removeAll()
        singletons.removeAll()
    }

    /// Override a dependency for testing
    func override<T>(_ type: T.Type, with instance: T) {
        let key = String(describing: type)
        singletons[key] = instance
        factories[key] = { instance }
    }
}
