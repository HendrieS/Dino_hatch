import WidgetKit
import SwiftUI

struct QuickTimerEntry: TimelineEntry {
    let date: Date
    let snapshot: WidgetSnapshot
}

/// Single-entry timeline, same reasoning as `AlarmProvider` — a running
/// timer's countdown is rendered live by `Text(_:style: .timer)`, driven by
/// the system rather than repeated reloads. `RootTabView` reloads this
/// widget's timeline whenever the timer starts, is cancelled, or completes.
struct QuickTimerProvider: TimelineProvider {
    func placeholder(in context: Context) -> QuickTimerEntry {
        QuickTimerEntry(date: .now, snapshot: .empty)
    }

    func getSnapshot(in context: Context, completion: @escaping (QuickTimerEntry) -> Void) {
        completion(QuickTimerEntry(date: .now, snapshot: WidgetSnapshotStore.load() ?? .empty))
    }

    func getTimeline(in context: Context, completion: @escaping (Timeline<QuickTimerEntry>) -> Void) {
        let entry = QuickTimerEntry(date: .now, snapshot: WidgetSnapshotStore.load() ?? .empty)
        completion(Timeline(entries: [entry], policy: .never))
    }
}

/// Three states: no timer running shows the four quick-start buttons, which
/// start a timer via `StartTimerIntent` without opening the app; a running
/// timer shows a live countdown instead (buttons are hidden rather than
/// left tappable-but-ignored, matching `TimerHomeView`'s silent-ignore
/// behavior for a stray tap while already counting down) — tapping the
/// countdown *does* open the app, since there's no `Link`/`Button`
/// intercepting that region; and a timer whose end date has already
/// passed — finished, but not yet opened in the app to play the hatch
/// animation — shows a "ready" state instead of an odd-looking countdown
/// ticking past zero, also tappable to open the app.
struct DinoHatchQuickTimerWidgetView: View {
    var entry: QuickTimerProvider.Entry

    private var snapshot: WidgetSnapshot { entry.snapshot }

    var body: some View {
        VStack(alignment: .leading, spacing: 10) {
            header

            if let endDate = snapshot.activeTimerEndDate {
                if endDate > entry.date {
                    countdownView(endDate: endDate)
                } else {
                    readyView
                }
            } else {
                buttonsView
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

    private var header: some View {
        HStack(spacing: 6) {
            Image("egg-hatch-1-widget")
                .resizable()
                .scaledToFit()
                .frame(width: 20, height: 20)
            Text("Quick Timer")
                .font(.system(size: 13, weight: .bold, design: .rounded))
                .foregroundStyle(.secondary)
        }
    }

    private func countdownView(endDate: Date) -> some View {
        HStack(spacing: 14) {
            DinoWidgetImage(assetName: snapshot.activeTimerDinosaurImageAssetName, emoji: snapshot.activeTimerDinosaurEmoji, size: 44)
            Text(endDate, style: .timer)
                .font(.system(size: 32, weight: .bold, design: .rounded))
                .monospacedDigit()
                .minimumScaleFactor(0.6)
                .lineLimit(1)
        }
    }

    private var readyView: some View {
        HStack(spacing: 10) {
            DinoWidgetImage(assetName: snapshot.activeTimerDinosaurImageAssetName, emoji: snapshot.activeTimerDinosaurEmoji, size: 36)
            Text("An egg is ready to hatch!")
                .font(.system(size: 15, weight: .bold, design: .rounded))
        }
    }

    /// Each duration is an `AppIntent`-backed `Button` (interactive widgets,
    /// iOS 17+) rather than a `Link` — starting a timer this way runs
    /// `StartTimerIntent` right in the widget extension process and never
    /// opens the app, unlike the countdown/ready states below, which fall
    /// back to the default "tap anywhere opens the app" behavior since they
    /// contain no `Link`/`Button` of their own.
    private var buttonsView: some View {
        HStack(spacing: 8) {
            ForEach(QuickTimerDurations.allowedMinutes, id: \.self) { minutes in
                Button(intent: StartTimerIntent(minutes: minutes)) {
                    VStack(spacing: 2) {
                        Text(minutes, format: .number)
                            .font(.system(size: 20, weight: .bold, design: .rounded))
                        Text("min")
                            .font(.system(size: 10, weight: .semibold, design: .rounded))
                            .foregroundStyle(.secondary)
                    }
                    .frame(maxWidth: .infinity)
                    .padding(.vertical, 10)
                    .background(
                        Color(red: 0.20, green: 0.62, blue: 0.42).opacity(0.16),
                        in: RoundedRectangle(cornerRadius: 12, style: .continuous)
                    )
                }
                .buttonStyle(.plain)
            }
        }
    }
}

struct DinoHatchQuickTimerWidget: Widget {
    var body: some WidgetConfiguration {
        StaticConfiguration(kind: WidgetSnapshotStore.quickTimerWidgetKind, provider: QuickTimerProvider()) { entry in
            DinoHatchQuickTimerWidgetView(entry: entry)
        }
        .configurationDisplayName("Quick Timer")
        .description("Start a 5, 10, 15, or 30 minute timer right from the Home Screen, and see the time left.")
        .supportedFamilies([.systemMedium])
    }
}

#Preview("Buttons", as: .systemMedium) {
    DinoHatchQuickTimerWidget()
} timeline: {
    QuickTimerEntry(date: .now, snapshot: .empty)
}

#Preview("Counting down", as: .systemMedium) {
    DinoHatchQuickTimerWidget()
} timeline: {
    QuickTimerEntry(
        date: .now,
        snapshot: WidgetSnapshot(
            unlockedCount: 4, totalCount: 26,
            activeTimerEndDate: .now.addingTimeInterval(600),
            activeTimerDinosaurEmoji: "🦕", activeTimerDinosaurImageAssetName: "brachiosaurus-skin"
        )
    )
}

#Preview("Ready", as: .systemMedium) {
    DinoHatchQuickTimerWidget()
} timeline: {
    QuickTimerEntry(
        date: .now,
        snapshot: WidgetSnapshot(
            unlockedCount: 4, totalCount: 26,
            activeTimerEndDate: .now.addingTimeInterval(-30),
            activeTimerDinosaurEmoji: "🦕", activeTimerDinosaurImageAssetName: "brachiosaurus-skin"
        )
    )
}
