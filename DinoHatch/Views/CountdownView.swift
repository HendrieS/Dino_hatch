import SwiftUI
import UIKit

struct CountdownView: View {
    var engine: TimerEngine
    var onComplete: () -> Void
    var onCancel: () -> Void

    @State private var hasCompleted = false

    var body: some View {
        NavigationStack {
            countdownContent
                .navigationTitle("Dino Hatch")
                .navigationBarTitleDisplayMode(.inline)
        }
    }

    /// Matches `TimerSetupView`'s own `NavigationStack` + inline "Dino
    /// Hatch" title exactly, rather than leaving this screen title-less —
    /// without it, switching from setup to counting dropped the whole nav
    /// bar, so everything below (including the Cancel Timer button) jumped
    /// up by that bar's height the instant the timer started.
    private var countdownContent: some View {
        VStack(spacing: 40) {
            Spacer()

            if let endDate = engine.endDate {
                Text(endDate, style: .timer)
                    .font(.system(size: 56, weight: .bold, design: .rounded))
                    .monospacedDigit()
            }

            TimelineView(.periodic(from: .now, by: 0.1)) { context in
                EggView(remainingFraction: engine.remainingFraction(at: context.date), date: context.date)
                    // Watches the completion Bool rather than `context.date`
                    // itself — a raw `Date` changes on every 0.1s tick, and
                    // SwiftUI logs "action tried to update multiple times
                    // per frame" for `onChange(of:)` on a value that churns
                    // that fast. The Bool only flips once (false → true).
                    .onChange(of: engine.isComplete(at: context.date)) { _, isComplete in
                        guard !hasCompleted, isComplete else { return }
                        hasCompleted = true
                        onComplete()
                    }
            }
            .frame(height: 220)

            Button(role: .destructive) {
                engine.cancel()
                onCancel()
            } label: {
                HStack(spacing: 8) {
                    Image("button-footprint-stop")
                        .resizable()
                        .scaledToFit()
                        .frame(width: 22, height: 22)
                    Text("Cancel Timer")
                }
                .font(.title3.bold())
                .frame(maxWidth: .infinity)
                .padding()
                .background(Color.dinoRed)
                .foregroundStyle(.white)
                .clipShape(RoundedRectangle(cornerRadius: 20))
            }
            .padding(.horizontal, 32)

            Spacer()
            Spacer()
        }
        .padding()
        .dinoWarmBackground()
        // Keep the screen awake for the duration of the countdown so it
        // doesn't lock mid-timer; restored as soon as this view goes away
        // (cancelled, hatched, or navigated off).
        .onAppear { UIApplication.shared.isIdleTimerDisabled = true }
        .onDisappear { UIApplication.shared.isIdleTimerDisabled = false }
    }
}
