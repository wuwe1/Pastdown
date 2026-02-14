import SwiftUI

struct SettingsView: View {
    @Bindable var viewModel: ClipboardViewModel
    @State private var settings = AppSettings.shared
    @State private var showClearConfirmation = false

    var body: some View {
        Form {
            Section("General") {
                HStack {
                    Text("Max Items")
                    Spacer()
                    Picker("", selection: $settings.maxItems) {
                        Text("25").tag(25)
                        Text("50").tag(50)
                        Text("100").tag(100)
                        Text("200").tag(200)
                    }
                    .pickerStyle(.menu)
                    .frame(width: 100)
                }

                Toggle("Launch at Login", isOn: Binding(
                    get: { settings.launchAtLogin },
                    set: { newValue in
                        settings.launchAtLogin = newValue
                        viewModel.updateLaunchAtLogin()
                    }
                ))
            }

            Section("Clipboard Monitoring") {
                Toggle("Auto-monitor clipboard", isOn: Binding(
                    get: { settings.autoMonitorEnabled },
                    set: { newValue in
                        settings.autoMonitorEnabled = newValue
                        viewModel.updateMonitoringState()
                    }
                ))

                Text("When enabled, all copied content is automatically saved. When disabled, only manually pinned items are saved.")
                    .font(.caption)
                    .foregroundStyle(.secondary)
            }

            Section("Data") {
                Button("Clear All History") {
                    showClearConfirmation = true
                }
                .foregroundStyle(.red)

                Text("Database: Application Support/Pastdown/")
                    .font(.caption)
                    .foregroundStyle(.secondary)
            }
        }
        .formStyle(.grouped)
        .scrollContentBackground(.hidden)
        .frame(width: 380, height: 320)
        .background(.ultraThinMaterial)
        .alert("Clear All History?", isPresented: $showClearConfirmation) {
            Button("Cancel", role: .cancel) {}
            Button("Clear All", role: .destructive) {
                viewModel.clearAllItems()
            }
        } message: {
            Text("This will permanently delete all saved clipboard items.")
        }
    }
}
