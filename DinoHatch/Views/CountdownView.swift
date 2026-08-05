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
        }
    }

    /// Matches `TimerSetupView`'s own `NavigationStack` + `SignTitleView`
    /// exactly, rather than leaving this screen title-less — without a
    /// matching title element, switching from setup to counting dropped
    /// whatever occupied that space, so everything below (including the
    /// Cancel Timer button) jumped up the instant the timer started.
    private var countdownContent: some View {
        VStack(spacing: 40) {
            SignTitleView(text: "Dino Hatch")
                // Experimental — see TimerSetupView's matching offset.
                .offset(y: -80)

            Spacer()

            // Same ring + egg composition as CircularDurationPicker's setup
            // state (260pt diameter, matching), so starting the timer feels
            // like a continuation rather than a completely different
            // screen — the ring's progress arc now shrinks as the egg's
            // own remainingFraction does, rather than being a separate
            // static duration display. The live countdown text moves below
            // the ring instead of above the egg, same layout as setup.
            TimelineView(.periodic(from: .now, by: 0.1)) { context in
                VStack(spacing: 12) {
                    ZStack {
                        DialRingView(progress: engine.remainingFraction(at: context.date))
                            .frame(width: 260, height: 260)
                        EggView(remainingFraction: engine.remainingFraction(at: context.date), date: context.date)
                    }
                    .frame(width: 260, height: 260)
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

                    if let endDate = engine.endDate {
                        Text(endDate, style: .timer)
                            .font(.system(size: 40, weight: .bold, design: .rounded))
                            .monospacedDigit()
                    }
                }
            }

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
        // Matches TimerSetupView's own extra top padding so SignTitleView
        // lands at the same vertical position in both screens — now that
        // the sign is a real VStack element (not native nav bar chrome
        // with OS-guaranteed matching height), any padding mismatch here
        // would reintroduce the very jump this screen's title element was
        // added to prevent.
        .padding(.top, 24)
        .dinoWarmBackground()
        // Keep the screen awake for the duration of the countdown so it
        // doesn't lock mid-timer; restored as soon as this view goes away
        // (cancelled, hatched, or navigated off).
        .onAppear { UIApplication.shared.isIdleTimerDisabled = true }
        .onDisappear { UIApplication.shared.isIdleTimerDisabled = false }
    }
}
