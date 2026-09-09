import ActivityKit
import WidgetKit
import SwiftUI

/// Lock Screen banner + Dynamic Island presentation for a running timer.
/// `TimerEngine.start()`/`cancel()` (in-app) and `StartTimerIntent.perform()`
/// (Quick Timer widget) both drive this via `DinoTimerActivityController` —
/// wherever a timer starts, this shows up, and tapping it anywhere opens the
/// app (the default behavior for a Live Activity with no `Link`s of its
/// own, same reasoning as the Quick Timer widget's countdown/ready states).
///
/// Always shows a plain egg (`egg-hatch-1` art at the two sizes big enough
/// to read it, plain 🥚 in the compact/minimal Dynamic Island regions),
/// never the actual dinosaur that's hatching — the whole point of the
/// in-app hatch animation is the reveal, and a Live Activity sits on the
/// Lock Screen where anyone glancing at it mid-countdown would see the
/// species well before that reveal plays. There's also no reliable way to
/// swap in the real art the instant the countdown hits zero while the app
/// is backgrounded (no push/server infra here), so rather than have it
/// sometimes reveal early depending on timing, it just never reveals at
/// all — the actual reward moment stays exclusively in-app.
struct DinoTimerLiveActivity: Widget {
    var body: some WidgetConfiguration {
        ActivityConfiguration(for: DinoTimerActivityAttributes.self) { context in
            lockScreenView(context: context)
                .activityBackgroundTint(Color(red: 0.93, green: 0.96, blue: 1.00))
                .activitySystemActionForegroundColor(.black)
                // Same "always light" reasoning as the Home Screen widgets
                // (see DinoHatchCollectionWidgetView) — this banner's own
                // background is a fixed light pastel tint, so .primary/
                // .secondary text needs to stay in their light-mode colors
                // too, regardless of system Dark Mode. Deliberately NOT
                // applied to the `dynamicIsland` closure below — that
                // content renders on the system's own always-dark Island
                // chrome, where the default (dark) color scheme is already
                // correct; forcing light there would make its text
                // disappear against that dark background instead.
                .environment(\.colorScheme, .light)
        } dynamicIsland: { context in
            DynamicIsland {
                DynamicIslandExpandedRegion(.leading) {
                    DinoWidgetImage(assetName: "egg-hatch-1", emoji: "🥚", size: 28)
                }
                DynamicIslandExpandedRegion(.trailing) {
                    // `staleDate: endDate` (see DinoTimerActivityController)
                    // makes `context.isStale` true once the countdown ends —
                    // without checking it, this would keep ticking the timer
                    // text past zero indefinitely for a timer started via
                    // the widget and never opened in-app to actually finish
                    // it (same class of bug as
                    // DinoHatchQuickTimerWidgetView's countdown/ready split).
                    if context.isStale {
                        Text("Ready!")
                            .font(.system(size: 16, weight: .bold, design: .rounded))
                    } else {
                        Text(context.state.endDate, style: .timer)
                            .font(.system(size: 20, weight: .bold, design: .rounded))
                            .monospacedDigit()
                    }
                }
                DynamicIslandExpandedRegion(.bottom) {
                    Text(verbatim: "Dino Hatch")
                        .font(.system(size: 12, weight: .semibold, design: .rounded))
                        .foregroundStyle(.secondary)
                }
            } compactLeading: {
                Text(verbatim: "🥚")
            } compactTrailing: {
                if context.isStale {
                    Image(systemName: "checkmark.circle.fill")
                        .font(.system(size: 15, weight: .bold))
                        .frame(width: 42)
                } else {
                    Text(context.state.endDate, style: .timer)
                        .font(.system(size: 13, weight: .bold, design: .rounded))
                        .monospacedDigit()
                        .frame(width: 42)
                }
            } minimal: {
                Text(verbatim: "🥚")
            }
        }
    }

    private func lockScreenView(context: ActivityViewContext<DinoTimerActivityAttributes>) -> some View {
        HStack(spacing: 14) {
            DinoWidgetImage(assetName: "egg-hatch-1", emoji: "🥚", size: 48)
            VStack(alignment: .leading, spacing: 2) {
                Text(verbatim: "Dino Hatch")
                    .font(.system(size: 13, weight: .semibold, design: .rounded))
                    .foregroundStyle(.secondary)
                // Same `context.isStale` reasoning as the Dynamic Island
                // regions above — reuses the exact string
                // TimerReadyBanner/DinoHatchQuickTimerWidgetView already
                // use for this same "egg's done" moment, rather than
                // introducing a new one that would need its own
                // translations.
                if context.isStale {
                    Text("An egg is ready to hatch!")
                        .font(.system(size: 18, weight: .bold, design: .rounded))
                } else {
                    Text(context.state.endDate, style: .timer)
                        .font(.system(size: 28, weight: .bold, design: .rounded))
                        .monospacedDigit()
                }
            }
            Spacer()
            WidgetSupporterBadge(tier: context.state.supporterTierRawValue.flatMap(SupporterTier.init(rawValue:)))
        }
        .padding(16)
    }
}
