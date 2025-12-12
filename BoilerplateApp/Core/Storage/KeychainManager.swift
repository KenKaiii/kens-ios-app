import Foundation
import Security

/// Secure storage manager using iOS Keychain
/// Use for sensitive data like tokens, passwords, and API keys
final class KeychainManager {

    // MARK: - Keys

    enum KeychainKey: String {
        case accessToken = "com.app.accessToken"
        case refreshToken = "com.app.refreshToken"
        case userCredentials = "com.app.userCredentials"
        case apiKey = "com.app.apiKey"
        // Add more keys as needed
    }

    // MARK: - Properties

    private let service: String

    // MARK: - Initialization

    init(service: String = Bundle.main.bundleIdentifier ?? "com.app.keychain") {
        self.service = service
    }

    // MARK: - Public Methods

    /// Save a string value to keychain
    func save(_ value: String, for key: KeychainKey) throws {
        guard let data = value.data(using: .utf8) else {
            throw KeychainError.encodingFailed
        }
        try save(data, for: key)
    }

    /// Save data to keychain
    func save(_ data: Data, for key: KeychainKey) throws {
        // Delete existing item first
        try? delete(key)

        let query: [String: Any] = [
            kSecClass as String: kSecClassGenericPassword,
            kSecAttrService as String: service,
            kSecAttrAccount as String: key.rawValue,
            kSecValueData as String: data,
            kSecAttrAccessible as String: kSecAttrAccessibleAfterFirstUnlockThisDeviceOnly
        ]

        let status = SecItemAdd(query as CFDictionary, nil)

        guard status == errSecSuccess else {
            throw KeychainError.saveFailed(status)
        }

        Log.info("Keychain: Saved \(key.rawValue)")
    }

    /// Save a Codable object to keychain
    func save<T: Encodable>(_ object: T, for key: KeychainKey) throws {
        let data = try JSONEncoder().encode(object)
        try save(data, for: key)
    }

    /// Retrieve a string value from keychain
    func getString(for key: KeychainKey) throws -> String {
        let data = try getData(for: key)
        guard let string = String(data: data, encoding: .utf8) else {
            throw KeychainError.decodingFailed
        }
        return string
    }

    /// Retrieve data from keychain
    func getData(for key: KeychainKey) throws -> Data {
        let query: [String: Any] = [
            kSecClass as String: kSecClassGenericPassword,
            kSecAttrService as String: service,
            kSecAttrAccount as String: key.rawValue,
            kSecReturnData as String: true,
            kSecMatchLimit as String: kSecMatchLimitOne
        ]

        var result: AnyObject?
        let status = SecItemCopyMatching(query as CFDictionary, &result)

        guard status == errSecSuccess else {
            if status == errSecItemNotFound {
                throw KeychainError.itemNotFound
            }
            throw KeychainError.readFailed(status)
        }

        guard let data = result as? Data else {
            throw KeychainError.invalidData
        }

        return data
    }

    /// Retrieve a Codable object from keychain
    func get<T: Decodable>(_ type: T.Type, for key: KeychainKey) throws -> T {
        let data = try getData(for: key)
        return try JSONDecoder().decode(T.self, from: data)
    }

    /// Check if a key exists in keychain
    func exists(_ key: KeychainKey) -> Bool {
        do {
            _ = try getData(for: key)
            return true
        } catch {
            return false
        }
    }

    /// Delete an item from keychain
    func delete(_ key: KeychainKey) throws {
        let query: [String: Any] = [
            kSecClass as String: kSecClassGenericPassword,
            kSecAttrService as String: service,
            kSecAttrAccount as String: key.rawValue
        ]

        let status = SecItemDelete(query as CFDictionary)

        guard status == errSecSuccess || status == errSecItemNotFound else {
            throw KeychainError.deleteFailed(status)
        }

        Log.info("Keychain: Deleted \(key.rawValue)")
    }

    /// Delete all items for this service
    func deleteAll() throws {
        let query: [String: Any] = [
            kSecClass as String: kSecClassGenericPassword,
            kSecAttrService as String: service
        ]

        let status = SecItemDelete(query as CFDictionary)

        guard status == errSecSuccess || status == errSecItemNotFound else {
            throw KeychainError.deleteFailed(status)
        }

        Log.info("Keychain: Deleted all items")
    }
}

// MARK: - Errors

enum KeychainError: LocalizedError {
    case encodingFailed
    case decodingFailed
    case saveFailed(OSStatus)
    case readFailed(OSStatus)
    case deleteFailed(OSStatus)
    case itemNotFound
    case invalidData

    var errorDescription: String? {
        switch self {
        case .encodingFailed:
            return "Failed to encode data for keychain"
        case .decodingFailed:
            return "Failed to decode data from keychain"
        case .saveFailed(let status):
            return "Failed to save to keychain (status: \(status))"
        case .readFailed(let status):
            return "Failed to read from keychain (status: \(status))"
        case .deleteFailed(let status):
            return "Failed to delete from keychain (status: \(status))"
        case .itemNotFound:
            return "Item not found in keychain"
        case .invalidData:
            return "Invalid data in keychain"
        }
    }
}
