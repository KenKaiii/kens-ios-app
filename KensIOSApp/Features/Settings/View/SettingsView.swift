import SwiftUI

/// Settings screen with theme selection and app info
struct SettingsView: View {

    // MARK: - Properties

    @EnvironmentObject private var themeManager: ThemeManager
    @EnvironmentObject private var router: Router
    @AppStorage("isNotificationsEnabled") private var notificationsEnabled = true

    // MARK: - Body

    var body: some View {
        List {
            appearanceSection
            notificationsSection
            aboutSection
            debugSection
        }
        .navigationTitle("Settings")
    }

    // MARK: - Sections

    private var appearanceSection: some View {
        Section("Appearance") {
            Picker("Theme", selection: $themeManager.currentMode) {
                ForEach(ThemeMode.allCases) { mode in
                    Label(mode.displayName, systemImage: mode.icon)
                        .tag(mode)
                }
            }
            .pickerStyle(.navigationLink)
        }
    }

    private var notificationsSection: some View {
        Section("Notifications") {
            Toggle("Enable Notifications", isOn: $notificationsEnabled)
        }
    }

    private var aboutSection: some View {
        Section("About") {
            NavigationLink {
                AboutView()
            } label: {
                Label("About This App", systemImage: "info.circle")
            }

            LabeledContent("Version") {
                Text(appVersion)
            }

            LabeledContent("Build") {
                Text(buildNumber)
            }
        }
    }

    @ViewBuilder
    private var debugSection: some View {
        #if DEBUG
        Section("Debug") {
            LabeledContent("Environment") {
                Text(AppEnvironment.current.name)
                    .foregroundStyle(.secondary)
            }

            Button("Clear All Data", role: .destructive) {
                clearAllData()
            }
        }
        #endif
    }

    // MARK: - Helpers

    private var appVersion: String {
        Bundle.main.infoDictionary?["CFBundleShortVersionString"] as? String ?? "1.0"
    }

    private var buildNumber: String {
        Bundle.main.infoDictionary?["CFBundleVersion"] as? String ?? "1"
    }

    private func clearAllData() {
        // Clear UserDefaults
        UserDefaultsManager().clearAll()

        // Clear Keychain
        try? KeychainManager().deleteAll()

        Log.warning("All app data cleared")
    }
}

// MARK: - Preview

#Preview {
    NavigationStack {
        SettingsView()
    }
    .environmentObject(ThemeManager())
    .environmentObject(Router())
}
