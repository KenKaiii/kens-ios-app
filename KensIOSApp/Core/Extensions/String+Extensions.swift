import Foundation

extension String {

    // MARK: - Validation

    /// Check if string is a valid email
    var isValidEmail: Bool {
        let emailRegex = #"^[A-Z0-9a-z._%+-]+@[A-Za-z0-9.-]+\.[A-Za-z]{2,64}$"#
        return range(of: emailRegex, options: .regularExpression) != nil
    }

    /// Check if string contains only alphanumeric characters
    var isAlphanumeric: Bool {
        !isEmpty && range(of: "[^a-zA-Z0-9]", options: .regularExpression) == nil
    }

    /// Check if string is a valid URL
    var isValidURL: Bool {
        URL(string: self) != nil
    }

    // MARK: - Transformations

    /// Trim whitespace and newlines
    var trimmed: String {
        trimmingCharacters(in: .whitespacesAndNewlines)
    }

    /// Convert to URL if valid
    var asURL: URL? {
        URL(string: self)
    }

    /// Capitalize first letter only
    var capitalizedFirst: String {
        prefix(1).capitalized + dropFirst()
    }

    /// Remove all whitespace
    var withoutWhitespace: String {
        replacingOccurrences(of: " ", with: "")
    }

    // MARK: - Localization

    /// Return localized string
    var localized: String {
        NSLocalizedString(self, comment: "")
    }

    /// Return localized string with arguments
    func localized(with arguments: CVarArg...) -> String {
        String(format: localized, arguments: arguments)
    }

    // MARK: - Nil/Empty Helpers

    /// Returns nil if string is empty
    var nilIfEmpty: String? {
        isEmpty ? nil : self
    }

    /// Returns nil if string is empty or whitespace only
    var nilIfBlank: String? {
        trimmed.isEmpty ? nil : self
    }

    // MARK: - Substring

    /// Safe subscript access
    subscript(safe index: Int) -> Character? {
        guard index >= 0 && index < count else { return nil }
        return self[self.index(startIndex, offsetBy: index)]
    }

    /// Safe range subscript access
    subscript(safe range: Range<Int>) -> String? {
        guard range.lowerBound >= 0,
              range.upperBound <= count else {
            return nil
        }
        let start = index(startIndex, offsetBy: range.lowerBound)
        let end = index(startIndex, offsetBy: range.upperBound)
        return String(self[start..<end])
    }
}

// MARK: - Optional String Extensions

extension Optional where Wrapped == String {

    /// Returns true if nil or empty
    var isNilOrEmpty: Bool {
        self?.isEmpty ?? true
    }

    /// Returns true if nil, empty, or whitespace only
    var isNilOrBlank: Bool {
        self?.trimmed.isEmpty ?? true
    }

    /// Returns the string or empty string if nil
    var orEmpty: String {
        self ?? ""
    }
}
