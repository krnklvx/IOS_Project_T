import SwiftUI

struct ContentView: View {
    var body: some View {
        TabView {
            OrderListView()
                .tabItem {
                    Label("Заказы", systemImage: "list.bullet.rectangle")
                }

            ProfilePlaceholderView()
                .tabItem {
                    Label("Профиль", systemImage: "person.crop.circle")
                }

            IdeasPlaceholderView()
                .tabItem {
                    Label("Идеи", systemImage: "sparkles")
                }
        }
    }
}
