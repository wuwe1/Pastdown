import Foundation
import SwiftUI

struct MarkdownHighlighter {

    // MARK: - Colors

    private static let h1Color = Color(red: 0.85, green: 0.35, blue: 0.2)   // deep orange-red
    private static let h2Color = Color(red: 0.9, green: 0.45, blue: 0.2)    // orange
    private static let h3Color = Color(red: 0.9, green: 0.55, blue: 0.25)   // lighter orange
    private static let h4Color = Color(red: 0.85, green: 0.6, blue: 0.3)    // warm amber
    private static let boldColor = Color(red: 0.9, green: 0.5, blue: 0.2)   // orange-brown
    private static let italicColor = Color(red: 0.7, green: 0.55, blue: 0.8) // lavender
    private static let linkColor = Color.blue
    private static let codeColor = Color(red: 0.6, green: 0.8, blue: 0.6)   // soft green
    private static let listMarkerColor = Color(red: 0.6, green: 0.6, blue: 0.9) // soft blue
    private static let hrColor = Color.secondary

    // MARK: - Font sizes

    private static let baseSize: CGFloat = 12
    private static let h1Size: CGFloat = 20
    private static let h2Size: CGFloat = 17
    private static let h3Size: CGFloat = 14.5
    private static let h4Size: CGFloat = 13

    // MARK: - Public API

    static func highlight(_ markdown: String) -> AttributedString {
        var lines = markdown.components(separatedBy: "\n")
        var result = AttributedString()
        var inCodeBlock = false

        for (index, line) in lines.enumerated() {
            var attrLine: AttributedString

            // Fenced code block toggle
            if line.hasPrefix("```") {
                inCodeBlock.toggle()
                var codeFence = AttributedString(line)
                codeFence.foregroundColor = codeColor
                codeFence.font = .system(size: baseSize, design: .monospaced)
                attrLine = codeFence
            } else if inCodeBlock {
                var codeLine = AttributedString(line)
                codeLine.foregroundColor = codeColor
                codeLine.font = .system(size: baseSize, design: .monospaced)
                attrLine = codeLine
            } else {
                attrLine = highlightLine(line)
            }

            result.append(attrLine)
            if index < lines.count - 1 {
                result.append(AttributedString("\n"))
            }
        }

        return result
    }

    // MARK: - Line-level highlighting

