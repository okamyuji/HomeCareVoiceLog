import Foundation

extension String {
    var normalizedForStorage: String? {
        let trimmed = trimmingCharacters(in: .whitespacesAndNewlines)
        return trimmed.isEmpty ? nil : trimmed
    }
}

extension String? {
    var normalizedForStorage: String? {
        switch self {
        case let .some(value):
            value.normalizedForStorage
        case .none:
            nil
        }
    }
}
