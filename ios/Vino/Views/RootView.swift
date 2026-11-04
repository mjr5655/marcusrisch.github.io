import SwiftUI

struct RootView: View {
    var body: some View {
        TabView {
            JournalView()
                .tabItem { Label("Journal", systemImage: "books.vertical") }
            DiscoverView()
                .tabItem { Label("Discover", systemImage: "sparkle.magnifyingglass") }
            LearnView()
                .tabItem { Label("Learn", systemImage: "graduationcap") }
        }
        .background(Theme.navy.ignoresSafeArea())
    }
}
