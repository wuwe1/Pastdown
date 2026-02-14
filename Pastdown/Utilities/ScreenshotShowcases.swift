#if DEBUG
import SwiftUI

// MARK: - Mock Data

@MainActor
enum ScreenshotMockData {

    static let mockItems: [ClipboardItem] = [
        ClipboardItem(
            id: 1,
            content: "https://developer.apple.com/documentation/swiftui",
            contentType: "url",
            isPinned: true,
            createdAt: Date().addingTimeInterval(-120),
            updatedAt: Date().addingTimeInterval(-120)
        ),
        ClipboardItem(
            id: 2,
            content: "Image",
            contentType: "image",
            isPinned: true,
            createdAt: Date().addingTimeInterval(-300),
            updatedAt: Date().addingTimeInterval(-300),
            thumbnailData: createMockThumbnail()
        ),
        ClipboardItem(
            id: 3,
            content: "/Users/tidbit/Documents/proposal.pdf",
            contentType: "file",
            isPinned: true,
            createdAt: Date().addingTimeInterval(-600),
            updatedAt: Date().addingTimeInterval(-600)
        ),
        ClipboardItem(
            id: 4,
            content: "# Welcome\n\nThis is **bold** and *italic* text.\n\n- Item one\n- Item two",
            contentType: "html",
            isPinned: false,
            createdAt: Date().addingTimeInterval(-1800),
            updatedAt: Date().addingTimeInterval(-1800),
            blobData: "<h1>Welcome</h1><p>This is <b>bold</b> and <i>italic</i> text.</p>".data(using: .utf8)
        ),
        ClipboardItem(
            id: 5,
            content: "#3B82F6",
            contentType: "color",
            isPinned: true,
            createdAt: Date().addingTimeInterval(-3600),
            updatedAt: Date().addingTimeInterval(-3600)
        ),
        ClipboardItem(
            id: 6,
            content: "func greet(name: String) -> String {\n    return \"Hello, \\(name)!\"\n}",
            contentType: "text",
            isPinned: false,
            createdAt: Date().addingTimeInterval(-7200),
            updatedAt: Date().addingTimeInterval(-7200)
        ),
    ]

    private static func createMockThumbnail() -> Data? {
        let size = NSSize(width: 64, height: 48)
        let image = NSImage(size: size)
        image.lockFocus()

        // Draw a gradient as mock image thumbnail
        let gradient = NSGradient(colors: [
            NSColor(red: 0.2, green: 0.6, blue: 0.9, alpha: 1.0),
            NSColor(red: 0.5, green: 0.3, blue: 0.8, alpha: 1.0),
        ])
        gradient?.draw(in: NSRect(origin: .zero, size: size), angle: 135)

        // Draw a small mountain shape
        let path = NSBezierPath()
        path.move(to: NSPoint(x: 0, y: 0))
        path.line(to: NSPoint(x: 20, y: 30))
        path.line(to: NSPoint(x: 32, y: 18))
        path.line(to: NSPoint(x: 50, y: 38))
        path.line(to: NSPoint(x: 64, y: 0))
        path.close()
        NSColor.white.withAlphaComponent(0.3).setFill()
        path.fill()

        image.unlockFocus()

        guard let tiffData = image.tiffRepresentation,
              let bitmapRep = NSBitmapImageRep(data: tiffData)
        else { return nil }
        return bitmapRep.representation(using: .png, properties: [:])
    }
}

// MARK: - Main List Showcase

struct MainListShowcase: View {
    private let items = ScreenshotMockData.mockItems

