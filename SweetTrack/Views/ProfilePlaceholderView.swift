import SwiftUI

struct ProfilePlaceholderView: View {
    var body: some View {
        NavigationStack {
            ContentUnavailableView(
                "Профиль",
                systemImage: "person.crop.circle.badge.clock",
            )
            .navigationTitle("Профиль")
        }
    }
}

