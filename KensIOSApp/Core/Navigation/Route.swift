import Foundation

/// Defines all navigable routes in the application
/// Conform to Hashable for NavigationStack compatibility
enum Route: Hashable {

    // MARK: - Main Routes

    /// Detail view for a specific item
    case detail(item: SampleItem)

    /// User profile view
    case profile

    /// About/Info view
    case about

    // MARK: - Add More Routes

    // Example routes you might add:
    // case itemList(category: String)
    // case search(query: String?)
    // case userProfile(userId: String)
    // case webView(url: URL)
}

// MARK: - Route Metadata

extension Route {

    /// Navigation title for each route
    var title: String {
        switch self {
        case .detail:
            return "Detail"
        case .profile:
            return "Profile"
        case .about:
            return "About"
        }
    }

    /// System image name for each route (optional)
    var systemImage: String? {
        switch self {
        case .detail:
            return "doc.text"
        case .profile:
            return "person.circle"
        case .about:
            return "info.circle"
        }
    }
}