    var body: some View {
        VStack(spacing: 0) {
            // Header
            HStack {
                Text("Pastdown")
                    .font(.headline)
                    .fontWeight(.semibold)
                Spacer()
                Image(systemName: "gearshape")
                    .font(.system(size: 14))
                    .foregroundStyle(.secondary)
            }
            .padding(.horizontal, 16)
            .padding(.vertical, 10)

            Divider()

            // Current clipboard
            HStack(alignment: .top, spacing: 10) {
                VStack(alignment: .leading, spacing: 4) {
                    Text("Current Clipboard")
                        .font(.caption)
                        .foregroundStyle(.secondary)
                    Text("let config = AppConfig(debug: true)")
                        .font(.system(size: 12))
                        .lineLimit(2)
                }
                Spacer()
                Image(systemName: "pin.fill")
                    .font(.system(size: 14))
                    .foregroundStyle(.orange)
            }
            .padding(.horizontal, 16)
            .padding(.vertical, 10)

            Divider()

            // Section header
            HStack {
                Text("Pinned Items")
                    .font(.caption)
                    .fontWeight(.medium)
                    .foregroundStyle(.secondary)
                Text("\(items.count)")
                    .font(.caption2)
                    .foregroundStyle(.tertiary)
                    .padding(.horizontal, 6)
                    .padding(.vertical, 1)
                    .background(.quaternary.opacity(0.5), in: Capsule())
                Spacer()
            }
            .padding(.horizontal, 16)
            .padding(.top, 8)
            .padding(.bottom, 4)

            // Search bar
            HStack(spacing: 6) {
                Image(systemName: "magnifyingglass")
                    .font(.system(size: 11))
                    .foregroundStyle(.tertiary)
                Text("Search...")
                    .font(.system(size: 12))
                    .foregroundStyle(.tertiary)
                Spacer()
            }
            .padding(.horizontal, 8)
            .padding(.vertical, 5)
            .background(.quaternary.opacity(0.3), in: RoundedRectangle(cornerRadius: 6))
            .padding(.horizontal, 12)
            .padding(.bottom, 4)

            // Item rows (inline, no ScrollView)
            VStack(spacing: 2) {
                ForEach(items) { item in
                    showcaseRow(item)
                }
            }
            .padding(.vertical, 4)

            Divider()

            // Footer
            HStack {
                Text("Clear All")
                    .font(.caption)
                    .foregroundStyle(.secondary)
                Spacer()
                Text("Quit")
                    .font(.caption)
                    .foregroundStyle(.secondary)
            }
            .padding(.horizontal, 16)
            .padding(.vertical, 8)
        }
        .frame(width: 340)
        .background(.background)
        .clipShape(RoundedRectangle(cornerRadius: 10))
        .shadow(color: .black.opacity(0.15), radius: 16, y: 8)
        .padding(40)
    }

    private func showcaseRow(_ item: ClipboardItem) -> some View {
        HStack(spacing: 10) {
            RoundedRectangle(cornerRadius: 1.5)
                .fill(accentColor(for: item))
                .frame(width: 3, height: 28)
                .opacity(0.7)

            rowContent(item)

            Spacer()

            if item.isPinned {
                Image(systemName: "pin.fill")
                    .font(.system(size: 9))
                    .foregroundStyle(.orange.opacity(0.5))
            }
        }
        .padding(.horizontal, 12)
        .padding(.vertical, 7)
        .padding(.horizontal, 8)
    }

    private func accentColor(for item: ClipboardItem) -> Color {
        switch item.contentType {
        case "url": return .blue
        case "image": return .green
        case "file": return .purple
        case "html", "rtf": return .red
        case "color": return .pink
        default: return .orange
        }
    }

