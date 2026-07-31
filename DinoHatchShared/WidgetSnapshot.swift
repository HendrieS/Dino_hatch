import Foundation

/// A small, deliberately non-SwiftData snapshot of collection progress,
/// written by the main app and read by `DinoHatchWidget`. WidgetKit
/// extensions run in a separate process and can't query the app's SwiftData
/// store directly, so this is written to an App Group-shared UserDefaults
/// suite instead. The app resolves `lastDinosaurName` (already localized)
/// and `lastDinosaurEmoji` before writing, so the widget target doesn't need
/// `DinosaurCatalog` or the localization catalog. It *does* share
/// `Assets.xcassets` (see `project.yml`) so it can render the real skin
/// illustration via `lastDinosaurImageAssetName`/
/// `activeTimerDinosaurImageAssetName` — the emoji fields stay as a
/// fallback for any dinosaur that doesn't have art yet (`DinoWidgetImage`
/// handles the fallback, mirroring `DinoImageView` in the main app).
struct WidgetSnapshot: Codable, Equatable {
    var unlockedCount: Int
    var totalCount: Int
    var lastDinosaurEmoji: String? = nil
    var lastDinosaurImageAssetName: String? = nil
    var lastDinosaurName: String? = nil
    /// Whether an alarm is currently enabled — kept separate from
    /// `nextAlarmFireDate` being non-nil so the alarm widget can tell "off"
    /// apart from "on, but the fire date happens to be stale/unresolved".
    var alarmEnabled: Bool = false
    /// The next concrete alarm firing, computed by `AlarmNextFireDate` at
    /// write time — the widget just hands this straight to
    /// `Text(_:style: .timer)`, which ticks down live with no further
    /// timeline reloads needed.
    var nextAlarmFireDate: Date? = nil
    /// Mirrors `AppSettings.activeTimerEndDate` — non-nil while a timer is
    /// running (whether or not it's already past, see
    /// `DinoHatchQuickTimerWidgetView`), nil once cancelled or hatched.
    var activeTimerEndDate: Date? = nil
    /// The emoji/asset name of the dinosaur the running timer is hatching,
    /// resolved in the app the same way `lastDinosaurEmoji`/
    /// `lastDinosaurImageAssetName` are.
    var activeTimerDinosaurEmoji: String? = nil
    var activeTimerDinosaurImageAssetName: String? = nil

    static let empty = WidgetSnapshot(unlockedCount: 0, totalCount: 0, lastDinosaurEmoji: nil, lastDinosaurName: nil)
}

/// Shared App Group read/write for `WidgetSnapshot`. Both targets link this
/// file; only the main app ever calls `save`, both call `load`.
enum WidgetSnapshotStore {
    static let appGroupID = "group.com.dinohatchtimer.app"
    static let widgetKind = "DinoHatchCollectionWidget"
    static let alarmWidgetKind = "DinoHatchAlarmWidget"
    static let quickTimerWidgetKind = "DinoHatchQuickTimerWidget"

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
