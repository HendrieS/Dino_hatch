import Foundation
import SwiftData

/// Builds the one `ModelContainer` both targets use, backed by a file inside
/// the `group.com.dinohatch.app` App Group container rather than the app's
/// own default location — the Quick Timer widget's `StartTimerIntent` runs
/// in the widget extension's process and needs to write `AppSettings`
/// directly (so a timer started from the widget is indistinguishable, once
/// written, from one started in-app: same hatch detection, same
/// notification), which is only possible if both processes open the same
/// store file. Both targets must declare the identical `Schema` (all three
/// model types, even ones a given process never touches) or SwiftData
/// rejects the store as incompatible.
enum SharedModelContainer {
    static func make() -> ModelContainer {
        let schema = Schema([UnlockedDinosaur.self, AppSettings.self, AlarmSettings.self])
        guard let groupURL = FileManager.default.containerURL(forSecurityApplicationGroupIdentifier: WidgetSnapshotStore.appGroupID) else {
            fatalError("App Group container unavailable — check the \(WidgetSnapshotStore.appGroupID) entitlement")
        }
        let storeURL = groupURL.appendingPathComponent("DinoHatch.sqlite")
        let config = ModelConfiguration(schema: schema, url: storeURL)
        do {
            return try ModelContainer(for: schema, configurations: [config])
        } catch {
            fatalError("Could not create shared ModelContainer: \(error)")
        }
    }
}