    @ViewBuilder
    private func rowContent(_ item: ClipboardItem) -> some View {
        switch item.contentType {
        case "image":
            HStack(spacing: 8) {
                if let thumbnailData = item.thumbnailData, let nsImage = NSImage(data: thumbnailData) {
                    Image(nsImage: nsImage)
                        .resizable()
                        .aspectRatio(contentMode: .fit)
                        .frame(maxWidth: 28, maxHeight: 28)
                        .cornerRadius(3)
                }
                VStack(alignment: .leading, spacing: 3) {
                    Text("Image")
                        .font(.system(size: 12))
                    Text(item.updatedAt.relativeDescription)
                        .font(.caption2)
                        .foregroundStyle(.tertiary)
                }
            }
        case "file":
            VStack(alignment: .leading, spacing: 3) {
                HStack(spacing: 4) {
                    Image(systemName: "doc")
                        .font(.system(size: 10))
                        .foregroundStyle(.purple)
                    Text(URL(fileURLWithPath: item.content).lastPathComponent)
                        .font(.system(size: 12))
                        .lineLimit(1)
                }
                Text(item.updatedAt.relativeDescription)
                    .font(.caption2)
                    .foregroundStyle(.tertiary)
            }
        case "color":
            HStack(spacing: 8) {
                Circle()
                    .fill(Color(hex: item.content))
                    .frame(width: 16, height: 16)
                VStack(alignment: .leading, spacing: 3) {
                    Text(item.content)
                        .font(.system(size: 12, design: .monospaced))
                    Text(item.updatedAt.relativeDescription)
                        .font(.caption2)
                        .foregroundStyle(.tertiary)
                }
            }
        default:
            VStack(alignment: .leading, spacing: 3) {
                Text(item.preview)
                    .font(.system(size: 12))
                    .lineLimit(2)
                Text(item.updatedAt.relativeDescription)
                    .font(.caption2)
                    .foregroundStyle(.tertiary)
            }
        }
    }
}

// MARK: - HTML Detail Showcase

struct HTMLDetailShowcase: View {
    private let markdownContent = """
        # Welcome to Pastdown

        This is **bold** and *italic* text.

        ## Features

        - Clipboard monitoring
        - Multi-format support
        - `SHA256` deduplication

        > A lightweight clipboard manager

        ```swift
        let pastdown = ClipboardManager()
        pastdown.start()
        ```
        """

    var body: some View {
        VStack(spacing: 0) {
            // Header
            HStack {
                HStack(spacing: 4) {
                    Image(systemName: "chevron.left")
                    Text("Back")
                }
                .font(.system(size: 13))
                .foregroundStyle(.blue)

                Spacer()

                Text("HTML")
                    .font(.headline)
                    .fontWeight(.semibold)

                Spacer()

                HStack(spacing: 4) {
                    Image(systemName: "chevron.left")
                    Text("Back")
                }
                .font(.system(size: 13))
                .opacity(0)
            }
            .padding(.horizontal, 16)
            .padding(.vertical, 10)

            Divider()

            // Tab bar
            HStack(spacing: 0) {
                tabButton("Markdown", selected: true)
                tabButton("HTML", selected: false)
                tabButton("Plain Text", selected: false)
            }
            .padding(.horizontal, 16)
            .padding(.vertical, 8)

            Divider()

            // Markdown rendered content (no ScrollView)
            VStack(alignment: .leading, spacing: 0) {
                Text(MarkdownHighlighter.highlight(markdownContent))
                    .frame(maxWidth: .infinity, alignment: .leading)
            }
            .padding(16)

            Spacer()

            Divider()

            // Footer
            HStack {
                Text("2 min ago")
                    .font(.caption2)
                    .foregroundStyle(.tertiary)

                Spacer()

                HStack(spacing: 6) {
                    Image(systemName: "doc.on.doc")
                    Text("Copy")
                }
                .font(.system(size: 12))
                .padding(.horizontal, 10)
                .padding(.vertical, 4)
                .background(.blue)
                .foregroundColor(.white)
                .cornerRadius(5)

                HStack(spacing: 6) {
                    Image(systemName: "trash")
                    Text("Delete")
                }
                .font(.system(size: 12))
                .padding(.horizontal, 10)
                .padding(.vertical, 4)
                .background(.quaternary)
                .cornerRadius(5)
            }
            .padding(.horizontal, 16)
            .padding(.vertical, 10)
        }
        .frame(width: 340)
        .background(.background)
        .clipShape(RoundedRectangle(cornerRadius: 10))
        .shadow(color: .black.opacity(0.15), radius: 16, y: 8)
        .padding(40)
    }

