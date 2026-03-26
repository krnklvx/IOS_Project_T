import SwiftUI

struct IdeasPlaceholderView: View {
    var body: some View {
        NavigationStack {
            ContentUnavailableView(
                "Идеи",
                systemImage: "lightbulb.2",
            )
            .navigationTitle("Идеи")
        }
    }
}
