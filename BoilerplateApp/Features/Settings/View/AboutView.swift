import SwiftUI

/// About screen with app information
struct AboutView: View {

    // MARK: - Body

    var body: some View {
        List {
            appInfoSection
            linksSection
            legalSection
        }
        .navigationTitle("About")
        .navigationBarTitleDisplayMode(.inline)
    }

    // MARK: - Sections

    private var appInfoSection: some View {
        Section {
            VStack(spacing: 16) {
                Image(systemName: "app.fill")
                    .font(.system(size: 60))
                    .foregroundStyle(.tint)

                Text("BoilerplateApp")
                    .font(.title2)
                    .fontWeight(.semibold)

                Text("A modern iOS app boilerplate built with SwiftUI")
                    .font(.subheadline)
                    .foregroundStyle(.secondary)
                    .multilineTextAlignment(.center)
            }
            .frame(maxWidth: .infinity)
            .padding(.vertical, 20)
        }
    }

    private var linksSection: some View {
        Section("Links") {
            if let githubURL = URL(string: "https://github.com") {
                Link(destination: githubURL) {
                    Label("GitHub Repository", systemImage: "link")
                }
            }

            if let appleURL = URL(string: "https://developer.apple.com") {
                Link(destination: appleURL) {
                    Label("Apple Developer", systemImage: "apple.logo")
                }
            }
        }
    }

    private var legalSection: some View {
        Section("Legal") {
            NavigationLink {
                LegalTextView(
                    title: "Privacy Policy",
                    text: privacyPolicyText
                )
            } label: {
                Label("Privacy Policy", systemImage: "hand.raised")
            }

            NavigationLink {
                LegalTextView(
                    title: "Terms of Service",
                    text: termsOfServiceText
                )
            } label: {
                Label("Terms of Service", systemImage: "doc.text")
            }
        }
    }

    // MARK: - Legal Text

    private var privacyPolicyText: String {
        """
        Privacy Policy

        Last updated: [Date]

        Your privacy is important to us. This policy explains how we collect, use, and protect your information.

        [Add your privacy policy content here]

        Contact us at: privacy@example.com
        """
    }

    private var termsOfServiceText: String {
        """
        Terms of Service

        Last updated: [Date]

        By using this app, you agree to these terms.

        [Add your terms of service content here]

        Contact us at: legal@example.com
        """
    }
}

// MARK: - Legal Text View

struct LegalTextView: View {
    let title: String
    let text: String

    var body: some View {
        ScrollView {
            Text(text)
                .padding()
        }
        .navigationTitle(title)
        .navigationBarTitleDisplayMode(.inline)
    }
}

// MARK: - Preview

#Preview {
    NavigationStack {
        AboutView()
    }
}
