import Foundation
import Network

/// Network connectivity status
public enum NetworkStatus: Equatable {
    case connected
    case disconnected
    case unknown
}

/// Connection type
public enum ConnectionType: Equatable {
    case wifi
    case cellular
    case wiredEthernet
    case unknown
}

/// Monitors network connectivity using NWPathMonitor
/// Based on patterns from omnivore-app, exyte/Chat, and NetNewsWire
@MainActor
public final class NetworkMonitor: ObservableObject {

    // MARK: - Singleton

    public static let shared = NetworkMonitor()

    // MARK: - Published Properties

    @Published public private(set) var status: NetworkStatus = .unknown
    @Published public private(set) var connectionType: ConnectionType = .unknown
    @Published public private(set) var isExpensive: Bool = false
    @Published public private(set) var isConstrained: Bool = false

    // MARK: - Private Properties

    private let monitor: NWPathMonitor
    private let queue: DispatchQueue

    // MARK: - Computed Properties

    public var isConnected: Bool {
        status == .connected
    }

    // MARK: - Initialization

    public init() {
        monitor = NWPathMonitor()
        queue = DispatchQueue(label: "com.app.networkmonitor", qos: .utility)
        startMonitoring()
    }

    deinit {
        monitor.cancel()
    }

    // MARK: - Public Methods

    public func startMonitoring() {
        monitor.pathUpdateHandler = { [weak self] path in
            Task { @MainActor [weak self] in
                self?.updateStatus(from: path)
            }
        }
        monitor.start(queue: queue)
    }

    public func stopMonitoring() {
        monitor.cancel()
    }

    // MARK: - Private Methods

    private func updateStatus(from path: NWPath) {
        // Update connection status
        switch path.status {
        case .satisfied:
            status = .connected
        case .unsatisfied:
            status = .disconnected
        case .requiresConnection:
            status = .disconnected
        @unknown default:
            status = .unknown
        }

        // Update connection type
        if path.usesInterfaceType(.wifi) {
            connectionType = .wifi
        } else if path.usesInterfaceType(.cellular) {
            connectionType = .cellular
        } else if path.usesInterfaceType(.wiredEthernet) {
            connectionType = .wiredEthernet
        } else {
            connectionType = .unknown
        }

        // Update expensive/constrained flags
        isExpensive = path.isExpensive
        isConstrained = path.isConstrained

        Log.debug("Network status: \(status), type: \(connectionType), expensive: \(isExpensive)")
    }
}

// MARK: - SwiftUI Environment

import SwiftUI

private struct NetworkMonitorKey: @preconcurrency EnvironmentKey {
    @MainActor static let defaultValue = NetworkMonitor.shared
}

extension EnvironmentValues {
    @MainActor
    public var networkMonitor: NetworkMonitor {
        get { self[NetworkMonitorKey.self] }
        set { self[NetworkMonitorKey.self] = newValue }
    }
}

// MARK: - View Extension

extension View {
    /// Shows an overlay when network is disconnected
    public func networkUnavailableOverlay() -> some View {
        modifier(NetworkUnavailableModifier())
    }
}

private struct NetworkUnavailableModifier: ViewModifier {
    @StateObject private var networkMonitor = NetworkMonitor.shared

    func body(content: Content) -> some View {
        content
            .overlay(alignment: .top) {
                if !networkMonitor.isConnected {
                    NetworkUnavailableBanner()
                        .transition(.move(edge: .top).combined(with: .opacity))
                }
            }
            .animation(.easeInOut, value: networkMonitor.isConnected)
    }
}

private struct NetworkUnavailableBanner: View {
    var body: some View {
        HStack(spacing: 8) {
            Image(systemName: "wifi.slash")
            Text("No Internet Connection")
                .font(.subheadline)
                .fontWeight(.medium)
        }
        .foregroundStyle(.white)
        .padding(.horizontal, 16)
        .padding(.vertical, 10)
        .background(.red.gradient, in: Capsule())
        .padding(.top, 8)
    }
}
