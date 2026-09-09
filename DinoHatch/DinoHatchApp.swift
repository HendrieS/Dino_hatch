import SwiftUI
import SwiftData

@main
struct DinoHatchApp: App {
    // Backed by the App Group container (see SharedModelContainer) rather
    // than the app's own default location, so the Quick Timer widget's
    // StartTimerIntent can write AppSettings directly from the widget
    // extension process. Also syncs via CloudKit by default
    // (`cloudKitDatabase: .automatic`, set in SharedModelContainer) — that
    // requires a paid Apple Developer Program membership to provision; see
    // "iCloud sync" in README.md for what that enables and the two-line
    // revert to local-only if you're on a personal/free team.
    var sharedModelContainer: ModelContainer = SharedModelContainer.make()

    var body: some Scene {
        WindowGroup {
            RootTabView()
                // The app is aimed at kids and isn't designed with a dark
                // palette in mind — UIUserInterfaceStyle in project.yml
                // forces the system chrome (status bar, system alerts)
                // light too; this covers the SwiftUI view hierarchy itself.
                .preferredColorScheme(.light)
        }
        .modelContainer(sharedModelContainer)
    }
}
