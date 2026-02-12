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
                    .fill(item.contentType == "url" ? Color.blue : Color.orange)
                    .frame(width: 3, height: 28)
                    .opacity(0.7)

                VStack(alignment: .leading, spacing: 3) {
                    Text(item.preview)
                        .font(.system(size: 12))
                        .lineLimit(2)
                        .foregroundStyle(.primary)

                    Text(item.updatedAt.relativeDescription)
                        .font(.caption2)
                        .foregroundStyle(.tertiary)
                }

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
}

// MARK: - Date Extension

extension Date {
    var relativeDescription: String {
        let formatter = RelativeDateTimeFormatter()
        formatter.unitsStyle = .abbreviated
        return formatter.localizedString(for: self, relativeTo: Date())
    }
}
