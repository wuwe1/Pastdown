import Foundation
import GRDB

struct ClipboardItem: Identifiable, Equatable, Hashable {
    var id: Int64?
    var content: String
    var contentType: String
    var preview: String
    var isPinned: Bool
    var createdAt: Date
    var updatedAt: Date
    var hash: String
    var blobData: Data?
    var thumbnailData: Data?
    var sourceApp: String?

    init(
        id: Int64? = nil,
        content: String,
        contentType: String = "text",
        isPinned: Bool = true,
        createdAt: Date = Date(),
        updatedAt: Date = Date(),
        blobData: Data? = nil,
        thumbnailData: Data? = nil,
        sourceApp: String? = nil
    ) {
        self.id = id
        self.content = content
        self.contentType = contentType
        self.preview = ClipboardItem.generatePreview(content: content, contentType: contentType)
        self.isPinned = isPinned
        self.createdAt = createdAt
        self.updatedAt = updatedAt
        self.blobData = blobData
        self.thumbnailData = thumbnailData
        self.sourceApp = sourceApp

        if let blobData, contentType == "image" {
            self.hash = blobData.sha256Hash
        } else {
            self.hash = content.sha256Hash
        }
    }

    static func generatePreview(content: String, contentType: String) -> String {
        switch contentType {
        case "image":
            return "Image"
        case "file":
            let url = URL(fileURLWithPath: content)
            return url.lastPathComponent
        case "color":
            return content
        default:
            return content.trimmedPreview
        }
    }
}

// MARK: - GRDB Codable Record

extension ClipboardItem: Codable, FetchableRecord, MutablePersistableRecord {
    static let databaseTableName = "clipboardItems"

    enum Columns: String, ColumnExpression {
        case id, content, contentType, preview, isPinned, createdAt, updatedAt, hash
        case blobData, thumbnailData, sourceApp
    }

    mutating func didInsert(_ inserted: InsertionSuccess) {
        id = inserted.rowID
    }
}
