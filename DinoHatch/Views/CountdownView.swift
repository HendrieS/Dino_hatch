import SwiftUI

struct CountdownView: View {
    var engine: TimerEngine
    var onComplete: () -> Void
    var onCancel: () -> Void

    @State private var hasCompleted = false

    var body: some View {
        VStack(spacing: 40) {
            Spacer()

            if let endDate = engine.endDate {
                Text(endDate, style: .timer)
                    .font(.system(size: 56, weight: .bold, design: .rounded))
                    .monospacedDigit()
            }

            TimelineView(.periodic(from: .now, by: 0.1)) { context in
                EggView(remainingFraction: engine.remainingFraction(at: context.date), date: context.date)
                    .onChange(of: context.date) { _, newDate in
                        guard !hasCompleted, engine.isComplete(at: newDate) else { return }
                        hasCompleted = true
                        onComplete()
                    }
            }
            .frame(height: 220)

            Button("Cancel Timer", role: .destructive) {
                engine.cancel()
                onCancel()
            }

            Spacer()
            Spacer()
        }
        .padding()
    }
}
