import Foundation
import SwiftData

@Model
final class RecipeIngredient {
    @Attribute(.unique) var id: UUID
    var name: String
    var amount: Double
    var unit: String
    var sortIndex: Int

    var recipe: Recipe?

    init(
        id: UUID = UUID(),
        name: String,
        amount: Double,
        unit: String,
        sortIndex: Int,
        recipe: Recipe? = nil
    ) {
        self.id = id
        self.name = name
        self.amount = amount
        self.unit = unit
        self.sortIndex = sortIndex
        self.recipe = recipe
    }
}
