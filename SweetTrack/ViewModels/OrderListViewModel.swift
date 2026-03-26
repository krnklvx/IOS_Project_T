import Foundation

@MainActor
final class OrderListViewModel: ObservableObject {
    enum State {
        case initial
        case loading
        case loaded([Order])
        case failure(String)
    }

    @Published var state: State = .initial
    @Published var searchText = ""

    func loadData(from orders: [Order]) {
        state = .loading

        let text = searchText.trimmingCharacters(in: .whitespacesAndNewlines).lowercased()
        let filteredOrders = orders.filter { order in
            if text.isEmpty { return true }
            return order.clientName.lowercased().contains(text) ||
                order.productType.lowercased().contains(text)
        }

        state = .loaded(filteredOrders)
    }
}
