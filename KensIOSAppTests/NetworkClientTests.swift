@testable import KensIOSApp
import XCTest

/// Tests for NetworkClient
final class NetworkClientTests: XCTestCase {

    // MARK: - Properties

    private var mockSession: URLSession?

    // MARK: - Setup & Teardown

    override func setUp() {
        super.setUp()

        let config = URLSessionConfiguration.ephemeral
        config.protocolClasses = [MockURLProtocol.self]
        mockSession = URLSession(configuration: config)
    }

    override func tearDown() {
        mockSession = nil
        MockURLProtocol.requestHandler = nil
        super.tearDown()
    }

    // MARK: - Tests

    func testSuccessfulRequest() async throws {
        guard let session = mockSession else {
            XCTFail("Mock session not initialized")
            return
        }

        // Given
        let expectedData = Data("""
        {"id": "123", "name": "Test"}
        """.utf8)

        MockURLProtocol.requestHandler = { request in
            guard let url = request.url else {
                throw URLError(.badURL)
            }
            guard let response = HTTPURLResponse(
                url: url,
                statusCode: 200,
                httpVersion: nil,
                headerFields: nil
            ) else {
                throw URLError(.badServerResponse)
            }
            return (response, expectedData)
        }

        let client = NetworkClient(session: session)

        // When
        struct TestResponse: Decodable {
            let id: String
            let name: String
        }

        let result = try await client.request(
            MockEndpoint.test,
            responseType: TestResponse.self
        )

        // Then
        XCTAssertEqual(result.id, "123")
        XCTAssertEqual(result.name, "Test")
    }

    func testUnauthorizedError() async {
        guard let session = mockSession else {
            XCTFail("Mock session not initialized")
            return
        }

        // Given
        MockURLProtocol.requestHandler = { request in
            guard let url = request.url else {
                throw URLError(.badURL)
            }
            guard let response = HTTPURLResponse(
                url: url,
                statusCode: 401,
                httpVersion: nil,
                headerFields: nil
            ) else {
                throw URLError(.badServerResponse)
            }
            return (response, Data())
        }

        let client = NetworkClient(session: session)

        // When/Then
        do {
            let _: EmptyResponse = try await client.request(
                MockEndpoint.test,
                responseType: EmptyResponse.self
            )
            XCTFail("Expected unauthorized error")
        } catch let error as NetworkError {
            XCTAssertEqual(error, .unauthorized)
        } catch {
            XCTFail("Unexpected error type: \(error)")
        }
    }

    func testServerError() async {
        guard let session = mockSession else {
            XCTFail("Mock session not initialized")
            return
        }

        // Given
        MockURLProtocol.requestHandler = { request in
            guard let url = request.url else {
                throw URLError(.badURL)
            }
            guard let response = HTTPURLResponse(
                url: url,
                statusCode: 500,
                httpVersion: nil,
                headerFields: nil
            ) else {
                throw URLError(.badServerResponse)
            }
            return (response, Data())
        }

        let client = NetworkClient(session: session)

        // When/Then
        do {
            let _: EmptyResponse = try await client.request(
                MockEndpoint.test,
                responseType: EmptyResponse.self
            )
            XCTFail("Expected server error")
        } catch let error as NetworkError {
            if case .serverError(let code) = error {
                XCTAssertEqual(code, 500)
            } else {
                XCTFail("Expected server error")
            }
        } catch {
            XCTFail("Unexpected error type: \(error)")
        }
    }
}

// MARK: - Mock Endpoint

enum MockEndpoint: Endpoint {
    case test

    var path: String { "/test" }
    var method: HTTPMethod { .get }
}

// MARK: - Mock URL Protocol

final class MockURLProtocol: URLProtocol {

    static var requestHandler: ((URLRequest) throws -> (HTTPURLResponse, Data))?

    override static func canInit(with request: URLRequest) -> Bool {
        true
    }

    override static func canonicalRequest(for request: URLRequest) -> URLRequest {
        request
    }

    override func startLoading() {
        guard let handler = MockURLProtocol.requestHandler else {
            fatalError("Handler not set")
        }

        do {
            let (response, data) = try handler(request)
            client?.urlProtocol(self, didReceive: response, cacheStoragePolicy: .notAllowed)
            client?.urlProtocol(self, didLoad: data)
            client?.urlProtocolDidFinishLoading(self)
        } catch {
            client?.urlProtocol(self, didFailWithError: error)
        }
    }

    override func stopLoading() {}
}

// MARK: - NetworkError Equatable

extension NetworkError: Equatable {
    public static func == (lhs: NetworkError, rhs: NetworkError) -> Bool {
        switch (lhs, rhs) {
        case (.invalidURL, .invalidURL),
             (.invalidResponse, .invalidResponse),
             (.unauthorized, .unauthorized),
             (.forbidden, .forbidden),
             (.notFound, .notFound),
             (.noInternetConnection, .noInternetConnection),
             (.timeout, .timeout):
            return true
        case let (.clientError(lhsCode), .clientError(rhsCode)),
             let (.serverError(lhsCode), .serverError(rhsCode)),
             let (.unknown(lhsCode), .unknown(rhsCode)):
            return lhsCode == rhsCode
        default:
            return false
        }
    }
}
