import Foundation

/// Network-related errors
enum NetworkError: LocalizedError {
    case invalidURL
    case invalidResponse
    case unauthorized
    case forbidden
    case notFound
    case clientError(Int)
    case serverError(Int)
    case decodingError(Error)
    case encodingError(Error)
    case noInternetConnection
    case timeout
    case unknown(Int)

    var errorDescription: String? {
        switch self {
        case .invalidURL:
            return "Invalid URL"
        case .invalidResponse:
            return "Invalid response from server"
        case .unauthorized:
            return "Authentication required"
        case .forbidden:
            return "Access denied"
        case .notFound:
            return "Resource not found"
        case .clientError(let code):
            return "Client error (HTTP \(code))"
        case .serverError(let code):
            return "Server error (HTTP \(code))"
        case .decodingError(let error):
            return "Failed to decode response: \(error.localizedDescription)"
        case .encodingError(let error):
            return "Failed to encode request: \(error.localizedDescription)"
        case .noInternetConnection:
            return "No internet connection"
        case .timeout:
            return "Request timed out"
        case .unknown(let code):
            return "Unknown error (HTTP \(code))"
        }
    }

    var recoverySuggestion: String? {
        switch self {
        case .unauthorized:
            return "Please log in again"
        case .noInternetConnection:
            return "Please check your internet connection"
        case .timeout:
            return "Please try again"
        case .serverError:
            return "Please try again later"
        default:
            return nil
        }
    }

    /// Whether the error is recoverable by retrying
    var isRetryable: Bool {
        switch self {
        case .timeout, .serverError, .noInternetConnection:
            return true
        default:
            return false
        }
    }
}
