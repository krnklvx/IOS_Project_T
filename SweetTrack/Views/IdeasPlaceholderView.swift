import SwiftUI

struct IdeasPlaceholderView: View {
    var body: some View {
        NavigationStack {
            ContentUnavailableView(
                "Идеи",
                systemImage: "lightbulb.2",
                description: Text("Скоро подгрузим идеи с сайта.")
            )
            .navigationTitle("Идеи")
            .frame(maxWidth: .infinity, maxHeight: .infinity)
            .background(AppTheme.softBackground)
        }
    }
}
