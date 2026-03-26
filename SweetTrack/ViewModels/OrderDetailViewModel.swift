import Foundation

@MainActor
final class OrderDetailViewModel: ObservableObject {
    enum State {
        case initial
        case loading
        case loaded(Order)
        case failure(String)
    }

    @Published var state: State = .initial

    init(order: Order) {
        state = .loaded(order)
    }

    func hasNotes(_ order: Order) -> Bool {
        !order.notes.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty
    }

    func money(_ value: Double) -> String {
        let formatted = value.formatted(.number.precision(.fractionLength(0...2)))
        return "\(formatted) ₽"
    }
}
