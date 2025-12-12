import SwiftUI

/// Login screen
/// Based on patterns from Firebase examples, Twitter Clone, and Stripe Firebase
struct LoginView: View {

    // MARK: - Properties

    @Environment(\.dismiss) private var dismiss
    @State private var viewModel = AuthViewModel()
    @State private var showSignup = false
    @State private var showForgotPassword = false

    // MARK: - Body

    var body: some View {
        NavigationStack {
            ScrollView {
                VStack(spacing: 32) {
                    // Logo/Header
                    headerSection

                    // Form fields
                    formSection

                    // Login button
                    loginButton

                    // Divider
                    dividerSection

                    // Social login options
                    socialLoginSection

                    // Sign up link
                    signupLink
                }
                .padding(.horizontal, 24)
                .padding(.vertical, 40)
            }
            .navigationTitle("Sign In")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .cancellationAction) {
                    Button("Cancel") {
                        dismiss()
                    }
                }
            }
            .alert("Error", isPresented: $viewModel.showError) {
                Button("OK", role: .cancel) {}
            } message: {
                Text(viewModel.errorMessage ?? "An error occurred")
            }
            .sheet(isPresented: $showSignup) {
                SignupView()
            }
            .sheet(isPresented: $showForgotPassword) {
                ForgotPasswordView()
            }
        }
    }

    // MARK: - Subviews

    private var headerSection: some View {
        VStack(spacing: 16) {
            Image(systemName: "person.circle.fill")
                .font(.system(size: 80))
                .foregroundStyle(.tint)

            Text("Welcome Back")
                .font(.title2)
                .fontWeight(.bold)

            Text("Sign in to continue")
                .font(.subheadline)
                .foregroundStyle(.secondary)
        }
        .padding(.bottom, 16)
    }

    private var formSection: some View {
        VStack(spacing: 16) {
            // Email field
            AuthTextField(
                text: $viewModel.email,
                placeholder: "Email",
                systemImage: "envelope",
                keyboardType: .emailAddress,
                textContentType: .emailAddress,
                autocapitalization: .never
            )

            // Password field
            AuthSecureField(
                text: $viewModel.password,
                placeholder: "Password",
                systemImage: "lock",
                textContentType: .password
            )

            // Forgot password
            HStack {
                Spacer()
                Button("Forgot Password?") {
                    showForgotPassword = true
                }
                .font(.footnote)
                .foregroundStyle(.tint)
            }
        }
    }

    private var loginButton: some View {
        Button {
            Task {
                await viewModel.login()
            }
        } label: {
            Group {
                if viewModel.isLoading {
                    ProgressView()
                        .tint(.white)
                } else {
                    Text("Sign In")
                        .fontWeight(.semibold)
                }
            }
            .frame(maxWidth: .infinity)
            .padding(.vertical, 16)
            .background(viewModel.isLoginValid ? Color.accentColor : Color.gray.opacity(0.5))
            .foregroundStyle(.white)
            .clipShape(RoundedRectangle(cornerRadius: 12))
        }
        .disabled(!viewModel.isLoginValid || viewModel.isLoading)
    }

    private var dividerSection: some View {
        HStack {
            Rectangle()
                .fill(Color.secondary.opacity(0.3))
                .frame(height: 1)

            Text("or")
                .font(.footnote)
                .foregroundStyle(.secondary)
                .padding(.horizontal, 8)

            Rectangle()
                .fill(Color.secondary.opacity(0.3))
                .frame(height: 1)
        }
    }

    private var socialLoginSection: some View {
        VStack(spacing: 12) {
            SocialLoginButton(
                title: "Continue with Apple",
                systemImage: "apple.logo",
                backgroundColor: .primary
            ) {
                // Handle Apple Sign In
            }

            SocialLoginButton(
                title: "Continue with Google",
                systemImage: "globe",
                backgroundColor: .blue
            ) {
                // Handle Google Sign In
            }
        }
    }

    private var signupLink: some View {
        HStack {
            Text("Don't have an account?")
                .foregroundStyle(.secondary)

            Button("Sign Up") {
                showSignup = true
            }
            .fontWeight(.semibold)
        }
        .font(.subheadline)
    }
}

// MARK: - Social Login Button

private struct SocialLoginButton: View {
    let title: String
    let systemImage: String
    let backgroundColor: Color
    let action: () -> Void

    var body: some View {
        Button(action: action) {
            HStack(spacing: 12) {
                Image(systemName: systemImage)
                    .font(.title3)
                Text(title)
                    .fontWeight(.medium)
            }
            .frame(maxWidth: .infinity)
            .padding(.vertical, 14)
            .foregroundStyle(backgroundColor == .primary ? Color(.systemBackground) : .white)
            .background(backgroundColor)
            .clipShape(RoundedRectangle(cornerRadius: 12))
        }
    }
}

// MARK: - Preview

#Preview {
    LoginView()
}
