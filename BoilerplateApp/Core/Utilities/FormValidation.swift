import Foundation

// Form validation utilities
// Based on patterns from swift-form-validation and FormStateKit

// MARK: - Validation Rule

/// A validation rule that can validate a value of type T
public struct ValidationRule<T> {
    public let id: String
    public let message: String
    public let validate: (T) -> Bool

    public init(
        id: String = UUID().uuidString,
        message: String,
        validate: @escaping (T) -> Bool
    ) {
        self.id = id
        self.message = message
        self.validate = validate
    }
}

// MARK: - Common String Rules

extension ValidationRule where T == String {
    /// Validates that string is not empty
    public static func notEmpty(message: String = "This field is required") -> ValidationRule {
        ValidationRule(id: "notEmpty", message: message) { !$0.trimmed.isEmpty }
    }

    /// Validates minimum length
    public static func minLength(_ length: Int, message: String? = nil) -> ValidationRule {
        ValidationRule(
            id: "minLength",
            message: message ?? "Must be at least \(length) characters"
        ) { $0.count >= length }
    }

    /// Validates maximum length
    public static func maxLength(_ length: Int, message: String? = nil) -> ValidationRule {
        ValidationRule(
            id: "maxLength",
            message: message ?? "Must be no more than \(length) characters"
        ) { $0.count <= length }
    }

    /// Validates email format
    public static func email(message: String = "Please enter a valid email") -> ValidationRule {
        ValidationRule(id: "email", message: message) { $0.isValidEmail }
    }

    /// Validates against a regex pattern
    public static func regex(_ pattern: String, message: String) -> ValidationRule {
        ValidationRule(id: "regex", message: message) { value in
            value.range(of: pattern, options: .regularExpression) != nil
        }
    }

    /// Validates that string matches another string
    public static func matches(
        _ other: @escaping () -> String,
        message: String = "Values do not match"
    ) -> ValidationRule {
        ValidationRule(id: "matches", message: message) { $0 == other() }
    }

    /// Validates password strength (at least 8 chars, 1 uppercase, 1 lowercase, 1 number)
    public static func strongPassword(
        message: String = "Password must be at least 8 characters with uppercase, lowercase, and number"
    ) -> ValidationRule {
        ValidationRule(id: "strongPassword", message: message) { password in
            guard password.count >= 8 else { return false }
            let hasUppercase = password.range(of: "[A-Z]", options: .regularExpression) != nil
            let hasLowercase = password.range(of: "[a-z]", options: .regularExpression) != nil
            let hasNumber = password.range(of: "[0-9]", options: .regularExpression) != nil
            return hasUppercase && hasLowercase && hasNumber
        }
    }
}

// MARK: - Common Optional Rules

extension ValidationRule {
    /// Creates a rule that allows nil values
    public static func optional<U>(_ rule: ValidationRule<U>) -> ValidationRule<U?> {
        ValidationRule<U?>(id: rule.id, message: rule.message) { value in
            guard let value else { return true }
            return rule.validate(value)
        }
    }
}

// MARK: - Field Validator

/// Validates a single field with multiple rules
public struct FieldValidator<T> {
    private let rules: [ValidationRule<T>]

    public init(rules: [ValidationRule<T>]) {
        self.rules = rules
    }

    /// Validates the value and returns the first error message if invalid
    public func validate(_ value: T) -> String? {
        for rule in rules where !rule.validate(value) {
            return rule.message
        }
        return nil
    }

    /// Returns true if all rules pass
    public func isValid(_ value: T) -> Bool {
        validate(value) == nil
    }

    /// Returns all error messages for failed rules
    public func allErrors(_ value: T) -> [String] {
        rules.compactMap { rule in
            rule.validate(value) ? nil : rule.message
        }
    }
}

// MARK: - Form Validator

/// Validates multiple fields in a form
@Observable
public final class FormValidator {
    public var errors: [String: String] = [:]

    public init() {}

    /// Validates a field and stores any error
    @discardableResult
    public func validate<T>(
        _ value: T,
        field: String,
        rules: [ValidationRule<T>]
    ) -> Bool {
        let validator = FieldValidator(rules: rules)
        if let error = validator.validate(value) {
            errors[field] = error
            return false
        } else {
            errors.removeValue(forKey: field)
            return true
        }
    }

    /// Returns the error message for a field
    public func error(for field: String) -> String? {
        errors[field]
    }

    /// Returns true if the form has no errors
    public var isValid: Bool {
        errors.isEmpty
    }

    /// Clears all errors
    public func clearErrors() {
        errors.removeAll()
    }
}

// MARK: - View Extension

import SwiftUI

extension View {
    /// Shows an error message below the view if validation fails
    public func validationError(_ error: String?) -> some View {
        VStack(alignment: .leading, spacing: 4) {
            self
            if let error {
                Text(error)
                    .font(.caption)
                    .foregroundStyle(.red)
                    .transition(.opacity.combined(with: .move(edge: .top)))
            }
        }
        .animation(.easeInOut(duration: 0.2), value: error)
    }
}
