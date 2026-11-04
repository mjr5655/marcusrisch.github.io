import SwiftUI
import SwiftData

@main
struct VinoApp: App {
    init() {
        Theme.applyAppearance()
    }

    var body: some Scene {
        WindowGroup {
            RootView()
                .tint(Theme.gold)
                .preferredColorScheme(.dark)
        }
        .modelContainer(for: Wine.self)
    }
}
