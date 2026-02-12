import SwiftUI

struct ContentView: View {
    @Bindable var viewModel: ClipboardViewModel
    @Environment(\.openWindow) private var openWindow

    var body: some View {
        VStack(spacing: 0) {
            if viewModel.showingDetail, let item = viewModel.selectedItem {
                ItemDetailView(item: item, viewModel: viewModel)
            } else {
                mainListView
            }
        }
        .onAppear {
            viewModel.refreshCurrentContent()
        }
    }

    private var mainListView: some View {
        VStack(spacing: 0) {
            // Header
            headerView

            Divider()

            // Current Clipboard
            CurrentClipboardView(viewModel: viewModel)

            Divider()

            // Section header
            pinnedSectionHeader

            // Pinned Items List
            if viewModel.pinnedItems.isEmpty {
                EmptyStateView()
                    .frame(height: 120)
            } else {
                PinnedItemsListView(viewModel: viewModel)
                    .frame(maxHeight: 320)
            }

            Divider()

            // Footer
            footerView
        }
    }

    private var headerView: some View {
        HStack {
            Text("Kopi")
                .font(.headline)
                .fontWeight(.semibold)

            Spacer()

            Button {
                openSettings()
            } label: {
                Image(systemName: "gearshape")
                    .font(.system(size: 14))
                    .foregroundStyle(.secondary)
            }
            .buttonStyle(.plain)
            .help("Settings")
            .keyboardShortcut(",", modifiers: .command)
        }
        .padding(.horizontal, 16)
        .padding(.vertical, 10)
    }

    private var pinnedSectionHeader: some View {
        HStack {
            Text("Pinned Items")
                .font(.caption)
                .fontWeight(.medium)
                .foregroundStyle(.secondary)

            if !viewModel.pinnedItems.isEmpty {
                Text("\(viewModel.pinnedItems.count)")
                    .font(.caption2)
                    .foregroundStyle(.tertiary)
                    .padding(.horizontal, 6)
                    .padding(.vertical, 1)
                    .background(.quaternary.opacity(0.5), in: Capsule())
            }

            Spacer()
        }
        .padding(.horizontal, 16)
        .padding(.top, 8)
        .padding(.bottom, 4)
    }

    private var footerView: some View {
        HStack {
            Button("Clear All") {
                viewModel.clearAllItems()
            }
            .buttonStyle(.plain)
            .foregroundStyle(.secondary)
            .font(.caption)
            .disabled(viewModel.pinnedItems.isEmpty)

            Spacer()

            Button("Quit") {
                NSApplication.shared.terminate(nil)
            }
            .buttonStyle(.plain)
            .foregroundStyle(.secondary)
            .font(.caption)
            .keyboardShortcut("q", modifiers: .command)
        }
        .padding(.horizontal, 16)
        .padding(.vertical, 8)
    }

    private func openSettings() {
        openWindow(id: "settings")
        NSApp.activate()
    }
}