    private func tabButton(_ title: String, selected: Bool) -> some View {
        Text(title)
            .font(.system(size: 12, weight: selected ? .medium : .regular))
            .padding(.horizontal, 12)
            .padding(.vertical, 5)
            .frame(maxWidth: .infinity)
            .background(selected ? Color.accentColor.opacity(0.15) : .clear)
            .cornerRadius(6)
    }
}

// MARK: - Settings Showcase

struct SettingsShowcase: View {
    var body: some View {
        VStack(alignment: .leading, spacing: 0) {
            // Title
            Text("Pastdown Settings")
                .font(.title2)
                .fontWeight(.semibold)
                .padding(.horizontal, 20)
                .padding(.top, 20)
                .padding(.bottom, 12)

            // General section
            sectionHeader("General")
            settingsCard {
                VStack(spacing: 0) {
                    HStack {
                        Text("Max Items")
                        Spacer()
                        Text("50")
                            .foregroundStyle(.secondary)
                            .padding(.horizontal, 8)
                            .padding(.vertical, 2)
                            .background(Color.gray.opacity(0.15), in: RoundedRectangle(cornerRadius: 4))
                    }
                    .padding(.vertical, 8)

                    Divider()

                    HStack {
                        Text("Launch at Login")
                        Spacer()
                        RoundedRectangle(cornerRadius: 10)
                            .fill(Color.green)
                            .frame(width: 38, height: 22)
                            .overlay(
                                Circle()
                                    .fill(.white)
                                    .frame(width: 18, height: 18)
                                    .offset(x: 8)
                            )
                    }
                    .padding(.vertical, 8)
                }
            }

            // Clipboard Monitoring section
            sectionHeader("Clipboard Monitoring")
            settingsCard {
                VStack(alignment: .leading, spacing: 0) {
                    HStack {
                        Text("Auto-monitor clipboard")
                        Spacer()
                        RoundedRectangle(cornerRadius: 10)
                            .fill(Color.green)
                            .frame(width: 38, height: 22)
                            .overlay(
                                Circle()
                                    .fill(.white)
                                    .frame(width: 18, height: 18)
                                    .offset(x: 8)
                            )
                    }
                    .padding(.vertical, 8)

                    Divider()

                    Text("When enabled, all copied content is automatically saved. When disabled, only manually pinned items are saved.")
                        .font(.caption)
                        .foregroundStyle(.secondary)
                        .padding(.vertical, 8)
                }
            }

            // Data section
            sectionHeader("Data")
            settingsCard {
                VStack(alignment: .leading, spacing: 0) {
                    Text("Clear All History")
                        .foregroundStyle(.red)
                        .padding(.vertical, 8)

                    Divider()

                    Text("Database: Application Support/Pastdown/")
                        .font(.caption)
                        .foregroundStyle(.secondary)
                        .padding(.vertical, 8)
                }
            }

            Spacer()
        }
        .frame(width: 380, height: 360)
        .background(Color(nsColor: .windowBackgroundColor))
        .clipShape(RoundedRectangle(cornerRadius: 10))
        .shadow(color: .black.opacity(0.15), radius: 16, y: 8)
        .padding(40)
    }

    private func sectionHeader(_ title: String) -> some View {
        Text(title)
            .font(.subheadline)
            .fontWeight(.medium)
            .foregroundStyle(.secondary)
            .textCase(.uppercase)
            .padding(.horizontal, 20)
            .padding(.top, 12)
            .padding(.bottom, 4)
    }

    private func settingsCard<Content: View>(@ViewBuilder content: () -> Content) -> some View {
        VStack(spacing: 0) {
            content()
        }
        .padding(.horizontal, 12)
        .background(Color(nsColor: .controlBackgroundColor), in: RoundedRectangle(cornerRadius: 8))
        .padding(.horizontal, 16)
    }
}
#endif
