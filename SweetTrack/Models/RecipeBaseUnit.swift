import Foundation

enum RecipeBaseUnit: String, Codable, CaseIterable, Identifiable {
    case grams
    case pieces

    var id: String { rawValue }

    var shortTitle: String {
        switch self {
        case .grams: return "г"
        case .pieces: return "шт"
        }
    }

    var pickerTitle: String {
        switch self {
        case .grams: return "Граммы"
        case .pieces: return "Штуки"
        }
    }
}
