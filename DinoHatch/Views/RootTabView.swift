import SwiftUI

struct RootTabView: View {
    var body: some View {
        TabView {
            TimerHomeView()
                .tabItem {
                    Label("Timer", systemImage: "hourglass")
                }

            CollectionView()
                .tabItem {
                    Label("Collection", systemImage: "book.closed.fill")
                }
        }
    }
}

#Preview {
    RootTabView()
        .modelContainer(for: [UnlockedDinosaur.self, AppSettings.self], inMemory: true)
}
