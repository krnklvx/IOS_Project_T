import SwiftUI

struct ContentView: View {
    var body: some View {
        TabView {
            OrderListView()
                .tabItem {
                    Label("Заказы", systemImage: "list.bullet.rectangle")
                }

            RecipeListView()
                .tabItem {
                    Label("Мои рецепты", systemImage: "heart.fill")
                }

            ProfilePlaceholderView()
                .tabItem {
                    Label("Профиль", systemImage: "person.crop.circle")
                }

            IdeasPlaceholderView()
                .tabItem {
                    Label("Идеи", systemImage: "lightbulb.fill")
                }
        }
        .tint(AppTheme.accent)
    }
}
