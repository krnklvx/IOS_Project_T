import SwiftUI

enum AppTheme {
    static let accent = Color(red: 0.90, green: 0.45, blue: 0.62)
    static let softBackground = Color(red: 1.0, green: 0.94, blue: 0.96)

    static func rubles(_ value: Double) -> String {
        "\(value.formatted(.number.precision(.fractionLength(0...2)))) ₽"
    }
}
