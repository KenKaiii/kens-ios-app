import Foundation

extension Task where Success == Never, Failure == Never {

    /// Sleep for a specified number of seconds
    static func sleep(seconds: Double) async throws {
        try await sleep(nanoseconds: UInt64(seconds * 1_000_000_000))
    }

    /// Sleep for a specified number of milliseconds
    static func sleep(milliseconds: Int) async throws {
        try await sleep(nanoseconds: UInt64(milliseconds) * 1_000_000)
    }
}

// MARK: - Async Helpers

/// Execute an async operation with a timeout
func withTimeout<T>(
    seconds: TimeInterval,
    operation: @escaping () async throws -> T
) async throws -> T {
    try await withThrowingTaskGroup(of: T.self) { group in
        group.addTask {
            try await operation()
        }

        group.addTask {
            try await Task.sleep(seconds: seconds)
            throw TimeoutError()
        }

        guard let result = try await group.next() else {
            throw TimeoutError()
        }
        group.cancelAll()
        return result
    }
}

struct TimeoutError: LocalizedError {
    var errorDescription: String? {
        "Operation timed out"
    }
}

/// Retry an async operation with exponential backoff
func withRetry<T>(
    maxAttempts: Int = 3,
    initialDelay: TimeInterval = 1.0,
    maxDelay: TimeInterval = 30.0,
    multiplier: Double = 2.0,
    operation: @escaping () async throws -> T
) async throws -> T {
    var currentDelay = initialDelay
    var lastError: Error?

    for attempt in 1...maxAttempts {
        do {
            return try await operation()
        } catch {
            lastError = error
            Log.warning("Attempt \(attempt)/\(maxAttempts) failed: \(error.localizedDescription)")

            if attempt < maxAttempts {
                try await Task.sleep(seconds: currentDelay)
                currentDelay = min(currentDelay * multiplier, maxDelay)
            }
        }
    }

    throw lastError ?? RetryError.maxAttemptsExceeded
}

enum RetryError: LocalizedError {
    case maxAttemptsExceeded

    var errorDescription: String? {
        "Maximum retry attempts exceeded"
    }
}

// MARK: - Debounce

actor Debouncer {
    private var task: Task<Void, Never>?
    private let delay: Duration

    init(delay: Duration) {
        self.delay = delay
    }

    func debounce(action: @escaping () async -> Void) {
        task?.cancel()
        task = Task {
            do {
                try await Task.sleep(for: delay)
                guard !Task.isCancelled else { return }
                await action()
            } catch {}
        }
    }
}
