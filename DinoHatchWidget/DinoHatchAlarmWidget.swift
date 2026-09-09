import WidgetKit
import SwiftUI

struct AlarmEntry: TimelineEntry {
    let date: Date
    let snapshot: WidgetSnapshot
}

/// The countdown itself is rendered live by `Text(_:style: .timer)`, driven
/// by the system with no reload needed *while* the fire date is still in
/// the future. But `RootTabView`'s pre-computed `nextAlarmFireDate` goes
/// stale the moment it passes — relying on the main app to notice and
/// reload (next foreground, or a settings change) leaves the widget stuck
/// showing that stale date, ticking oddly past zero, for however long the
/// app stays unopened, which defeats the point of a glanceable widget.
/// `getTimeline` instead recomputes the fire date itself from the raw
/// schedule and self-schedules its own reload right at that moment
/// (`.after`), so it stays correct even if the app is never reopened.
struct AlarmProvider: TimelineProvider {
    func placeholder(in context: Context) -> AlarmEntry {
        AlarmEntry(date: .now, snapshot: WidgetSnapshot(unlockedCount: 0, totalCount: 26, alarmEnabled: true, nextAlarmFireDate: .now.addingTimeInterval(3600)))
    }

    func getSnapshot(in context: Context, completion: @escaping (AlarmEntry) -> Void) {
        completion(AlarmEntry(date: .now, snapshot: WidgetSnapshotStore.load() ?? .empty))
    }

    func getTimeline(in context: Context, completion: @escaping (Timeline<AlarmEntry>) -> Void) {
        var snapshot = WidgetSnapshotStore.load() ?? .empty
        let resolvedFireDate = Self.resolvedFireDate(for: snapshot)
        snapshot.nextAlarmFireDate = resolvedFireDate
        let entry = AlarmEntry(date: .now, snapshot: snapshot)
        let policy: TimelineReloadPolicy = resolvedFireDate.map { .after($0) } ?? .never
        completion(Timeline(entries: [entry], policy: policy))
    }

    /// Recomputes the next fire date fresh from `alarmHour`/`alarmMinute`/
    /// `alarmWeekdays` using this call's own `.now`, rather than trusting
    /// `snapshot.nextAlarmFireDate` — see the type's doc comment above.
    /// Falls back to that stored value only if the raw fields are missing
    /// (a snapshot written before this field existed).
    private static func resolvedFireDate(for snapshot: WidgetSnapshot) -> Date? {
        guard snapshot.alarmEnabled else { return nil }
        guard let hour = snapshot.alarmHour, let minute = snapshot.alarmMinute, let weekdays = snapshot.alarmWeekdays else {
            return snapshot.nextAlarmFireDate
        }
        return AlarmNextFireDate.next(hour: hour, minute: minute, weekdays: weekdays)
    }
}

struct DinoHatchAlarmWidgetView: View {
    var entry: AlarmProvider.Entry

    private var snapshot: WidgetSnapshot { entry.snapshot }

    var body: some View {
        VStack(alignment: .leading, spacing: 6) {
            HStack(spacing: 6) {
                Image("alarm-egg-widget")
                    .resizable()
                    .scaledToFit()
                    .frame(width: 22, height: 22)
                Text("Dino Alarm")
                    .font(.system(size: 13, weight: .bold, design: .rounded))
                    .foregroundStyle(.secondary)
            }

            Spacer(minLength: 4)

            if snapshot.alarmEnabled, let fireDate = snapshot.nextAlarmFireDate {
                Text(fireDate, style: .timer)
                    .font(.system(size: 24, weight: .bold, design: .rounded))
                    .monospacedDigit()
                    .minimumScaleFactor(0.6)
                    .lineLimit(1)
                Text(fireDate, style: .time)
                    .font(.system(size: 12, weight: .semibold, design: .rounded))
                    .foregroundStyle(.secondary)
            } else {
                Text("No alarm set")
                    .font(.system(size: 15, weight: .semibold, design: .rounded))
                    .foregroundStyle(.secondary)
            }
        }
        .frame(maxWidth: .infinity, alignment: .leading)
        .overlay(alignment: .topTrailing) {
            WidgetSupporterBadge(tier: snapshot.supporterTier)
                .padding(6)
        }
        .containerBackground(for: .widget) {
            LinearGradient(
                colors: [Color(red: 0.93, green: 0.96, blue: 1.00), Color(red: 0.89, green: 0.94, blue: 0.84)],
                startPoint: .top, endPoint: .bottom
            )
        }
    }
}

struct DinoHatchAlarmWidget: Widget {
    var body: some WidgetConfiguration {
        StaticConfiguration(kind: WidgetSnapshotStore.alarmWidgetKind, provider: AlarmProvider()) { entry in
            DinoHatchAlarmWidgetView(entry: entry)
        }
        .configurationDisplayName("Dino Alarm")
        .description("See the countdown to your next dino alarm.")
        .supportedFamilies([.systemSmall])
    }
}

#Preview(as: .systemSmall) {
    DinoHatchAlarmWidget()
} timeline: {
    AlarmEntry(
        date: .now,
        snapshot: WidgetSnapshot(unlockedCount: 4, totalCount: 26, alarmEnabled: true, nextAlarmFireDate: .now.addingTimeInterval(9 * 3600))
    )
}
