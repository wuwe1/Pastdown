import Foundation

enum Constants {
    static let appName = "Pastdown"

    // MARK: - Paths
    static let pastdownDirectoryURL: URL = {
        let appSupport = FileManager.default.urls(for: .applicationSupportDirectory, in: .userDomainMask).first!
        return appSupport.appendingPathComponent("Pastdown", isDirectory: true)
    }()

    static let databaseURL: URL = {
        pastdownDirectoryURL.appendingPathComponent("pastdown.db")
    }()

    // MARK: - Defaults
    static let defaultMaxItems = 50
    static let defaultPollingInterval: TimeInterval = 0.5
    static let previewMaxLength = 100

    // MARK: - UserDefaults Keys
    enum SettingsKeys {
        static let maxItems = "maxItems"
        static let autoMonitorEnabled = "autoMonitorEnabled"
        static let pollingInterval = "pollingInterval"
        static let launchAtLogin = "launchAtLogin"
    }
}
