import Foundation

extension Collection {

    /// Safe subscript access - returns nil if index is out of bounds
    subscript(safe index: Index) -> Element? {
        indices.contains(index) ? self[index] : nil
    }

    /// Returns the collection or nil if empty
    var nilIfEmpty: Self? {
        isEmpty ? nil : self
    }
}

extension Array {

    /// Remove duplicates while preserving order
    func removingDuplicates<T: Hashable>(by keyPath: KeyPath<Element, T>) -> [Element] {
        var seen = Set<T>()
        return filter { element in
            let key = element[keyPath: keyPath]
            return seen.insert(key).inserted
        }
    }

    /// Split array into chunks of specified size
    func chunked(into size: Int) -> [[Element]] {
        stride(from: 0, to: count, by: size).map {
            Array(self[$0..<Swift.min($0 + size, count)])
        }
    }

    /// Move element from one index to another
    mutating func move(from source: Int, to destination: Int) {
        guard source != destination,
              indices.contains(source),
              indices.contains(destination) else {
            return
        }
        insert(remove(at: source), at: destination)
    }
}

extension Array where Element: Equatable {

    /// Remove duplicates while preserving order
    var uniqued: [Element] {
        var result: [Element] = []
        for element in self where !result.contains(element) {
            result.append(element)
        }
        return result
    }

    /// Remove first occurrence of element
    mutating func removeFirst(_ element: Element) {
        if let index = firstIndex(of: element) {
            remove(at: index)
        }
    }
}

extension Dictionary {

    /// Merge two dictionaries
    func merged(with other: [Key: Value]) -> [Key: Value] {
        var result = self
        other.forEach { result[$0.key] = $0.value }
        return result
    }

    /// Compact map values, removing nil results
    func compactMapValues<T>(_ transform: (Value) -> T?) -> [Key: T] {
        reduce(into: [:]) { result, pair in
            if let value = transform(pair.value) {
                result[pair.key] = value
            }
        }
    }
}

extension Set {

    /// Toggle element in set (add if not present, remove if present)
    mutating func toggle(_ element: Element) {
        if contains(element) {
            remove(element)
        } else {
            insert(element)
        }
    }
}
