import Foundation
import AppKit

final class HTMLToMarkdown: Sendable {
    static let shared = HTMLToMarkdown()

    private init() {}

    /// Convert HTML string to Markdown using NSAttributedString (WebKit-based HTML parsing)
    func convert(_ html: String) -> String? {
        guard let data = html.data(using: .utf8) else { return nil }

        // Parse HTML into NSAttributedString (uses WebKit internally)
        // Must run on main thread as it uses WebKit
        let attrStr: NSAttributedString?
        if Thread.isMainThread {
            attrStr = Self.parseHTML(data)
        } else {
            attrStr = DispatchQueue.main.sync { Self.parseHTML(data) }
        }

        guard let attrStr else { return nil }
        return buildMarkdown(from: attrStr)
    }

    private static func parseHTML(_ data: Data) -> NSAttributedString? {
        try? NSAttributedString(
            data: data,
            options: [
                .documentType: NSAttributedString.DocumentType.html,
                .characterEncoding: String.Encoding.utf8.rawValue,
            ],
            documentAttributes: nil
        )
    }

    // MARK: - Attributed String → Markdown

    private func buildMarkdown(from attrStr: NSAttributedString) -> String {
        var segments: [String] = []
        let fullRange = NSRange(location: 0, length: attrStr.length)
        let string = attrStr.string as NSString

        attrStr.enumerateAttributes(in: fullRange, options: []) { attrs, range, _ in
            var text = string.substring(with: range)
            if text.isEmpty { return }

            let font = attrs[.font] as? NSFont
            let traits = font?.fontDescriptor.symbolicTraits ?? []
            let isBold = traits.contains(.bold)
            let isItalic = traits.contains(.italic)
            let isMono = traits.contains(.monoSpace)

            // Detect heading by font size (typical HTML heading sizes)
            let fontSize = font?.pointSize ?? 12
            let headingLevel = Self.detectHeadingLevel(fontSize: fontSize, isBold: isBold)

            // Check if this is a link
            let linkURL: String? = {
                if let url = attrs[.link] as? URL { return url.absoluteString }
                if let str = attrs[.link] as? String { return str }
                return nil
            }()

            // Check for strikethrough
            let isStrikethrough = (attrs[.strikethroughStyle] as? Int ?? 0) != 0

            // Build the segment
            let trimmedText = text.trimmingCharacters(in: .newlines)
            let hasLeadingNewline = text.hasPrefix("\n")
            let hasTrailingNewline = text.hasSuffix("\n")

            // Process inline text (non-newline parts)
            if !trimmedText.isEmpty {
                var processed = trimmedText

                // Apply inline formatting
                if let url = linkURL {
                    processed = "[\(processed)](\(url))"
                }

                if isMono && !processed.contains("\n") {
                    processed = "`\(processed)`"
                }

                if isStrikethrough {
                    processed = "~~\(processed)~~"
                }

                if isBold && isItalic {
                    processed = "***\(processed)***"
                } else if isBold && headingLevel == 0 {
                    processed = "**\(processed)**"
                } else if isItalic {
                    processed = "*\(processed)*"
                }

                // Apply heading prefix
                if headingLevel > 0 {
                    let prefix = String(repeating: "#", count: headingLevel)
                    processed = "\(prefix) \(processed)"
                }

                text = (hasLeadingNewline ? "\n" : "") + processed + (hasTrailingNewline ? "\n" : "")
            }

            segments.append(text)
        }

        var result = segments.joined()

        // Convert bullet list markers: \t•\t → -
        result = result.replacingOccurrences(of: "\t•\t", with: "- ")
        // Convert numbered list markers: \t1.\t etc.
        result = result.replacingOccurrences(of: "\t(\\d+\\.)\t", with: "$1 ", options: .regularExpression)

        // Clean up: collapse 3+ newlines to 2
        result = result.replacingOccurrences(of: "\n{3,}", with: "\n\n", options: .regularExpression)

        // Clean up empty bold/italic markers
        result = result.replacingOccurrences(of: "\\*{2,3}\\s*\\*{2,3}", with: "", options: .regularExpression)

        return result.trimmingCharacters(in: .whitespacesAndNewlines)
    }

    /// Detect heading level based on font size.
    /// Typical browser rendering: h1≈32pt, h2≈24pt, h3≈18pt, h4≈16pt, h5≈13pt, h6≈10pt, body≈12-16pt
    private static func detectHeadingLevel(fontSize: CGFloat, isBold: Bool) -> Int {
        guard isBold else { return 0 }
        if fontSize >= 28 { return 1 }
        if fontSize >= 22 { return 2 }
        if fontSize >= 18 { return 3 }
        if fontSize >= 16 { return 4 }
        return 0
    }

    // MARK: - Strip HTML to plain text

    static func stripHTMLTags(_ html: String) -> String {
        guard let data = html.data(using: .utf8) else {
            return html.replacingOccurrences(of: "<[^>]+>", with: "", options: .regularExpression)
        }

        if let attributed = try? NSAttributedString(
            data: data,
            options: [
                .documentType: NSAttributedString.DocumentType.html,
                .characterEncoding: String.Encoding.utf8.rawValue,
            ],
            documentAttributes: nil
        ) {
            return attributed.string
        }

        return html.replacingOccurrences(of: "<[^>]+>", with: "", options: .regularExpression)
    }
}
