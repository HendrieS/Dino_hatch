import SwiftUI
import SwiftData

@main
struct DinoHatchApp: App {
    var sharedModelContainer: ModelContainer = {
        // Local-only for now: iCloud/CloudKit sync requires a paid Apple
        // Developer Program membership (personal/free teams can't use the
        // iCloud capability). To re-enable sync once on a paid team, pass
        // `cloudKitDatabase: .automatic` here and restore the `entitlements`
        // block for the DinoHatch target in project.yml.
        let schema = Schema([UnlockedDinosaur.self, AppSettings.self])
        let config = ModelConfiguration(schema: schema)
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
