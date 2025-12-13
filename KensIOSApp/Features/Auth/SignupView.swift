import SwiftUI

/// Sign up screen
struct SignupView: View {

    // MARK: - Properties

    @Environment(\.dismiss) private var dismiss
    @State private var viewModel = AuthViewModel()
    @State private var agreedToTerms = false

    // MARK: - Body

    var body: some View {
        NavigationStack {
            ScrollView {
                VStack(spacing: 32) {
                    // Header
                    headerSection

                    // Form fields
                    formSection

                    // Terms checkbox
                    termsSection

                    // Sign up button
                    signupButton

                    // Login link
                    loginLink
                }
                .padding(.horizontal, 24)
                .padding(.vertical, 40)
            }
            .navigationTitle("Create Account")
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
        }
    }

    // MARK: - Subviews

    private var headerSection: some View {
        VStack(spacing: 16) {
            Image(systemName: "person.badge.plus.fill")
                .font(.system(size: 80))
                .foregroundStyle(.tint)

            Text("Join Us")
                .font(.title2)
                .fontWeight(.bold)

            Text("Create an account to get started")
                .font(.subheadline)
                .foregroundStyle(.secondary)
        }
        .padding(.bottom, 16)
    }

    private var formSection: some View {
        VStack(spacing: 16) {
            // Full name field
            AuthTextField(
                text: $viewModel.fullName,
                placeholder: "Full Name",
                systemImage: "person",
                textContentType: .name
            )

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
                textContentType: .newPassword
            )

            // Confirm password field
            AuthSecureField(
                text: $viewModel.confirmPassword,
                placeholder: "Confirm Password",
                systemImage: "lock.fill",
                textContentType: .newPassword
            )

            // Password mismatch warning
            if !viewModel.confirmPassword.isEmpty && !viewModel.passwordsMatch {
                HStack {
                    Image(systemName: "exclamationmark.triangle.fill")
                        .foregroundStyle(.orange)
                    Text("Passwords do not match")
                        .font(.caption)
                        .foregroundStyle(.orange)
                    Spacer()
                }
            }
        }
    }

    private var termsSection: some View {
        HStack(alignment: .top, spacing: 12) {
            Button {
                agreedToTerms.toggle()
            } label: {
                Image(systemName: agreedToTerms ? "checkmark.square.fill" : "square")
                    .font(.title3)
                    .foregroundStyle(agreedToTerms ? Color.accentColor : Color.secondary)
            }

            Text("I agree to the [Terms of Service](https://example.com/terms) and [Privacy Policy](https://example.com/privacy)")
                .font(.footnote)
                .foregroundStyle(.secondary)
                .tint(.accentColor)
        }
    }

    private var signupButton: some View {
        Button {
            Task {
                await viewModel.signup()
            }
        } label: {
            Group {
                if viewModel.isLoading {
                    ProgressView()
                        .tint(.white)
                } else {
                    Text("Create Account")
                        .fontWeight(.semibold)
                }
            }
            .frame(maxWidth: .infinity)
            .padding(.vertical, 16)
            .background(isFormValid ? Color.accentColor : Color.gray.opacity(0.5))
            .foregroundStyle(.white)
            .clipShape(RoundedRectangle(cornerRadius: 12))
        }
        .disabled(!isFormValid || viewModel.isLoading)
    }

    private var loginLink: some View {
        HStack {
            Text("Already have an account?")
                .foregroundStyle(.secondary)

            Button("Sign In") {
                dismiss()
            }
            .fontWeight(.semibold)
        }
        .font(.subheadline)
    }

    // MARK: - Helpers

    private var isFormValid: Bool {
        viewModel.isSignupValid && agreedToTerms
    }
}

// MARK: - Preview

#Preview {
    SignupView()
}
