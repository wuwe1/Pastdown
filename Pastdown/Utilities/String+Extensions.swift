import Foundation
import CryptoKit

extension String {
    var sha256Hash: String {
        let data = Data(self.utf8)
        let hash = SHA256.hash(data: data)
        return hash.compactMap { String(format: "%02x", $0) }.joined()
    }

    func truncated(to maxLength: Int = Constants.previewMaxLength) -> String {
        if count <= maxLength { return self }
        return String(prefix(maxLength)) + "..."
    }

    var trimmedPreview: String {
        let trimmed = trimmingCharacters(in: .whitespacesAndNewlines)
        let singleLine = trimmed.components(separatedBy: .newlines)
            .map { $0.trimmingCharacters(in: .whitespaces) }
            .joined(separator: " ")
        return singleLine.truncated()
    }
}

extension Data {
    var sha256Hash: String {
        let hash = SHA256.hash(data: self)
        return hash.compactMap { String(format: "%02x", $0) }.joined()
    }
}
