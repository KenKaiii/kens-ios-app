import Foundation

/// Modern async/await network client using URLSession
/// Provides type-safe API requests with automatic encoding/decoding
actor NetworkClient {

    // MARK: - Singleton

    static let shared = NetworkClient()

    // MARK: - Properties

    private let session: URLSession
    private let decoder: JSONDecoder
    private let encoder: JSONEncoder

    /// Auth token for authenticated requests
    private var authToken: String?

    // MARK: - Initialization

    init(session: URLSession = .shared) {
        self.session = session

        self.decoder = JSONDecoder()
        decoder.keyDecodingStrategy = .convertFromSnakeCase
        decoder.dateDecodingStrategy = .iso8601

        self.encoder = JSONEncoder()
        encoder.keyEncodingStrategy = .convertToSnakeCase
        encoder.dateEncodingStrategy = .iso8601
    }

    // MARK: - Auth Token Management

    func setAuthToken(_ token: String?) {
        self.authToken = token
    }

    // MARK: - Request Methods

    /// Performs a network request and decodes the response
    func request<T: Decodable>(
        _ endpoint: Endpoint,
        responseType: T.Type
    ) async throws -> T {
        let request = try buildRequest(for: endpoint)
        Log.network("[\(endpoint.method.rawValue)] \(endpoint.path)")

        let (data, response) = try await session.data(for: request)

        try validateResponse(response)

        do {
            return try decoder.decode(T.self, from: data)
        } catch {
            Log.error("Decoding error: \(error)")
            throw NetworkError.decodingError(error)
        }
    }

    /// Performs a network request without expecting a response body
    func request(_ endpoint: Endpoint) async throws {
        let request = try buildRequest(for: endpoint)
        Log.network("[\(endpoint.method.rawValue)] \(endpoint.path)")

        let (_, response) = try await session.data(for: request)
        try validateResponse(response)
    }

    /// Uploads data to an endpoint
    func upload<T: Decodable>(
        _ endpoint: Endpoint,
        data: Data,
        responseType: T.Type
    ) async throws -> T {
        var request = try buildRequest(for: endpoint)
        request.httpBody = data

        Log.network("[UPLOAD] \(endpoint.path)")

        let (responseData, response) = try await session.data(for: request)

        try validateResponse(response)

        return try decoder.decode(T.self, from: responseData)
    }

    /// Downloads data from a URL
    func download(from url: URL) async throws -> Data {
        Log.network("[DOWNLOAD] \(url.absoluteString)")

        let (data, response) = try await session.data(from: url)

        try validateResponse(response)

        return data
    }

    // MARK: - Private Methods

    private func buildRequest(for endpoint: Endpoint) throws -> URLRequest {
        guard let url = URL(string: endpoint.path, relativeTo: endpoint.baseURL) else {
            throw NetworkError.invalidURL
        }

        var components = URLComponents(url: url, resolvingAgainstBaseURL: true)

        // Add query parameters
        if let queryParams = endpoint.queryParameters, !queryParams.isEmpty {
            components?.queryItems = queryParams.map {
                URLQueryItem(name: $0.key, value: $0.value)
            }
        }

        guard let finalURL = components?.url else {
            throw NetworkError.invalidURL
        }

        var request = URLRequest(url: finalURL)
        request.httpMethod = endpoint.method.rawValue
        request.timeoutInterval = AppEnvironment.current.apiTimeoutInterval

        // Set headers
        request.setValue("application/json", forHTTPHeaderField: "Content-Type")
        request.setValue("application/json", forHTTPHeaderField: "Accept")

        // Add auth token if available
        if let token = authToken {
            request.setValue("Bearer \(token)", forHTTPHeaderField: "Authorization")
        }

        // Add custom headers
        endpoint.headers?.forEach { key, value in
            request.setValue(value, forHTTPHeaderField: key)
        }

        // Set body
        if let body = endpoint.body {
            request.httpBody = try encoder.encode(body)
        }

        return request
    }

    private func validateResponse(_ response: URLResponse) throws {
        guard let httpResponse = response as? HTTPURLResponse else {
            throw NetworkError.invalidResponse
        }

        switch httpResponse.statusCode {
        case 200...299:
            return
        case 401:
            throw NetworkError.unauthorized
        case 403:
            throw NetworkError.forbidden
        case 404:
            throw NetworkError.notFound
        case 400...499:
            throw NetworkError.clientError(httpResponse.statusCode)
        case 500...599:
            throw NetworkError.serverError(httpResponse.statusCode)
        default:
            throw NetworkError.unknown(httpResponse.statusCode)
        }
    }
}
