import Foundation
import SwiftData

@MainActor
final class OrderFormViewModel: ObservableObject {
    enum FormState {
        case initial
        case loading
        case editing
        case saving
        case failure(String)
    }

    @Published var state: FormState = .initial

    @Published var clientName = ""
    @Published var productType = ""
    @Published var quantityOrWeight = ""
    @Published var deadline = Date()
    @Published var priceText = ""
    @Published var costText = ""
    @Published var status: OrderStatus = .new
    @Published var notes = ""

    func setup(with order: Order?) {
        state = .loading

        if let order {
            clientName = order.clientName
            productType = order.productType
            quantityOrWeight = order.quantityOrWeight
            deadline = order.deadline
            priceText = String(order.price)
            costText = String(order.cost)
            status = order.status
            notes = order.notes
        }
        state = .editing
    }

    var isFormValid: Bool {
        !clientName.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty &&
        !productType.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty &&
        Double(priceText.replacingOccurrences(of: ",", with: ".")) != nil
    }

    func save(order: Order?, modelContext: ModelContext) -> Bool {
        state = .saving

        let parsedPrice = Double(priceText.replacingOccurrences(of: ",", with: "."))
        guard let price = parsedPrice else {
            state = .failure("Цена введена неверно")
            return false
        }
        let cost = Double(costText.replacingOccurrences(of: ",", with: ".")) ?? 0

        if let order {
            order.clientName = clientName
            order.productType = productType
            order.quantityOrWeight = quantityOrWeight
            order.deadline = deadline
            order.price = price
            order.cost = cost
            order.status = status
            order.notes = notes
        } else {
            let newOrder = Order(
                clientName: clientName,
                productType: productType,
                quantityOrWeight: quantityOrWeight,
                deadline: deadline,
                price: price,
                cost: cost,
                status: status,
                notes: notes
            )
            modelContext.insert(newOrder)
        }

        state = .editing
        return true
    }
}
