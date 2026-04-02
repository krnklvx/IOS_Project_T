import Foundation
import SwiftData

@Model
final class RecipeStep {
    @Attribute(.unique) var id: UUID
    var text: String
    var sortIndex: Int

    var recipe: Recipe?

    init(id: UUID = UUID(), text: String, sortIndex: Int, recipe: Recipe? = nil) {
        self.id = id
        self.text = text
        self.sortIndex = sortIndex
        self.recipe = recipe
    }
}
