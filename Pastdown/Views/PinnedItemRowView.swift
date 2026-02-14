import SwiftUI

struct PinnedItemRowView: View {
    let item: ClipboardItem
    @Bindable var viewModel: ClipboardViewModel
    @State private var isHovering = false

    var body: some View {
        Button {
            viewModel.selectItem(item)
        } label: {
            HStack(spacing: 10) {
                // Color accent bar
                RoundedRectangle(cornerRadius: 1.5)
                    .fill(accentColor)
                    .frame(width: 3, height: 28)
                    .opacity(0.7)

                rowContent

                Spacer()

                if item.isPinned {
                    Image(systemName: "pin.fill")
                        .font(.system(size: 9))
                        .foregroundStyle(.orange.opacity(0.5))
                }
            }
            .padding(.horizontal, 12)
            .padding(.vertical, 7)
            .background(
                RoundedRectangle(cornerRadius: 6)
                    .fill(isHovering ? .white.opacity(0.15) : .clear)
            )
            .padding(.horizontal, 8)
            .contentShape(Rectangle())
        }
        .buttonStyle(.plain)
        .onHover { hovering in
            isHovering = hovering
        }
        .contextMenu {
            Button {
                viewModel.copyToClipboard(item)
            } label: {
                Label("Copy", systemImage: "doc.on.doc")
            }

            Divider()

            Button(role: .destructive) {
                viewModel.deleteItem(item)
            } label: {
                Label("Delete", systemImage: "trash")
            }
        }
    }

    private var accentColor: Color {
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
    private var rowContent: some View {
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
                        .foregroundStyle(.primary)
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
                        .foregroundStyle(.primary)
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
                        .foregroundStyle(.primary)
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
                    .foregroundStyle(.primary)

                Text(item.updatedAt.relativeDescription)
                    .font(.caption2)
                    .foregroundStyle(.tertiary)
            }
        }
    }
}

// MARK: - Date Extension

extension Date {
    var relativeDescription: String {
        let formatter = RelativeDateTimeFormatter()
        formatter.unitsStyle = .abbreviated
        return formatter.localizedString(for: self, relativeTo: Date())
    }
}
