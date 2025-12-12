import SwiftUI
import SwiftData

/// Main entry point for the application
/// Uses SwiftUI App lifecycle with SwiftData integration
@main
struct BoilerplateApp: App {

    // MARK: - Properties

    @UIApplicationDelegateAdaptor(AppDelegate.self) private var appDelegate
    @StateObject private var router = Router()
    @StateObject private var themeManager = ThemeManager()

    /// SwiftData model container for persistence
    private let modelContainer: ModelContainer

    // MARK: - Initialization

    init() {
        // Initialize SwiftData container
        do {
            let schema = Schema([
                // Add your SwiftData models here
                SampleItem.self
            ])
            let modelConfiguration = ModelConfiguration(
                schema: schema,
                isStoredInMemoryOnly: false,
                cloudKitDatabase: .none // Change to .automatic for iCloud sync
            )
            modelContainer = try ModelContainer(
                for: schema,
                configurations: [modelConfiguration]
            )
        } catch {
            fatalError("Failed to initialize SwiftData container: \(error)")
        }

        // Configure dependencies
        DependencyContainer.shared.register()

        // Log app launch
        Log.info("App launched - Environment: \(AppEnvironment.current.name)")
    }

    // MARK: - Body

    var body: some Scene {
        WindowGroup {
            RootView()
                .environmentObject(router)
                .environmentObject(themeManager)
                .preferredColorScheme(themeManager.colorScheme)
                .modelContainer(modelContainer)
                .onAppear {
                    configureAppearance()
                }
        }
    }

    // MARK: - Private Methods

    private func configureAppearance() {
        // Configure any global appearance settings here
    }
}
