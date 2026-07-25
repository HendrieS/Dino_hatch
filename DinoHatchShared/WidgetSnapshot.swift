import Foundation

/// A small, deliberately non-SwiftData snapshot of collection progress,
/// written by the main app and read by `DinoHatchWidget`. WidgetKit
/// extensions run in a separate process and can't query the app's SwiftData
/// store directly, so this is written to an App Group-shared UserDefaults
/// suite instead. The app resolves `lastDinosaurName` (already localized)
/// and `lastDinosaurEmoji` before writing, so the widget target doesn't need
/// `DinosaurCatalog`, the localization catalog, or any dinosaur art at all —
/// it just displays whatever's in here.
struct WidgetSnapshot: Codable, Equatable {
    var unlockedCount: Int
    var totalCount: Int
    var lastDinosaurEmoji: String?
    var lastDinosaurName: String?

    static let empty = WidgetSnapshot(unlockedCount: 0, totalCount: 0, lastDinosaurEmoji: nil, lastDinosaurName: nil)
}

/// Shared App Group read/write for `WidgetSnapshot`. Both targets link this
/// file; only the main app ever calls `save`, both call `load`.
enum WidgetSnapshotStore {
    static let appGroupID = "group.com.dinohatch.app"
    static let widgetKind = "DinoHatchCollectionWidget"

    private static let key = "widgetSnapshot"

    static func save(_ snapshot: WidgetSnapshot) {
        guard let defaults = UserDefaults(suiteName: appGroupID),
              let data = try? JSONEncoder().encode(snapshot) else { return }
        defaults.set(data, forKey: key)
    }

    static func load() -> WidgetSnapshot? {
        guard let defaults = UserDefaults(suiteName: appGroupID),
              let data = defaults.data(forKey: key) else { return nil }
        return try? JSONDecoder().decode(WidgetSnapshot.self, from: data)
    }
}
