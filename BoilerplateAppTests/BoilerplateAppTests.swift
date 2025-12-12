@testable import BoilerplateApp
import SwiftData
import XCTest

/// Main test suite for BoilerplateApp
final class BoilerplateAppTests: XCTestCase {

    // MARK: - Properties

    private var modelContainer: ModelContainer?

    // MARK: - Setup & Teardown

    override func setUpWithError() throws {
        try super.setUpWithError()

        // Create in-memory SwiftData container for testing
        let schema = Schema([SampleItem.self])
        let config = ModelConfiguration(isStoredInMemoryOnly: true)
        modelContainer = try ModelContainer(for: schema, configurations: [config])
    }

    override func tearDownWithError() throws {
        modelContainer = nil
        try super.tearDownWithError()
    }

    // MARK: - Sample Item Tests

    @MainActor
    func testSampleItemCreation() throws {
        guard let container = modelContainer else {
            XCTFail("Model container not initialized")
            return
        }

        let context = container.mainContext
        let item = SampleItem(name: "Test Item", itemDescription: "Test Description")
        context.insert(item)

        XCTAssertEqual(item.name, "Test Item")
        XCTAssertEqual(item.itemDescription, "Test Description")
        XCTAssertFalse(item.isFavorite)
        XCTAssertNotNil(item.createdAt)
    }

    @MainActor
    func testSampleItemUpdate() throws {
        let item = SampleItem(name: "Original")

        item.update(name: "Updated", description: "New Description", setFavorite: true)

        XCTAssertEqual(item.name, "Updated")
        XCTAssertEqual(item.itemDescription, "New Description")
        XCTAssertTrue(item.isFavorite)
        XCTAssertTrue(item.updatedAt >= item.createdAt)
    }

    // MARK: - String Extension Tests

    func testEmailValidation() {
        XCTAssertTrue("test@example.com".isValidEmail)
        XCTAssertTrue("user.name+tag@domain.co.uk".isValidEmail)
        XCTAssertFalse("invalid-email".isValidEmail)
        XCTAssertFalse("@nodomain.com".isValidEmail)
        XCTAssertFalse("".isValidEmail)
    }

    func testStringTrimmed() {
        XCTAssertEqual("  hello  ".trimmed, "hello")
        XCTAssertEqual("\n\ttest\n".trimmed, "test")
        XCTAssertEqual("no-trim".trimmed, "no-trim")
    }

    func testNilIfEmpty() {
        XCTAssertNil("".nilIfEmpty)
        XCTAssertEqual("test".nilIfEmpty, "test")
        XCTAssertNil("   ".nilIfBlank)
    }

    // MARK: - Collection Extension Tests

    func testSafeSubscript() {
        let array = [1, 2, 3]

        XCTAssertEqual(array[safe: 0], 1)
        XCTAssertEqual(array[safe: 2], 3)
        XCTAssertNil(array[safe: 5])
        XCTAssertNil(array[safe: -1])
    }

    func testRemoveDuplicates() {
        let array = [1, 2, 2, 3, 1, 4]
        let uniqued = array.uniqued

        XCTAssertEqual(uniqued, [1, 2, 3, 4])
    }

    func testChunked() {
        let array = [1, 2, 3, 4, 5]
        let chunks = array.chunked(into: 2)

        XCTAssertEqual(chunks.count, 3)
        XCTAssertEqual(chunks[0], [1, 2])
        XCTAssertEqual(chunks[1], [3, 4])
        XCTAssertEqual(chunks[2], [5])
    }

    // MARK: - Date Extension Tests

    func testDateIsToday() {
        XCTAssertTrue(Date().isToday)
        XCTAssertFalse(Date().adding(days: -1).isToday)
    }

    func testDateAddingDays() {
        let today = Date()
        let tomorrow = today.adding(days: 1)
        let yesterday = today.adding(days: -1)

        XCTAssertTrue(tomorrow.isFuture)
        XCTAssertTrue(yesterday.isPast)
    }
}
