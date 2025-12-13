import Foundation
import LocalAuthentication

/// Authentication service protocol for dependency injection
@MainActor
protocol AuthServiceProtocol {
    var isAuthenticated: Bool { get }
    var currentUser: User? { get }
    var isLoading: Bool { get }

    func login(email: String, password: String) async throws
    func signup(email: String, password: String, name: String) async throws
    func logout() async throws
    func resetPassword(email: String) async throws
    func canUseBiometrics() -> Bool
    func authenticateWithBiometrics() async throws -> Bool
}

/// Authentication service handling login, logout, and session management
@MainActor
final class AuthService: ObservableObject, AuthServiceProtocol {

    // MARK: - Singleton

    static let shared = AuthService()

    // MARK: - Published State

    @Published private(set) var isAuthenticated = false
    @Published private(set) var currentUser: User?
    @Published private(set) var isLoading = false

    // MARK: - Dependencies

    private let keychain: KeychainManager
    private let networkClient: NetworkClient

    // MARK: - Initialization

    init(
        keychain: KeychainManager = KeychainManager(),
        networkClient: NetworkClient = NetworkClient.shared
    ) {
        self.keychain = keychain
        self.networkClient = networkClient

        // Check for existing session
        Task {
            await checkExistingSession()
        }
    }

    // MARK: - Public Methods

    /// Sign in with email and password
    func login(email: String, password: String) async throws {
        isLoading = true
        defer { isLoading = false }

        // Example API call - replace with your auth endpoint
        // let response = try await networkClient.request(
        //     AuthAPI.login(email: email, password: password),
        //     responseType: AuthResponse.self
        // )

        // For demo, simulate successful auth
        let mockToken = "mock_access_token_\(UUID().uuidString)"
        let mockUser = User(id: UUID().uuidString, email: email, name: "User")

        // Store tokens securely
        try keychain.save(mockToken, for: .accessToken)

        // Update auth token in network client
        await networkClient.setAuthToken(mockToken)

        // Update state
        currentUser = mockUser
        isAuthenticated = true

        Log.info("User signed in: \(email)")
    }

    /// Sign up with email, password, and name
    func signup(email: String, password: String, name: String) async throws {
        isLoading = true
        defer { isLoading = false }

        // Example API call - replace with your signup endpoint
        // let response = try await networkClient.request(
        //     AuthAPI.signup(email: email, password: password, name: name),
        //     responseType: AuthResponse.self
        // )

        // For demo, simulate successful signup
        let mockToken = "mock_access_token_\(UUID().uuidString)"
        let mockUser = User(id: UUID().uuidString, email: email, name: name)

        // Store tokens securely
        try keychain.save(mockToken, for: .accessToken)

        // Update auth token in network client
        await networkClient.setAuthToken(mockToken)

        // Update state
        currentUser = mockUser
        isAuthenticated = true

        Log.info("User signed up: \(email)")
    }

    /// Sign out and clear session
    func logout() async throws {
        isLoading = true
        defer { isLoading = false }

        // Clear stored tokens
        try? keychain.delete(.accessToken)
        try? keychain.delete(.refreshToken)

        // Clear auth token from network client
        await networkClient.setAuthToken(nil)

        // Update state
        currentUser = nil
        isAuthenticated = false

        Log.info("User signed out")
    }

    /// Request password reset
    func resetPassword(email: String) async throws {
        isLoading = true
        defer { isLoading = false }

        // Example API call - replace with your password reset endpoint
        // try await networkClient.request(
        //     AuthAPI.resetPassword(email: email),
        //     responseType: EmptyResponse.self
        // )

        // Simulate network delay
        try await Task.sleep(seconds: 1)

        Log.info("Password reset requested for: \(email)")
    }

    /// Check if user can authenticate with biometrics
    func canUseBiometrics() -> Bool {
        let context = LAContext()
        var error: NSError?
        return context.canEvaluatePolicy(.deviceOwnerAuthenticationWithBiometrics, error: &error)
    }

    /// Authenticate using Face ID / Touch ID
    func authenticateWithBiometrics() async throws -> Bool {
        let context = LAContext()
        context.localizedCancelTitle = "Cancel"

        let reason = "Authenticate to access your account"

        do {
            let success = try await context.evaluatePolicy(
                .deviceOwnerAuthenticationWithBiometrics,
                localizedReason: reason
            )
            Log.info("Biometric authentication: \(success ? "success" : "failed")")
            return success
        } catch {
            Log.error("Biometric authentication error", error: error)
            throw AuthError.biometricsFailed(error)
        }
    }

    /// Refresh the access token
    func refreshToken() async throws {
        guard keychain.exists(.refreshToken) else {
            throw AuthError.noRefreshToken
        }

        // Example API call - replace with your refresh endpoint
        // let storedRefreshToken = try keychain.getString(for: .refreshToken)
        // let response = try await networkClient.request(
        //     AuthAPI.refresh(token: storedRefreshToken),
        //     responseType: AuthResponse.self
        // )

        // Store new tokens
        // try keychain.save(response.accessToken, for: .accessToken)
        // await networkClient.setAuthToken(response.accessToken)

        Log.info("Token refreshed")
    }

    // MARK: - Private Methods

    private func checkExistingSession() async {
        guard let token = try? keychain.getString(for: .accessToken) else {
            return
        }

        // Validate token with server or decode JWT to check expiry
        // For demo, just restore session
        await networkClient.setAuthToken(token)
        isAuthenticated = true

        Log.info("Restored existing session")
    }
}

// MARK: - Supporting Types

struct User: Codable, Identifiable {
    let id: String
    let email: String
    let name: String
    var avatarURL: URL?
}

struct AuthResponse: Decodable {
    let accessToken: String
    let refreshToken: String?
    let user: User
    let expiresIn: Int
}

enum AuthError: LocalizedError {
    case invalidCredentials
    case networkError(Error)
    case noRefreshToken
    case tokenExpired
    case biometricsFailed(Error)
    case unknown

    var errorDescription: String? {
        switch self {
        case .invalidCredentials:
            return "Invalid email or password"
        case .networkError(let error):
            return "Network error: \(error.localizedDescription)"
        case .noRefreshToken:
            return "No refresh token available"
        case .tokenExpired:
            return "Session expired. Please sign in again."
        case .biometricsFailed(let error):
            return "Biometric authentication failed: \(error.localizedDescription)"
        case .unknown:
            return "An unknown error occurred"
        }
    }
}
