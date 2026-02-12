import SwiftUI

@main
struct KopiApp: App {
    @State private var viewModel = ClipboardViewModel()

    var body: some Scene {
        MenuBarExtra {
            ContentView(viewModel: viewModel)
                .frame(width: 340)
                .frame(maxHeight: 500)
        } label: {
            Image("MenuBarIcon")
                .renderingMode(.template)
        }
        .menuBarExtraStyle(.window)

        Window("Kopi Settings", id: "settings") {
            SettingsView(viewModel: viewModel)
        }
        .windowResizability(.contentSize)
        .defaultPosition(.center)
    }
}
