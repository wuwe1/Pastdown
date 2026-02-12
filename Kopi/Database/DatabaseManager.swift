import Foundation
import GRDB

final class DatabaseManager: Sendable {
    static let shared = DatabaseManager()

    let dbQueue: DatabaseQueue

    private init() {
        do {
            let directoryURL = Constants.kopiDirectoryURL
            try FileManager.default.createDirectory(at: directoryURL, withIntermediateDirectories: true)

            var config = Configuration()
            config.foreignKeysEnabled = true

            dbQueue = try DatabaseQueue(path: Constants.databaseURL.path, configuration: config)
            try migrator.migrate(dbQueue)
        } catch {
            fatalError("Database initialization failed: \(error)")
        }
    }

    private var migrator: DatabaseMigrator {
        var migrator = DatabaseMigrator()

        migrator.registerMigration("v1_createClipboardItems") { db in
            try db.create(table: "clipboardItems") { t in
                t.autoIncrementedPrimaryKey("id")
                t.column("content", .text).notNull()
                t.column("contentType", .text).defaults(to: "text")
                t.column("preview", .text)
                t.column("isPinned", .boolean).notNull().defaults(to: true)
                t.column("createdAt", .datetime).notNull()
                t.column("updatedAt", .datetime).notNull()
                t.column("hash", .text).notNull().unique()
            }

            try db.create(
                index: "idx_clipboardItems_isPinned_createdAt",
                on: "clipboardItems",
                columns: ["isPinned", "createdAt"]
            )
        }

        migrator.registerMigration("v2_addBlobSupport") { db in
            try db.alter(table: "clipboardItems") { t in
                t.add(column: "blobData", .blob)
                t.add(column: "thumbnailData", .blob)
                t.add(column: "sourceApp", .text)
            }
        }

        return migrator
    }
}
