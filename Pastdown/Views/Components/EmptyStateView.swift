import SwiftUI

struct EmptyStateView: View {
    var body: some View {
        VStack(spacing: 12) {
            Spacer()

            Image(systemName: "pin.slash")
                .font(.system(size: 32))
                .foregroundStyle(.tertiary)

            Text("No pinned items")
                .font(.subheadline)
                .foregroundStyle(.secondary)

            Text("Click the pin button above to save\nyour current clipboard content.")
                .font(.caption)
                .foregroundStyle(.tertiary)
                .multilineTextAlignment(.center)

            Spacer()
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity)
        .padding()
    }
}