    private static func highlightLine(_ line: String) -> AttributedString {
        // Horizontal rule
        let trimmed = line.trimmingCharacters(in: .whitespaces)
        if trimmed == "---" || trimmed == "***" || trimmed == "___" {
            var attr = AttributedString(line)
            attr.foregroundColor = hrColor
            attr.font = .system(size: baseSize, design: .monospaced)
            return attr
        }

        // Headings
        if let headingMatch = trimmed.prefixMatch(of: /^(#{1,6})\s+(.+)$/) {
            let level = headingMatch.output.1.count
            let prefix = String(headingMatch.output.1) + " "
            let content = String(headingMatch.output.2)

            let (color, size, _) = headingStyle(level: level)

            var attrPrefix = AttributedString(prefix)
            attrPrefix.foregroundColor = color.opacity(0.6)
            attrPrefix.font = .system(size: size, weight: .bold, design: .monospaced)

            var attrContent = highlightInline(content)
            attrContent.foregroundColor = color
            attrContent.font = .system(size: size, weight: .bold, design: .monospaced)

            var result = attrPrefix
            result.append(attrContent)
            return result
        }

        // List items (- or * or digit.)
        if let listMatch = trimmed.prefixMatch(of: /^([-*]|\d+\.)\s+/) {
            let marker = String(listMatch.output.0)
            let content = String(trimmed.dropFirst(marker.count))
            let leadingSpaces = String(line.prefix(while: { $0 == " " || $0 == "\t" }))

            var attrMarker = AttributedString(leadingSpaces + marker)
            attrMarker.foregroundColor = listMarkerColor
            attrMarker.font = .system(size: baseSize, design: .monospaced)

            let attrContent = highlightInline(content)

            var result = attrMarker
            result.append(attrContent)
            return result
        }

        // Blockquote
        if trimmed.hasPrefix(">") {
            let content = String(trimmed.dropFirst(trimmed.hasPrefix("> ") ? 2 : 1))
            var attrMarker = AttributedString("> ")
            attrMarker.foregroundColor = .secondary
            attrMarker.font = .system(size: baseSize, design: .monospaced)

            var attrContent = highlightInline(content)
            attrContent.foregroundColor = .secondary

            var result = attrMarker
            result.append(attrContent)
            return result
        }

        // Regular line — apply inline highlighting
        return highlightInline(line)
    }

    // MARK: - Inline highlighting

    private static func highlightInline(_ text: String) -> AttributedString {
        // Build a list of styled ranges, then compose the attributed string
        var segments: [(range: Range<String.Index>, style: InlineStyle)] = []

        // Inline code: `code`
        findMatches(in: text, pattern: /`([^`]+)`/) { matchRange in
            segments.append((matchRange, .code))
        }

        // Bold + italic: ***text*** or ___text___
        findMatches(in: text, pattern: /\*{3}(.+?)\*{3}/) { matchRange in
            if !overlaps(matchRange, with: segments) {
                segments.append((matchRange, .boldItalic))
            }
        }

        // Bold: **text** or __text__
        findMatches(in: text, pattern: /\*{2}(.+?)\*{2}/) { matchRange in
            if !overlaps(matchRange, with: segments) {
                segments.append((matchRange, .bold))
            }
        }

        // Italic: *text* (single asterisk, not part of ** or ***)
        findMatches(in: text, pattern: /(?:^|[^*])\*([^*]+)\*(?:[^*]|$)/) { matchRange in
            if !overlaps(matchRange, with: segments) {
                segments.append((matchRange, .italic))
            }
        }

        // Links: [text](url)
        findMatches(in: text, pattern: /\[([^\]]+)\]\(([^)]+)\)/) { matchRange in
            if !overlaps(matchRange, with: segments) {
                segments.append((matchRange, .link))
            }
        }

        // Sort segments by position
        segments.sort { $0.range.lowerBound < $1.range.lowerBound }

        // Build attributed string
        var result = AttributedString()
        var currentIndex = text.startIndex

        for segment in segments {
            // Add plain text before this segment
            if currentIndex < segment.range.lowerBound {
                var plain = AttributedString(String(text[currentIndex..<segment.range.lowerBound]))
                plain.font = .system(size: baseSize, design: .monospaced)
                result.append(plain)
            }

            let matchedText = String(text[segment.range])
            let styled = applyStyle(segment.style, to: matchedText)
            result.append(styled)

            currentIndex = segment.range.upperBound
        }

        // Remaining plain text
        if currentIndex < text.endIndex {
            var plain = AttributedString(String(text[currentIndex...]))
            plain.font = .system(size: baseSize, design: .monospaced)
            result.append(plain)
        }

        return result
    }

    // MARK: - Style application

    private enum InlineStyle {
        case bold, italic, boldItalic, code, link
    }

    private static func applyStyle(_ style: InlineStyle, to text: String) -> AttributedString {
        var attr = AttributedString(text)

        switch style {
        case .bold:
            attr.font = .system(size: baseSize, weight: .bold, design: .monospaced)
            attr.foregroundColor = boldColor
        case .italic:
            attr.font = .system(size: baseSize, design: .monospaced).italic()
            attr.foregroundColor = italicColor
        case .boldItalic:
            attr.font = .system(size: baseSize, weight: .bold, design: .monospaced).italic()
            attr.foregroundColor = boldColor
        case .code:
            attr.font = .system(size: baseSize, design: .monospaced)
            attr.foregroundColor = codeColor
            attr.backgroundColor = codeColor.opacity(0.1)
        case .link:
            attr.font = .system(size: baseSize, design: .monospaced)
            attr.foregroundColor = linkColor
        }

        return attr
    }

    // MARK: - Heading style

    private static func headingStyle(level: Int) -> (Color, CGFloat, Font.Weight) {
        switch level {
        case 1: return (h1Color, h1Size, .bold)
        case 2: return (h2Color, h2Size, .bold)
        case 3: return (h3Color, h3Size, .bold)
        default: return (h4Color, h4Size, .bold)
        }
    }

    // MARK: - Regex helpers

    private static func findMatches(
        in text: String,
        pattern: some RegexComponent,
        handler: (Range<String.Index>) -> Void
    ) {
        for match in text.matches(of: pattern) {
            handler(match.range)
        }
    }

    private static func overlaps(_ range: Range<String.Index>, with segments: [(range: Range<String.Index>, style: InlineStyle)]) -> Bool {
        segments.contains { existing in
            existing.range.overlaps(range)
        }
    }
}
