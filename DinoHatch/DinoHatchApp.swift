import SwiftUI
import SwiftData

@main
struct DinoHatchApp: App {
    var sharedModelContainer: ModelContainer = {
        let schema = Schema([UnlockedDinosaur.self, AppSettings.self])
        let config = ModelConfiguration(schema: schema, cloudKitDatabase: .automatic)
        do {
            return try ModelContainer(for: schema, configurations: [config])
        } catch {
            fatalError("Could not create ModelContainer: \(error)")
        }
    }()

    var body: some Scene {
        WindowGroup {
            RootTabView()
        }
        .modelContainer(sharedModelContainer)
    }
}
