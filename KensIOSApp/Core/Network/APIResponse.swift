import Foundation

/// Generic API response wrapper
struct APIResponse<T: Decodable>: Decodable {
    let success: Bool
    let data: T?
    let message: String?
    let errors: [APIError]?
}

/// API error detail
struct APIError: Decodable {
    let code: String
    let message: String
    let field: String?
}

/// Paginated response wrapper
struct PaginatedResponse<T: Decodable>: Decodable {
    let items: [T]
    let pagination: PaginationInfo
}

/// Pagination metadata
struct PaginationInfo: Decodable {
    let currentPage: Int
    let totalPages: Int
    let totalItems: Int
    let itemsPerPage: Int

    var hasNextPage: Bool {
        currentPage < totalPages
    }

    var hasPreviousPage: Bool {
        currentPage > 1
    }
}

/// Empty response for endpoints that return no data
struct EmptyResponse: Decodable {}
