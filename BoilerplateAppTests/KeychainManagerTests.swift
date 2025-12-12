@testable import BoilerplateApp
import XCTest

/// Tests for KeychainManager
final class KeychainManagerTests: XCTestCase {

    // MARK: - Properties

    private var keychain: KeychainManager?

    // MARK: - Setup & Teardown

    override func setUp() {
        super.setUp()
        // Use a unique service identifier for testing
        keychain = KeychainManager(service: "com.test.keychain.\(UUID().uuidString)")
    }

    override func tearDown() {
        // Clean up
        try? keychain?.deleteAll()
        keychain = nil
        super.tearDown()
    }

    // MARK: - String Tests

    func testSaveAndRetrieveString() throws {
        guard let keychain = keychain else {
            XCTFail("Keychain not initialized")
            return
        }

        // Given
        let testValue = "test-token-123"

        // When
        try keychain.save(testValue, for: .accessToken)
        let retrieved = try keychain.getString(for: .accessToken)

        // Then
        XCTAssertEqual(retrieved, testValue)
    }

    func testOverwriteExistingValue() throws {
        guard let keychain = keychain else {
            XCTFail("Keychain not initialized")
            return
        }

        // Given
        try keychain.save("original", for: .accessToken)

        // When
        try keychain.save("updated", for: .accessToken)
        let retrieved = try keychain.getString(for: .accessToken)

        // Then
        XCTAssertEqual(retrieved, "updated")
    }

    // MARK: - Data Tests

    func testSaveAndRetrieveData() throws {
        guard let keychain = keychain else {
            XCTFail("Keychain not initialized")
            return
        }

        // Given
        let testData = Data("test-data".utf8)

        // When
        try keychain.save(testData, for: .accessToken)
        let retrieved = try keychain.getData(for: .accessToken)

        // Then
        XCTAssertEqual(retrieved, testData)
    }

    // MARK: - Codable Tests

    func testSaveAndRetrieveCodable() throws {
        guard let keychain = keychain else {
            XCTFail("Keychain not initialized")
            return
        }

        // Given
        struct TestObject: Codable, Equatable {
            let id: String
            let value: Int
        }
        let testObject = TestObject(id: "test", value: 42)

        // When
        try keychain.save(testObject, for: .userCredentials)
        let retrieved = try keychain.get(TestObject.self, for: .userCredentials)

        // Then
        XCTAssertEqual(retrieved, testObject)
    }

    // MARK: - Existence Tests

    func testExistsReturnsTrueWhenItemExists() throws {
        guard let keychain = keychain else {
            XCTFail("Keychain not initialized")
            return
        }

        // Given
        try keychain.save("test", for: .accessToken)

        // When/Then
        XCTAssertTrue(keychain.exists(.accessToken))
    }

    func testExistsReturnsFalseWhenItemDoesNotExist() {
        guard let keychain = keychain else {
            XCTFail("Keychain not initialized")
            return
        }

        // When/Then
        XCTAssertFalse(keychain.exists(.accessToken))
    }

    // MARK: - Delete Tests

    func testDeleteRemovesItem() throws {
        guard let keychain = keychain else {
            XCTFail("Keychain not initialized")
            return
        }

        // Given
        try keychain.save("test", for: .accessToken)
        XCTAssertTrue(keychain.exists(.accessToken))

        // When
        try keychain.delete(.accessToken)

        // Then
        XCTAssertFalse(keychain.exists(.accessToken))
    }

    func testDeleteNonExistentItemDoesNotThrow() {
        guard let keychain = keychain else {
            XCTFail("Keychain not initialized")
            return
        }

        // When/Then
        XCTAssertNoThrow(try keychain.delete(.accessToken))
    }

    func testDeleteAllRemovesAllItems() throws {
        guard let keychain = keychain else {
            XCTFail("Keychain not initialized")
            return
        }

        // Given
        try keychain.save("token", for: .accessToken)
        try keychain.save("refresh", for: .refreshToken)

        // When
        try keychain.deleteAll()

        // Then
        XCTAssertFalse(keychain.exists(.accessToken))
        XCTAssertFalse(keychain.exists(.refreshToken))
    }

    // MARK: - Error Tests

    func testRetrievingNonExistentItemThrowsNotFound() {
        guard let keychain = keychain else {
            XCTFail("Keychain not initialized")
            return
        }

        // When/Then
        XCTAssertThrowsError(try keychain.getString(for: .accessToken)) { error in
            XCTAssertEqual(error as? KeychainError, .itemNotFound)
        }
    }
}

// MARK: - KeychainError Equatable

extension KeychainError: Equatable {
    public static func == (lhs: KeychainError, rhs: KeychainError) -> Bool {
        switch (lhs, rhs) {
        case (.encodingFailed, .encodingFailed),
             (.decodingFailed, .decodingFailed),
             (.itemNotFound, .itemNotFound),
             (.invalidData, .invalidData):
            return true
        case let (.saveFailed(lhsStatus), .saveFailed(rhsStatus)),
             let (.readFailed(lhsStatus), .readFailed(rhsStatus)),
             let (.deleteFailed(lhsStatus), .deleteFailed(rhsStatus)):
            return lhsStatus == rhsStatus
        default:
            return false
        }
    }
}
