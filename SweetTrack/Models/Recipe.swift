import Foundation
import SwiftData

@Model
final class Recipe {
    @Attribute(.unique) var id: UUID
    var name: String
    var baseUnitRaw: String
    var baseAmount: Double
    var createdAt: Date

    @Relationship(deleteRule: .cascade, inverse: \RecipeIngredient.recipe)
    var ingredients: [RecipeIngredient] = []

    @Relationship(deleteRule: .cascade, inverse: \RecipeStep.recipe)
    var steps: [RecipeStep] = []

    @Relationship(inverse: \Order.recipe) //у одного рецепта много заказов
    var orders: [Order] = []

    init(
        id: UUID = UUID(),
        name: String,
        baseUnit: RecipeBaseUnit,
        baseAmount: Double,
        createdAt: Date = .now
    ) {
        self.id = id
        self.name = name
        self.baseUnitRaw = baseUnit.rawValue
        self.baseAmount = baseAmount
        self.createdAt = createdAt
    }
}

extension Recipe {
    var baseUnitEnum: RecipeBaseUnit {
        RecipeBaseUnit(rawValue: baseUnitRaw) ?? .grams
    }
}
