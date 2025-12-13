import SwiftUI

/// Root view that handles main navigation and tab structure
struct RootView: View {

    // MARK: - Properties

    @EnvironmentObject private var router: Router
    @EnvironmentObject private var themeManager: ThemeManager
    @State private var selectedTab: Tab = .home

    // MARK: - Body

    var body: some View {
        TabView(selection: $selectedTab) {
            homeTab
            settingsTab
        }
        .tint(themeManager.accentColor)
    }

    // MARK: - Tabs

    private var homeTab: some View {
        NavigationStack(path: $router.homePath) {
            HomeView()
                .navigationDestination(for: Route.self) { route in
                    router.destination(for: route)
                }
        }
        .tabItem {
            Label("Home", systemImage: "house.fill")
        }
        .tag(Tab.home)
    }

    private var settingsTab: some View {
        NavigationStack(path: $router.settingsPath) {
            SettingsView()
                .navigationDestination(for: Route.self) { route in
                    router.destination(for: route)
                }
        }
        .tabItem {
            Label("Settings", systemImage: "gear")
        }
        .tag(Tab.settings)
    }
}

// MARK: - Tab Enum

enum Tab: Hashable {
    case home
    case settings
}

// MARK: - Preview

#Preview {
    RootView()
        .environmentObject(Router())
        .environmentObject(ThemeManager())
}
