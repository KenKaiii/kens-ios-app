import Foundation
import SwiftData

/// Sample SwiftData model
/// Replace/extend with your own models
@Model
final class SampleItem {

    // MARK: - Properties

    @Attribute(.unique) var id: UUID
    var name: String
    var itemDescription: String?
    var createdAt: Date
    var updatedAt: Date
    var isFavorite: Bool

    // MARK: - Relationships

    // Example: @Relationship(deleteRule: .cascade) var children: [ChildItem]?

    // MARK: - Initialization

    init(
        id: UUID = UUID(),
        name: String,
        itemDescription: String? = nil,
        isFavorite: Bool = false
    ) {
        self.id = id
        self.name = name
        self.itemDescription = itemDescription
        self.createdAt = Date()
        self.updatedAt = Date()
        self.isFavorite = isFavorite
    }

    // MARK: - Methods

    // swiftlint:disable:next discouraged_optional_boolean
    func update(name: String? = nil, description: String? = nil, setFavorite: Bool? = nil) {
        if let name = name {
            self.name = name
        }
        if let description = description {
            self.itemDescription = description
        }
        if let setFavorite = setFavorite {
            self.isFavorite = setFavorite
        }
        self.updatedAt = Date()
    }
}

// MARK: - Hashable Conformance (for NavigationStack)

extension SampleItem: Hashable {
    static func == (lhs: SampleItem, rhs: SampleItem) -> Bool {
        lhs.id == rhs.id
    }

    func hash(into hasher: inout Hasher) {
        hasher.combine(id)
    }
}

// MARK: - Preview Data

extension SampleItem {
    static var preview: SampleItem {
        SampleItem(
            name: "Sample Item",
            itemDescription: "This is a sample item for previews",
            isFavorite: true
        )
    }

    static var previewList: [SampleItem] {
        [
            SampleItem(name: "First Item", itemDescription: "Description 1"),
            SampleItem(name: "Second Item", itemDescription: "Description 2", isFavorite: true),
            SampleItem(name: "Third Item", itemDescription: "Description 3")
        ]
    }
}
