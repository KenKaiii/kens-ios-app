import SwiftUI

/// Onboarding view with page-based navigation
/// Based on patterns from Mozilla Firefox iOS, Trust Wallet, and Ulry
struct OnboardingView: View {

    // MARK: - Properties

    @Environment(\.dismiss) private var dismiss
    @State private var currentPage = 0

    let pages: [OnboardingPage]
    let onComplete: () -> Void

    // MARK: - Initialization

    init(
        pages: [OnboardingPage] = OnboardingPage.defaultPages,
        onComplete: @escaping () -> Void
    ) {
        self.pages = pages
        self.onComplete = onComplete
    }

    // MARK: - Body

    var body: some View {
        VStack(spacing: 0) {
            // Skip button
            skipButton

            // Page content
            TabView(selection: $currentPage) {
                ForEach(Array(pages.enumerated()), id: \.element.id) { index, page in
                    OnboardingPageView(page: page)
                        .tag(index)
                }
            }
            .tabViewStyle(.page(indexDisplayMode: .never))
            .animation(.easeInOut, value: currentPage)

            // Bottom controls
            bottomControls
        }
        .background(Color(.systemBackground))
    }

    // MARK: - Subviews

    private var skipButton: some View {
        HStack {
            Spacer()
            Button("Skip") {
                completeOnboarding()
            }
            .font(.subheadline)
            .foregroundStyle(.secondary)
            .padding()
        }
        .opacity(isLastPage ? 0 : 1)
    }

    private var bottomControls: some View {
        VStack(spacing: 24) {
            // Page indicator
            PageIndicator(
                numberOfPages: pages.count,
                currentPage: currentPage
            )

            // Action button
            Button {
                if isLastPage {
                    completeOnboarding()
                } else {
                    withAnimation {
                        currentPage += 1
                    }
                }
            } label: {
                Text(isLastPage ? "Get Started" : "Continue")
                    .font(.headline)
                    .foregroundStyle(.white)
                    .frame(maxWidth: .infinity)
                    .padding(.vertical, 16)
                    .background(Color.accentColor, in: RoundedRectangle(cornerRadius: 14))
            }
            .padding(.horizontal, 24)
        }
        .padding(.bottom, 40)
    }

    // MARK: - Helpers

    private var isLastPage: Bool {
        currentPage == pages.count - 1
    }

    private func completeOnboarding() {
        onComplete()
        dismiss()
    }
}

// MARK: - Onboarding Page View

private struct OnboardingPageView: View {
    let page: OnboardingPage

    var body: some View {
        VStack(spacing: 32) {
            Spacer()

            // Image
            Group {
                if page.imageIsSystemName {
                    Image(systemName: page.imageName)
                        .font(.system(size: 80))
                        .foregroundStyle(.tint)
                } else {
                    Image(page.imageName)
                        .resizable()
                        .scaledToFit()
                }
            }
            .frame(height: 120)

            // Text content
            VStack(spacing: 16) {
                Text(page.title)
                    .font(.title)
                    .fontWeight(.bold)
                    .multilineTextAlignment(.center)

                Text(page.description)
                    .font(.body)
                    .foregroundStyle(.secondary)
                    .multilineTextAlignment(.center)
                    .padding(.horizontal, 32)
            }

            Spacer()
            Spacer()
        }
        .padding(.horizontal, 24)
    }
}

// MARK: - Page Indicator

private struct PageIndicator: View {
    let numberOfPages: Int
    let currentPage: Int

    var body: some View {
        HStack(spacing: 8) {
            ForEach(0..<numberOfPages, id: \.self) { index in
                Circle()
                    .fill(index == currentPage ? Color.accentColor : Color.secondary.opacity(0.3))
                    .frame(width: 8, height: 8)
                    .scaleEffect(index == currentPage ? 1.2 : 1.0)
                    .animation(.easeInOut(duration: 0.2), value: currentPage)
            }
        }
    }
}

// MARK: - Preview

#Preview {
    OnboardingView(onComplete: {})
}
