import SwiftUI
import SwiftData

@main
struct DinoHatchApp: App {
    // Backed by the App Group container (see SharedModelContainer) rather
    // than the app's own default location, so the Quick Timer widget's
    // StartTimerIntent can write AppSettings directly from the widget
    // extension process. Still local-only, no iCloud/CloudKit — that
    // requires a paid Apple Developer Program membership; see
    // "Re-enabling iCloud sync" in README.md.
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
