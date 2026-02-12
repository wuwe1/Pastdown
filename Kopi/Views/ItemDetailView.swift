import SwiftUI

struct ItemDetailView: View {
    let item: ClipboardItem
    @Bindable var viewModel: ClipboardViewModel

    var body: some View {
        VStack(spacing: 0) {
            // Header
            HStack {
                Button {
                    viewModel.goBack()
                } label: {
                    HStack(spacing: 4) {
                        Image(systemName: "chevron.left")
                        Text("Back")
                    }
                    .font(.system(size: 13))
                }
                .buttonStyle(.plain)
                .foregroundStyle(.blue)

                Spacer()

                Text(detailTitle)
                    .font(.headline)
                    .fontWeight(.semibold)

                Spacer()

                // Invisible spacer for centering
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

            // Content
            if item.contentType == "html" {
                HTMLDetailContent(item: item, viewModel: viewModel)
            } else {
                ScrollView {
                    detailContent
                        .frame(maxWidth: .infinity, alignment: .leading)
                        .padding(16)
                }
                .frame(maxHeight: .infinity)

                Divider()

                defaultFooter
            }
        }
    }

    private var detailTitle: String {
        switch item.contentType {
        case "image": return "Image"
        case "file": return "File"
        case "html": return "HTML"
        case "rtf": return "Rich Text"
        case "url": return "URL"
        case "color": return "Color"
        default: return "Text"
        }
    }

    @ViewBuilder
    private var detailContent: some View {
        switch item.contentType {
        case "image":
            if let blobData = item.blobData, let nsImage = NSImage(data: blobData) {
                Image(nsImage: nsImage)
                    .resizable()
                    .aspectRatio(contentMode: .fit)
                    .frame(maxWidth: .infinity)
                    .cornerRadius(6)
            } else {
                Text("Image data unavailable")
                    .foregroundStyle(.tertiary)
            }
        case "file":
            VStack(alignment: .leading, spacing: 12) {
                HStack(spacing: 8) {
                    Image(systemName: "doc.fill")
                        .font(.system(size: 24))
                        .foregroundStyle(.purple)
                    Text(URL(fileURLWithPath: item.content).lastPathComponent)
                        .font(.system(size: 14, weight: .medium))
                }
                Text(item.content)
                    .font(.system(size: 12, design: .monospaced))
                    .textSelection(.enabled)
                    .foregroundStyle(.secondary)
            }
        case "color":
            VStack(alignment: .leading, spacing: 12) {
                RoundedRectangle(cornerRadius: 8)
                    .fill(Color(hex: item.content))
                    .frame(height: 60)
                Text(item.content)
                    .font(.system(size: 14, design: .monospaced))
                    .textSelection(.enabled)
            }
        default:
            Text(item.content)
                .font(.system(size: 12, design: .monospaced))
                .textSelection(.enabled)
        }
    }

    private var defaultFooter: some View {
        HStack {
            Text(item.createdAt, format: .dateTime)
                .font(.caption2)
                .foregroundStyle(.tertiary)

            Spacer()

            if item.contentType == "file" {
                Button {
                    revealInFinder()
                } label: {
                    Label("Reveal in Finder", systemImage: "folder")
                        .font(.system(size: 12))
                }
                .buttonStyle(.bordered)
                .controlSize(.small)
            }

            Button {
                viewModel.copyToClipboard(item)
            } label: {
                Label("Copy", systemImage: "doc.on.doc")
                    .font(.system(size: 12))
            }
            .buttonStyle(.borderedProminent)
            .controlSize(.small)

            Button(role: .destructive) {
                viewModel.deleteItem(item)
            } label: {
                Label("Delete", systemImage: "trash")
                    .font(.system(size: 12))
            }
            .buttonStyle(.bordered)
            .controlSize(.small)
        }
        .padding(.horizontal, 16)
        .padding(.vertical, 10)
    }

    private func revealInFinder() {
        let url = URL(fileURLWithPath: item.content)
        NSWorkspace.shared.activateFileViewerSelecting([url])
    }
}

// MARK: - HTML Detail with Tabs

private enum HTMLTab: String, CaseIterable {
    case markdown = "Markdown"
    case html = "HTML"
    case plainText = "Plain Text"
}

private struct HTMLDetailContent: View {
    let item: ClipboardItem
    @Bindable var viewModel: ClipboardViewModel
    @State private var selectedTab: HTMLTab = .markdown

    var body: some View {
        VStack(spacing: 0) {
            // Tab bar
            Picker("", selection: $selectedTab) {
                ForEach(HTMLTab.allCases, id: \.self) { tab in
                    Text(tab.rawValue).tag(tab)
                }
            }
            .pickerStyle(.segmented)
            .padding(.horizontal, 16)
            .padding(.vertical, 8)

            Divider()

            // Content based on selected tab
            ScrollView {
                if selectedTab == .markdown {
                    Text(MarkdownHighlighter.highlight(item.content))
                        .textSelection(.enabled)
                        .frame(maxWidth: .infinity, alignment: .leading)
                        .padding(16)
                } else {
                    Text(contentForTab)
                        .font(.system(size: 12, design: .monospaced))
                        .textSelection(.enabled)
                        .frame(maxWidth: .infinity, alignment: .leading)
                        .padding(16)
                }
            }
            .frame(maxHeight: .infinity)

            Divider()

            // Footer with contextual copy buttons
            HStack {
                Text(item.createdAt, format: .dateTime)
                    .font(.caption2)
                    .foregroundStyle(.tertiary)

                Spacer()

                Menu {
                    Button {
                        viewModel.copyAsMarkdown(item)
                    } label: {
                        Label("Copy Markdown", systemImage: "text.quote")
                    }
                    Button {
                        viewModel.copyAsRawHTML(item)
                    } label: {
                        Label("Copy HTML", systemImage: "chevron.left.forwardslash.chevron.right")
                    }
                    Button {
                        viewModel.copyAsPlainText(item)
                    } label: {
                        Label("Copy Plain Text", systemImage: "doc.plaintext")
                    }
                    Divider()
                    Button {
                        viewModel.copyToClipboard(item)
                    } label: {
                        Label("Copy Original (Rich Text)", systemImage: "doc.on.doc")
                    }
                } label: {
                    Label("Copy", systemImage: "doc.on.doc")
                        .font(.system(size: 12))
                }
                .menuStyle(.borderedButton)
                .controlSize(.small)

                Button(role: .destructive) {
                    viewModel.deleteItem(item)
                } label: {
                    Label("Delete", systemImage: "trash")
                        .font(.system(size: 12))
                }
                .buttonStyle(.bordered)
                .controlSize(.small)
            }
            .padding(.horizontal, 16)
            .padding(.vertical, 10)
        }
    }

    private var contentForTab: String {
        switch selectedTab {
        case .markdown:
            return item.content
        case .html:
            if let blobData = item.blobData {
                return String(data: blobData, encoding: .utf8)
                    ?? String(data: blobData, encoding: .unicode)
                    ?? ""
            }
            return ""
        case .plainText:
            if let blobData = item.blobData {
                let html = String(data: blobData, encoding: .utf8)
                    ?? String(data: blobData, encoding: .unicode)
                    ?? item.content
                return HTMLToMarkdown.stripHTMLTags(html)
            }
            return item.content
        }
    }
}
