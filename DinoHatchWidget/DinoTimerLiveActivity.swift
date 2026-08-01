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
        } dynamicIsland: { context in
            DynamicIsland {
                DynamicIslandExpandedRegion(.leading) {
                    DinoWidgetImage(assetName: "egg-hatch-1", emoji: "🥚", size: 28)
                }
                DynamicIslandExpandedRegion(.trailing) {
                    Text(context.state.endDate, style: .timer)
                        .font(.system(size: 20, weight: .bold, design: .rounded))
                        .monospacedDigit()
                }
                DynamicIslandExpandedRegion(.bottom) {
                    Text(verbatim: "Dino Hatch")
                        .font(.system(size: 12, weight: .semibold, design: .rounded))
                        .foregroundStyle(.secondary)
                }
            } compactLeading: {
                Text(verbatim: "🥚")
            } compactTrailing: {
                Text(context.state.endDate, style: .timer)
                    .font(.system(size: 13, weight: .bold, design: .rounded))
                    .monospacedDigit()
                    .frame(width: 42)
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
                Text(context.state.endDate, style: .timer)
                    .font(.system(size: 28, weight: .bold, design: .rounded))
                    .monospacedDigit()
            }
            Spacer()
            WidgetSupporterBadge(tier: context.state.supporterTierRawValue.flatMap(SupporterTier.init(rawValue:)))
        }
        .padding(16)
    }
}
