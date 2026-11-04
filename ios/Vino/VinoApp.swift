import SwiftUI
import SwiftData

@main
struct VinoApp: App {
    var body: some Scene {
        WindowGroup {
            RootView()
                .tint(Theme.burgundy)
        }
        .modelContainer(for: Wine.self)
    }
}

enum Theme {
    static let burgundy = Color(red: 0.45, green: 0.09, blue: 0.20)
}
