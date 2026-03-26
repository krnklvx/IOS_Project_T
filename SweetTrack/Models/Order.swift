import Foundation
import SwiftData

enum OrderStatus: String, Codable, CaseIterable, Identifiable {
    case new = "Новый"
    case inProgress = "В работе"
    case ready = "Готов"
    case delivered = "Выдан"

    var id: String { rawValue }
}

@Model
final class Order {
    @Attribute(.unique) var id: UUID
    var clientName: String
    var productType: String
    var quantityOrWeight: String
    var deadline: Date
    var price: Double
    var cost: Double
    var status: OrderStatus
    var notes: String
    var createdAt: Date

    init(id: UUID = UUID(),
        clientName: String,
        productType: String,
        quantityOrWeight: String,
        deadline: Date,
        price: Double,
        cost: Double,
        status: OrderStatus = .new,
        notes: String = "",
        createdAt: Date = .now) {
        
        self.id = id
        self.clientName = clientName
        self.productType = productType
        self.quantityOrWeight = quantityOrWeight
        self.deadline = deadline
        self.price = price
        self.cost = cost
        self.status = status
        self.notes = notes
        self.createdAt = createdAt
    }

    var profit: Double {
        price - cost
    }
}
