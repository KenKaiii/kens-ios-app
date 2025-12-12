import Foundation
import OSLog

/// Centralized logging utility using OSLog
/// Provides categorized logging with environment-aware behavior
enum Log {

    // MARK: - Loggers

    private static let generalLogger = Logger(
        subsystem: Bundle.main.bundleIdentifier ?? "com.app",
        category: "general"
    )

    private static let networkLogger = Logger(
        subsystem: Bundle.main.bundleIdentifier ?? "com.app",
        category: "network"
    )

    private static let uiLogger = Logger(
        subsystem: Bundle.main.bundleIdentifier ?? "com.app",
        category: "ui"
    )

    private static let dataLogger = Logger(
        subsystem: Bundle.main.bundleIdentifier ?? "com.app",
        category: "data"
    )

    // MARK: - Log Levels

    /// Debug level - verbose information for development
    static func debug(
        _ message: String,
        file: String = #file,
        function: String = #function,
        line: Int = #line
    ) {
        guard AppEnvironment.current.isLoggingEnabled else { return }
        let context = formatContext(file: file, function: function, line: line)
        generalLogger.debug("🔍 \(message) \(context)")
    }

    /// Info level - general information
    static func info(
        _ message: String,
        file: String = #file,
        function: String = #function,
        line: Int = #line
    ) {
        guard AppEnvironment.current.isLoggingEnabled else { return }
        let context = formatContext(file: file, function: function, line: line)
        generalLogger.info("ℹ️ \(message) \(context)")
    }

    /// Warning level - potential issues
    static func warning(
        _ message: String,
        file: String = #file,
        function: String = #function,
        line: Int = #line
    ) {
        guard AppEnvironment.current.isLoggingEnabled else { return }
        let context = formatContext(file: file, function: function, line: line)
        generalLogger.warning("⚠️ \(message) \(context)")
    }

    /// Error level - errors that need attention
    static func error(
        _ message: String,
        error: Error? = nil,
        file: String = #file,
        function: String = #function,
        line: Int = #line
    ) {
        let context = formatContext(file: file, function: function, line: line)
        let errorInfo = error.map { " | Error: \($0.localizedDescription)" } ?? ""
        generalLogger.error("❌ \(message)\(errorInfo) \(context)")
    }

    /// Critical level - critical failures
    static func critical(
        _ message: String,
        file: String = #file,
        function: String = #function,
        line: Int = #line
    ) {
        let context = formatContext(file: file, function: function, line: line)
        generalLogger.critical("🚨 \(message) \(context)")
    }

    // MARK: - Specialized Loggers

    /// Network-specific logging
    static func network(
        _ message: String,
        file: String = #file,
        function: String = #function,
        line: Int = #line
    ) {
        guard AppEnvironment.current.isLoggingEnabled else { return }
        let context = formatContext(file: file, function: function, line: line)
        networkLogger.debug("🌐 \(message) \(context)")
    }

    /// UI-specific logging
    static func ui(
        _ message: String,
        file: String = #file,
        function: String = #function,
        line: Int = #line
    ) {
        guard AppEnvironment.current.isLoggingEnabled else { return }
        let context = formatContext(file: file, function: function, line: line)
        uiLogger.debug("🎨 \(message) \(context)")
    }

    /// Data/persistence-specific logging
    static func data(
        _ message: String,
        file: String = #file,
        function: String = #function,
        line: Int = #line
    ) {
        guard AppEnvironment.current.isLoggingEnabled else { return }
        let context = formatContext(file: file, function: function, line: line)
        dataLogger.debug("💾 \(message) \(context)")
    }

    // MARK: - Private Helpers

    private static func formatContext(file: String, function: String, line: Int) -> String {
        let filename = (file as NSString).lastPathComponent
        return "[\(filename):\(line) \(function)]"
    }
}

// MARK: - Performance Logging

extension Log {

    /// Measure execution time of a block
    @discardableResult
    static func measure<T>(
        _ label: String,
        block: () throws -> T
    ) rethrows -> T {
        let start = CFAbsoluteTimeGetCurrent()
        let result = try block()
        let duration = CFAbsoluteTimeGetCurrent() - start
        debug("\(label) completed in \(String(format: "%.3f", duration))s")
        return result
    }

    /// Measure execution time of an async block
    @discardableResult
    static func measureAsync<T>(
        _ label: String,
        block: () async throws -> T
    ) async rethrows -> T {
        let start = CFAbsoluteTimeGetCurrent()
        let result = try await block()
        let duration = CFAbsoluteTimeGetCurrent() - start
        debug("\(label) completed in \(String(format: "%.3f", duration))s")
        return result
    }
}
