import Foundation

/// Protocol defining an API endpoint
protocol Endpoint {
    /// Base URL for the endpoint (defaults to environment base URL)
    var baseURL: URL { get }

    /// Path component of the URL
    var path: String { get }

    /// HTTP method
    var method: HTTPMethod { get }

    /// Optional request body
    var body: Encodable? { get }

    /// Optional query parameters
    var queryParameters: [String: String]? { get }

    /// Optional custom headers
    var headers: [String: String]? { get }
}

// MARK: - Default Implementations

extension Endpoint {
    var baseURL: URL {
        AppEnvironment.current.baseURL
    }

    var body: Encodable? { nil }
    var queryParameters: [String: String]? { nil }
    var headers: [String: String]? { nil }
}

// MARK: - HTTP Method

enum HTTPMethod: String {
    case get = "GET"
    case post = "POST"
    case put = "PUT"
    case patch = "PATCH"
    case delete = "DELETE"
}

// MARK: - Sample API Endpoints

/// Example endpoint definitions
enum SampleAPI: Endpoint {

    case getItems
    case getItem(id: String)
    case createItem(CreateItemRequest)
    case updateItem(id: String, UpdateItemRequest)
    case deleteItem(id: String)

    var path: String {
        switch self {
        case .getItems:
            return "/items"
        case .getItem(let id):
            return "/items/\(id)"
        case .createItem:
            return "/items"
        case .updateItem(let id, _):
            return "/items/\(id)"
        case .deleteItem(let id):
            return "/items/\(id)"
        }
    }

    var method: HTTPMethod {
        switch self {
        case .getItems, .getItem:
            return .get
        case .createItem:
            return .post
        case .updateItem:
            return .put
        case .deleteItem:
            return .delete
        }
    }

    var body: Encodable? {
        switch self {
        case .createItem(let request):
            return request
        case .updateItem(_, let request):
            return request
        default:
            return nil
        }
    }
}

// MARK: - Request Models

struct CreateItemRequest: Encodable {
    let name: String
    let description: String?
}

struct UpdateItemRequest: Encodable {
    let name: String?
    let description: String?
}
