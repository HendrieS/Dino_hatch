import WidgetKit
import SwiftUI

/// No per-instance data to show — a fixed row of duration buttons — so this
/// is a placeholder entry purely to satisfy `TimelineProvider`. Like
/// `CollectionProvider`, there's nothing to poll for, so a single entry with
/// `policy: .never` is enough.
struct QuickTimerEntry: TimelineEntry {
    let date: Date
}

struct QuickTimerProvider: TimelineProvider {
    func placeholder(in context: Context) -> QuickTimerEntry {
        QuickTimerEntry(date: .now)
    }

    func getSnapshot(in context: Context, completion: @escaping (QuickTimerEntry) -> Void) {
        completion(QuickTimerEntry(date: .now))
    }

    func getTimeline(in context: Context, completion: @escaping (Timeline<QuickTimerEntry>) -> Void) {
        completion(Timeline(entries: [QuickTimerEntry(date: .now)], policy: .never))
    }
}

/// Each duration is its own `Link` (a distinct tap target within the same
/// medium-sized widget, supported since iOS 14) rather than one button that
/// opens the app to a picker — tapping "10" should start a 10-minute timer
/// immediately, the same one-tap promise as the rest of this feature.
struct DinoHatchQuickTimerWidgetView: View {
    var body: some View {
        VStack(alignment: .leading, spacing: 10) {
            HStack(spacing: 6) {
                Text(verbatim: "🥚")
                    .font(.system(size: 18))
                Text("Quick Timer")
                    .font(.system(size: 13, weight: .bold, design: .rounded))
                    .foregroundStyle(.secondary)
            }

            HStack(spacing: 8) {
                ForEach(QuickStartLink.allowedMinutes, id: \.self) { minutes in
                    Link(destination: QuickStartLink.url(forMinutes: minutes)) {
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
                }
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

struct DinoHatchQuickTimerWidget: Widget {
    var body: some WidgetConfiguration {
        StaticConfiguration(kind: "DinoHatchQuickTimerWidget", provider: QuickTimerProvider()) { _ in
            DinoHatchQuickTimerWidgetView()
        }
        .configurationDisplayName("Quick Timer")
        .description("Start a 5, 10, 15, or 30 minute timer right from the Home Screen.")
        .supportedFamilies([.systemMedium])
    }
}

#Preview(as: .systemMedium) {
    DinoHatchQuickTimerWidget()
} timeline: {
    QuickTimerEntry(date: .now)
}
