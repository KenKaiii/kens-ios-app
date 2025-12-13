import SwiftUI

/// Forgot password screen
struct ForgotPasswordView: View {

    // MARK: - Properties

    @Environment(\.dismiss) private var dismiss
    @State private var email = ""
    @State private var isLoading = false
    @State private var showSuccess = false
    @State private var errorMessage: String?
    @State private var showError = false

    @Injected(\.authService) private var authService: AuthServiceProtocol

    // MARK: - Computed Properties

    private var isValidEmail: Bool {
        email.isValidEmail
    }

    // MARK: - Body

    var body: some View {
        NavigationStack {
            VStack(spacing: 32) {
                // Header
                headerSection

                // Email field
                AuthTextField(
                    text: $email,
                    placeholder: "Email",
                    systemImage: "envelope",
                    keyboardType: .emailAddress,
                    textContentType: .emailAddress,
                    autocapitalization: .never
                )

                // Submit button
                submitButton

                Spacer()
            }
            .padding(.horizontal, 24)
            .padding(.vertical, 40)
            .navigationTitle("Reset Password")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .cancellationAction) {
                    Button("Cancel") {
                        dismiss()
                    }
                }
            }
            .alert("Error", isPresented: $showError) {
                Button("OK", role: .cancel) {}
            } message: {
                Text(errorMessage ?? "An error occurred")
            }
            .alert("Email Sent", isPresented: $showSuccess) {
                Button("OK") {
                    dismiss()
                }
            } message: {
                Text("If an account exists with that email, you'll receive a password reset link shortly.")
            }
        }
    }

    // MARK: - Subviews

    private var headerSection: some View {
        VStack(spacing: 16) {
            Image(systemName: "key.fill")
                .font(.system(size: 60))
                .foregroundStyle(.tint)

            Text("Forgot Password?")
                .font(.title2)
                .fontWeight(.bold)

            Text("Enter your email address and we'll send you a link to reset your password.")
                .font(.subheadline)
                .foregroundStyle(.secondary)
                .multilineTextAlignment(.center)
        }
        .padding(.bottom, 16)
    }

    private var submitButton: some View {
        Button {
            Task {
                await sendResetEmail()
            }
        } label: {
            Group {
                if isLoading {
                    ProgressView()
                        .tint(.white)
                } else {
                    Text("Send Reset Link")
                        .fontWeight(.semibold)
                }
            }
            .frame(maxWidth: .infinity)
            .padding(.vertical, 16)
            .background(isValidEmail ? Color.accentColor : Color.gray.opacity(0.5))
            .foregroundStyle(.white)
            .clipShape(RoundedRectangle(cornerRadius: 12))
        }
        .disabled(!isValidEmail || isLoading)
    }

    // MARK: - Methods

    private func sendResetEmail() async {
        isLoading = true

        do {
            try await authService.resetPassword(email: email)
            showSuccess = true
        } catch {
            errorMessage = error.localizedDescription
            showError = true
        }

        isLoading = false
    }
}

// MARK: - Preview

#Preview {
    ForgotPasswordView()
}
