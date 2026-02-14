import SwiftUI

struct PinnedItemsListView: View {
    let items: [ClipboardItem]
    @Bindable var viewModel: ClipboardViewModel

    var body: some View {
        ScrollView {
            LazyVStack(spacing: 2) {
                ForEach(items) { item in
                    PinnedItemRowView(item: item, viewModel: viewModel)
                }
            }
            .padding(.vertical, 4)
        }
    }
}
