import SwiftUI

struct CurrentClipboardView: View {
    @Bindable var viewModel: ClipboardViewModel

    var body: some View {
        HStack(alignment: .top, spacing: 10) {
            VStack(alignment: .leading, spacing: 4) {
                Text("Current Clipboard")
                    .font(.caption)
                    .foregroundStyle(.secondary)

                if let content = viewModel.currentClipboardContent {
                    clipboardPreview(for: content)
                } else {
                    Text("Clipboard is empty")
                        .font(.system(size: 12))
                        .foregroundStyle(.tertiary)
                        .italic()
                }
            }

            Spacer()

            Button {
                viewModel.pinCurrentClipboard()
            } label: {
                Image(systemName: "pin.fill")
                    .font(.system(size: 14))
                    .foregroundStyle(.orange)
            }
            .buttonStyle(.plain)
            .help("Pin to history")
            .disabled(viewModel.currentClipboardContent == nil)
        }
        .padding(.horizontal, 16)
        .padding(.vertical, 10)
    }

    @ViewBuilder
    private func clipboardPreview(for content: ClipboardContent) -> some View {
        switch content.contentType {
        case "image":
            HStack(spacing: 6) {
                if let blobData = content.blobData, let nsImage = NSImage(data: blobData) {
                    Image(nsImage: nsImage)
                        .resizable()
                        .aspectRatio(contentMode: .fit)
                        .frame(maxWidth: 40, maxHeight: 32)
                        .cornerRadius(4)
                }
                Text("Image")
                    .font(.system(size: 12))
                    .foregroundStyle(.secondary)
            }
        case "file":
            HStack(spacing: 6) {
                Image(systemName: "doc")
                    .font(.system(size: 14))
                    .foregroundStyle(.purple)
                if let path = content.textContent {
                    Text(URL(fileURLWithPath: path).lastPathComponent)
                        .font(.system(size: 12))
                        .lineLimit(2)
                }
            }
        case "color":
            HStack(spacing: 6) {
                if let hex = content.textContent {
                    Circle()
                        .fill(Color(hex: hex))
                        .frame(width: 16, height: 16)
                    Text(hex)
                        .font(.system(size: 12, design: .monospaced))
                }
            }
        default:
            if let text = content.textContent, !text.isEmpty {
                Text(text.trimmedPreview)
                    .font(.system(size: 12))
                    .lineLimit(2)
                    .frame(maxWidth: .infinity, alignment: .leading)
            } else {
                Text("Clipboard is empty")
                    .font(.system(size: 12))
                    .foregroundStyle(.tertiary)
                    .italic()
            }
        }
    }
}

// MARK: - Color from Hex

extension Color {
    init(hex: String) {
        let hex = hex.trimmingCharacters(in: CharacterSet.alphanumerics.inverted)
        var int: UInt64 = 0
        Scanner(string: hex).scanHexInt64(&int)
        let r, g, b: Double
        switch hex.count {
        case 6:
            r = Double((int >> 16) & 0xFF) / 255.0
            g = Double((int >> 8) & 0xFF) / 255.0
            b = Double(int & 0xFF) / 255.0
        default:
            r = 0; g = 0; b = 0
        }
        self.init(red: r, green: g, blue: b)
    }
}
