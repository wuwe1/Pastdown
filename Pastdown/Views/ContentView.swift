import SwiftUI

struct ContentView: View {
    @Bindable var viewModel: ClipboardViewModel
    @Environment(\.openWindow) private var openWindow

    private var panelWidth: CGFloat {
        viewModel.showingDetail ? 500 : 340
    }

    private var screenMaxHeight: CGFloat {
        NSScreen.main?.visibleFrame.height ?? 800
    }

    private var detailViewHeight: CGFloat {
        min(560, screenMaxHeight)
    }

    private var pinnedListHeight: CGFloat {
        let rowHeight: CGFloat = 44
        let count = CGFloat(viewModel.filteredItems.count)
        let naturalHeight = count * rowHeight + 8
        let maxListHeight = max(screenMaxHeight - 200, 120)
        return min(naturalHeight, maxListHeight)
    }

    var body: some View {
        VStack(spacing: 0) {
            if viewModel.showingDetail, let item = viewModel.selectedItem {
                ItemDetailView(item: item, viewModel: viewModel)
                    .frame(height: detailViewHeight)
            } else {
                mainListView
            }
        }
        .frame(width: panelWidth)
        .animation(.easeInOut(duration: 0.2), value: viewModel.showingDetail)
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

            // Search bar (only show when there are items)
            if !viewModel.pinnedItems.isEmpty {
                searchBar
            }

            // Pinned Items List
            if viewModel.pinnedItems.isEmpty {
                EmptyStateView()
                    .frame(height: 120)
            } else if viewModel.filteredItems.isEmpty {
                Text("No results for \"\(viewModel.searchText)\"")
                    .font(.caption)
                    .foregroundStyle(.tertiary)
                    .frame(height: 60)
            } else {
                PinnedItemsListView(items: viewModel.filteredItems, viewModel: viewModel)
                    .frame(height: pinnedListHeight)
            }

            Divider()

            // Footer
            footerView
        }
    }

    private var headerView: some View {
        HStack {
            Text("Pastdown")
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

    private var searchBar: some View {
        HStack(spacing: 6) {
            Image(systemName: "magnifyingglass")
                .font(.system(size: 11))
                .foregroundStyle(.tertiary)

            TextField("Search...", text: $viewModel.searchText)
                .textFieldStyle(.plain)
                .font(.system(size: 12))

            if !viewModel.searchText.isEmpty {
                Button {
                    viewModel.searchText = ""
                } label: {
                    Image(systemName: "xmark.circle.fill")
                        .font(.system(size: 11))
                        .foregroundStyle(.tertiary)
                }
                .buttonStyle(.plain)
            }
        }
        .padding(.horizontal, 8)
        .padding(.vertical, 5)
        .background(.quaternary.opacity(0.3), in: RoundedRectangle(cornerRadius: 6))
        .padding(.horizontal, 12)
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
