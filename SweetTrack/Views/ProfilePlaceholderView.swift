import SwiftUI

struct ProfilePlaceholderView: View {
    var body: some View {
        NavigationStack {
            ContentUnavailableView(
                "Профиль",
                systemImage: "person.crop.circle.badge.clock",
                description: Text("Скоро здесь будут настройки.")
            )
            .navigationTitle("Профиль")
            .frame(maxWidth: .infinity, maxHeight: .infinity)
            .background(AppTheme.softBackground)
        }
    }
}

