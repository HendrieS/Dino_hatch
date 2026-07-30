import ActivityKit
import WidgetKit
import SwiftUI

/// Lock Screen banner + Dynamic Island presentation for a running timer.
/// `TimerEngine.start()`/`cancel()` (in-app) and `StartTimerIntent.perform()`
/// (Quick Timer widget) both drive this via `DinoTimerActivityController` —
/// wherever a timer starts, this shows up, and tapping it anywhere opens the
/// app (the default behavior for a Live Activity with no `Link`s of its
/// own, same reasoning as the Quick Timer widget's countdown/ready states).
struct DinoTimerLiveActivity: Widget {
    var body: some WidgetConfiguration {
        ActivityConfiguration(for: DinoTimerActivityAttributes.self) { context in
            lockScreenView(context: context)
                .activityBackgroundTint(Color(red: 0.93, green: 0.96, blue: 1.00))
                .activitySystemActionForegroundColor(.black)
        } dynamicIsland: { context in
            DynamicIsland {
                DynamicIslandExpandedRegion(.leading) {
                    Text(verbatim: context.state.dinosaurEmoji ?? "🥚")
                        .font(.system(size: 28))
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
                Text(verbatim: context.state.dinosaurEmoji ?? "🥚")
            } compactTrailing: {
                Text(context.state.endDate, style: .timer)
                    .font(.system(size: 13, weight: .bold, design: .rounded))
                    .monospacedDigit()
                    .frame(width: 42)
            } minimal: {
                Text(verbatim: context.state.dinosaurEmoji ?? "🥚")
            }
        }
    }

    private func lockScreenView(context: ActivityViewContext<DinoTimerActivityAttributes>) -> some View {
        HStack(spacing: 14) {
            Text(verbatim: context.state.dinosaurEmoji ?? "🥚")
                .font(.system(size: 40))
            VStack(alignment: .leading, spacing: 2) {
                Text(verbatim: "Dino Hatch")
                    .font(.system(size: 13, weight: .semibold, design: .rounded))
                    .foregroundStyle(.secondary)
                Text(context.state.endDate, style: .timer)
                    .font(.system(size: 28, weight: .bold, design: .rounded))
                    .monospacedDigit()
            }
            Spacer()
        }
        .padding(16)
    }
}
