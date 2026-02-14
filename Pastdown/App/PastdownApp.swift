import SwiftUI

@main
struct PastdownApp: App {
    @State private var viewModel = ClipboardViewModel()

    #if DEBUG
    @NSApplicationDelegateAdaptor(ScreenshotAppDelegate.self) var screenshotDelegate
    #endif

    var body: some Scene {
        MenuBarExtra {
            ContentView(viewModel: viewModel)
        } label: {
            Image("MenuBarIcon")
                .renderingMode(.template)
        }
        .menuBarExtraStyle(.window)

        Window("Pastdown Settings", id: "settings") {
            SettingsView(viewModel: viewModel)
        }
        .windowResizability(.contentSize)
        .defaultPosition(.center)
    }
}

#if DEBUG
class ScreenshotAppDelegate: NSObject, NSApplicationDelegate {
    func applicationDidFinishLaunching(_ notification: Notification) {
        guard ProcessInfo.processInfo.arguments.contains("--generate-screenshots") else { return }

        DispatchQueue.main.asyncAfter(deadline: .now() + 0.5) {
            let outputDir = URL(filePath: ProcessInfo.processInfo.environment["SCREENSHOT_OUTPUT"]
                ?? "/tmp/pastdown-screenshots")
            let urls = ScreenshotGenerator.generateAll(to: outputDir)
            for url in urls {
                print("Generated: \(url.path())")
            }
            NSApplication.shared.terminate(nil)
        }
    }
}
#endif
