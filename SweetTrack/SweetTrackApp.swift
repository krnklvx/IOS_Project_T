import SwiftUI
import SwiftData

@main
struct SweetTrackApp: App {
    var body: some Scene {
        WindowGroup {
            ContentView()
        }
        .modelContainer(for: Order.self) //хранилище для order для Query и modelContext
    }
}
