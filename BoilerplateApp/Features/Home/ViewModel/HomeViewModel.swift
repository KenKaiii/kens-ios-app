import Foundation
import SwiftUI

/// ViewModel for HomeView
/// Uses @Observable macro (iOS 17+) for modern state management
@MainActor
@Observable
final class HomeViewModel {

    // MARK: - Published State

    var isLoading = false
    var error: Error?
    var searchText = ""

    // MARK: - Dependencies

    @ObservationIgnored
    @Injected private var networkClient: NetworkClient

    // MARK: - Computed Properties

    var hasError: Bool {
        error != nil
    }

    // MARK: - Methods

    /// Refresh data from remote source
    func refresh() async {
        isLoading = true
        error = nil

        do {
            // Example API call - replace with your actual endpoint
            // let items = try await networkClient.request(SampleAPI.getItems, responseType: [SampleItem].self)
            // Process items...

            // Simulate network delay for demo
            try await Task.sleep(for: .seconds(1))

            Log.info("Home data refreshed successfully")
        } catch {
            self.error = error
            Log.error("Failed to refresh home data", error: error)
        }

        isLoading = false
    }

    /// Clear any error state
    func clearError() {
        error = nil
    }
}

// MARK: - Observable Wrapper for StateObject

/// Wrapper to use @Observable classes with @StateObject
/// Needed because @Observable doesn't conform to ObservableObject
extension HomeViewModel: ObservableObject {}
