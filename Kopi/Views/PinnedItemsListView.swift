import SwiftUI

struct PinnedItemsListView: View {
    @Bindable var viewModel: ClipboardViewModel

    var body: some View {
        ScrollView {
            LazyVStack(spacing: 2) {
                ForEach(viewModel.pinnedItems) { item in
                    PinnedItemRowView(item: item, viewModel: viewModel)
                }
            }
            .padding(.vertical, 4)
        }
    }
}
