import Foundation
import SwiftUI

/// Authentication view model
/// Handles login, signup, and auth state management
@MainActor
@Observable
final class AuthViewModel {

    // MARK: - Properties

    var email = ""
    var password = ""
    var confirmPassword = ""
    var fullName = ""

    var isLoading = false
    var errorMessage: String?
    var showError = false

    @ObservationIgnored
    @Injected(\.authService) private var authService: AuthServiceProtocol

    // MARK: - Computed Properties

    var isLoginValid: Bool {
        email.isValidEmail && password.count >= 6
    }

    var isSignupValid: Bool {
        email.isValidEmail &&
        password.count >= 6 &&
        password == confirmPassword &&
        !fullName.trimmed.isEmpty
    }

    var passwordsMatch: Bool {
        password == confirmPassword
    }

    // MARK: - Methods

    func login() async {
        guard isLoginValid else {
            showErrorMessage("Please enter a valid email and password (6+ characters)")
            return
        }

        isLoading = true
        errorMessage = nil

        do {
            try await authService.login(email: email, password: password)
            clearFields()
        } catch {
            showErrorMessage(error.localizedDescription)
        }

        isLoading = false
    }

    func signup() async {
        guard isSignupValid else {
            if !passwordsMatch {
                showErrorMessage("Passwords do not match")
            } else {
                showErrorMessage("Please fill in all fields correctly")
            }
            return
        }

        isLoading = true
        errorMessage = nil

        do {
            try await authService.signup(email: email, password: password, name: fullName.trimmed)
            clearFields()
        } catch {
            showErrorMessage(error.localizedDescription)
        }

        isLoading = false
    }

    func logout() async {
        isLoading = true
        do {
            try await authService.logout()
        } catch {
            showErrorMessage(error.localizedDescription)
        }
        isLoading = false
    }

    // MARK: - Private Methods

    private func showErrorMessage(_ message: String) {
        errorMessage = message
        showError = true
    }

    private func clearFields() {
        email = ""
        password = ""
        confirmPassword = ""
        fullName = ""
    }
}
