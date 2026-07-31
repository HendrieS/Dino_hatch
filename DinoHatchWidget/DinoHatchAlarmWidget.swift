import WidgetKit
import SwiftUI

struct AlarmEntry: TimelineEntry {
    let date: Date
    let snapshot: WidgetSnapshot
}

/// Single-entry timeline, same reasoning as `CollectionProvider` — the
/// countdown itself is rendered live by `Text(_:style: .timer)`, driven by
/// the system rather than by repeated timeline reloads. `RootTabView`
/// reloads this widget's timeline whenever the alarm's settings change or
/// its next fire date has simply passed.
struct AlarmProvider: TimelineProvider {
    func placeholder(in context: Context) -> AlarmEntry {
        AlarmEntry(date: .now, snapshot: WidgetSnapshot(unlockedCount: 0, totalCount: 26, alarmEnabled: true, nextAlarmFireDate: .now.addingTimeInterval(3600)))
    }

    func getSnapshot(in context: Context, completion: @escaping (AlarmEntry) -> Void) {
        completion(AlarmEntry(date: .now, snapshot: WidgetSnapshotStore.load() ?? .empty))
    }

    func getTimeline(in context: Context, completion: @escaping (Timeline<AlarmEntry>) -> Void) {
        let entry = AlarmEntry(date: .now, snapshot: WidgetSnapshotStore.load() ?? .empty)
        completion(Timeline(entries: [entry], policy: .never))
    }
}

struct DinoHatchAlarmWidgetView: View {
    var entry: AlarmProvider.Entry

    private var snapshot: WidgetSnapshot { entry.snapshot }

    var body: some View {
        VStack(alignment: .leading, spacing: 6) {
            HStack(spacing: 6) {
                Image("alarm-egg")
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
