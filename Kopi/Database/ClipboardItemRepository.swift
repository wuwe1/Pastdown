import Foundation
import GRDB
import Combine

final class ClipboardItemRepository {
    private let dbQueue: DatabaseQueue

    init(dbQueue: DatabaseQueue = DatabaseManager.shared.dbQueue) {
        self.dbQueue = dbQueue
    }

    // MARK: - Create / Upsert

    @discardableResult
    func pinItem(from clipboardContent: ClipboardContent, thumbnailData: Data? = nil) throws -> ClipboardItem {
        let hash = Self.computeHash(for: clipboardContent)

        return try dbQueue.write { db in
            if var existing = try ClipboardItem.filter(ClipboardItem.Columns.hash == hash).fetchOne(db) {
                existing.updatedAt = Date()
                existing.isPinned = true
                try existing.update(db)
                return existing
            } else {
                var item = ClipboardItem(
                    content: clipboardContent.textContent ?? "",
                    contentType: clipboardContent.contentType,
                    isPinned: true,
                    blobData: clipboardContent.blobData,
                    thumbnailData: thumbnailData,
                    sourceApp: clipboardContent.sourceApp
                )
                try item.insert(db)
                return item
            }
        }
    }

    @discardableResult
    func saveItem(from clipboardContent: ClipboardContent, thumbnailData: Data? = nil) throws -> ClipboardItem {
        let hash = Self.computeHash(for: clipboardContent)

        return try dbQueue.write { db in
            if var existing = try ClipboardItem.filter(ClipboardItem.Columns.hash == hash).fetchOne(db) {
                existing.updatedAt = Date()
                try existing.update(db)
                return existing
            } else {
                var item = ClipboardItem(
                    content: clipboardContent.textContent ?? "",
                    contentType: clipboardContent.contentType,
                    isPinned: false,
                    blobData: clipboardContent.blobData,
                    thumbnailData: thumbnailData,
                    sourceApp: clipboardContent.sourceApp
                )
                try item.insert(db)
                return item
            }
        }
    }

    // MARK: - Hash Computation

    private static func computeHash(for content: ClipboardContent) -> String {
        if let blobData = content.blobData, content.contentType == "image" {
            return blobData.sha256Hash
        }
        return (content.textContent ?? "").sha256Hash
    }

    // MARK: - Read

    func fetchPinnedItems(limit: Int = Constants.defaultMaxItems) throws -> [ClipboardItem] {
        try dbQueue.read { db in
            try ClipboardItem
                .filter(ClipboardItem.Columns.isPinned == true)
                .order(ClipboardItem.Columns.updatedAt.desc)
                .limit(limit)
                .fetchAll(db)
        }
    }

    func fetchAllItems(limit: Int = Constants.defaultMaxItems) throws -> [ClipboardItem] {
        try dbQueue.read { db in
            try ClipboardItem
                .order(ClipboardItem.Columns.updatedAt.desc)
                .limit(limit)
                .fetchAll(db)
        }
    }

    // MARK: - Delete

    func deleteItem(_ item: ClipboardItem) throws {
        try dbQueue.write { db in
            _ = try item.delete(db)
        }
    }

    func deleteAllPinnedItems() throws {
        try dbQueue.write { db in
            _ = try ClipboardItem.filter(ClipboardItem.Columns.isPinned == true).deleteAll(db)
        }
    }

    func deleteAllItems() throws {
        try dbQueue.write { db in
            _ = try ClipboardItem.deleteAll(db)
        }
    }

    // MARK: - Enforce Max Items

    func enforceMaxItems(_ maxItems: Int) throws {
        try dbQueue.write { db in
            let count = try ClipboardItem.fetchCount(db)
            if count > maxItems {
                let excess = count - maxItems
                let oldestItems = try ClipboardItem
                    .order(ClipboardItem.Columns.updatedAt.asc)
                    .limit(excess)
                    .fetchAll(db)
                for item in oldestItems {
                    _ = try item.delete(db)
                }
            }
        }
    }

    // MARK: - ValueObservation

    func observeAllItems(
        in dbQueue: DatabaseQueue,
        limit: Int = Constants.defaultMaxItems,
        onChange: @escaping ([ClipboardItem]) -> Void
    ) -> AnyDatabaseCancellable {
        let observation = ValueObservation.tracking { db in
            try ClipboardItem
                .order(ClipboardItem.Columns.updatedAt.desc)
                .limit(limit)
                .fetchAll(db)
        }
        return observation.start(
            in: dbQueue,
            onError: { error in print("Observation error: \(error)") },
            onChange: onChange
        )
    }
}
