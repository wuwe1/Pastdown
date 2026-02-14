import Foundation
import Combine

@MainActor @Observable
final class AppSettings {
    static let shared = AppSettings()

    var maxItems: Int {
        didSet { UserDefaults.standard.set(maxItems, forKey: Constants.SettingsKeys.maxItems) }
    }

    var autoMonitorEnabled: Bool {
        didSet { UserDefaults.standard.set(autoMonitorEnabled, forKey: Constants.SettingsKeys.autoMonitorEnabled) }
    }

    var pollingInterval: TimeInterval {
        didSet { UserDefaults.standard.set(pollingInterval, forKey: Constants.SettingsKeys.pollingInterval) }
    }

    var launchAtLogin: Bool {
        didSet { UserDefaults.standard.set(launchAtLogin, forKey: Constants.SettingsKeys.launchAtLogin) }
    }

    private init() {
        let defaults = UserDefaults.standard

        if defaults.object(forKey: Constants.SettingsKeys.maxItems) == nil {
            defaults.set(Constants.defaultMaxItems, forKey: Constants.SettingsKeys.maxItems)
        }
        if defaults.object(forKey: Constants.SettingsKeys.pollingInterval) == nil {
            defaults.set(Constants.defaultPollingInterval, forKey: Constants.SettingsKeys.pollingInterval)
        }

        self.maxItems = defaults.integer(forKey: Constants.SettingsKeys.maxItems)
        self.autoMonitorEnabled = defaults.bool(forKey: Constants.SettingsKeys.autoMonitorEnabled)
        self.pollingInterval = defaults.double(forKey: Constants.SettingsKeys.pollingInterval)
        self.launchAtLogin = defaults.bool(forKey: Constants.SettingsKeys.launchAtLogin)
    }
}
