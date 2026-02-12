#if DEBUG
import AppKit
import SwiftUI

@MainActor
enum ScreenshotGenerator {

    @discardableResult
    static func render<V: View>(
        _ view: V,
        size: CGSize,
        scale: CGFloat = 2.0,
        to fileURL: URL
    ) -> Bool {
        let hosted = view.frame(width: size.width, height: size.height)
        let renderer = ImageRenderer(content: hosted)
        renderer.scale = scale

        guard let nsImage = renderer.nsImage,
              let tiffData = nsImage.tiffRepresentation,
              let bitmapRep = NSBitmapImageRep(data: tiffData),
              let pngData = bitmapRep.representation(using: .png, properties: [:])
        else {
            return false
        }

        do {
            try pngData.write(to: fileURL, options: .atomic)
            return true
        } catch {
            return false
        }
    }

    static func generateAll(to directory: URL, scale: CGFloat = 2.0) -> [URL] {
        try? FileManager.default.createDirectory(
            at: directory, withIntermediateDirectories: true
        )

        let scenes: [(view: AnyView, size: CGSize, name: String)] = [
            (
                AnyView(MainListShowcase()),
                CGSize(width: 420, height: 520),
                "screenshot-main.png"
            ),
            (
                AnyView(HTMLDetailShowcase()),
                CGSize(width: 420, height: 520),
                "screenshot-html-detail.png"
            ),
            (
                AnyView(SettingsShowcase()),
                CGSize(width: 460, height: 440),
                "screenshot-settings.png"
            ),
        ]

        var results: [URL] = []
        for scene in scenes {
            let url = directory.appending(path: scene.name)
            if render(scene.view, size: scene.size, scale: scale, to: url) {
                results.append(url)
            }
        }
        return results
    }
}
#endif
