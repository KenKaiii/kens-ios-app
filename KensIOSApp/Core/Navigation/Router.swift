import SwiftUI

/// Centralized navigation router using NavigationStack
/// Manages all navigation paths and provides type-safe routing
@MainActor
final class Router: ObservableObject {

    // MARK: - Navigation Paths

    /// Navigation path for Home tab
    @Published var homePath = NavigationPath()

    /// Navigation path for Settings tab
    @Published var settingsPath = NavigationPath()

    // MARK: - Sheet & FullScreenCover State

    @Published var presentedSheet: Route?
    @Published var presentedFullScreen: Route?

    // MARK: - Navigation Methods

    /// Push a route onto the current navigation stack
    func push(_ route: Route, on tab: Tab = .home) {
        switch tab {
        case .home:
            homePath.append(route)
        case .settings:
            settingsPath.append(route)
        }
    }

    /// Pop the top view from the current navigation stack
    func pop(on tab: Tab = .home) {
        switch tab {
        case .home:
            guard !homePath.isEmpty else { return }
            homePath.removeLast()
        case .settings:
            guard !settingsPath.isEmpty else { return }
            settingsPath.removeLast()
        }
    }

    /// Pop to root of the current navigation stack
    func popToRoot(on tab: Tab = .home) {
        switch tab {
        case .home:
            homePath = NavigationPath()
        case .settings:
            settingsPath = NavigationPath()
        }
    }

    /// Present a sheet
    func presentSheet(_ route: Route) {
        presentedSheet = route
    }

    /// Dismiss the current sheet
    func dismissSheet() {
        presentedSheet = nil
    }

    /// Present a full screen cover
    func presentFullScreen(_ route: Route) {
        presentedFullScreen = route
    }

    /// Dismiss the current full screen cover
    func dismissFullScreen() {
        presentedFullScreen = nil
    }

    // MARK: - Destination Builder

    /// Returns the destination view for a given route
    @ViewBuilder
    func destination(for route: Route) -> some View {
        switch route {
        case .detail(let item):
            DetailView(item: item)
        case .profile:
            ProfileView()
        case .about:
            AboutView()
        // Add more routes as needed
        }
    }
}
