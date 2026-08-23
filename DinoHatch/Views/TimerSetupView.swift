import SwiftUI
import SwiftData

struct TimerSetupView: View {
    var engine: TimerEngine
    var onStart: (Dinosaur) -> Void

    @Query private var unlockedDinosaurs: [UnlockedDinosaur]
    @State private var totalSeconds: Int = 300
    @State private var showSettings = false

    var body: some View {
        NavigationStack {
            VStack(spacing: 0) {
                SignTitleView(text: "Dino Hatch")
                    // Pinned here, outside the ScrollView below, so it stays
                    // fixed in place while the ring/button scroll underneath
                    // rather than scrolling away with them. Uses `.padding`
                    // rather than the `.offset` this used before switching
                    // to a pinned header — offset doesn't shrink the space
                    // a view reserves for layout, so the ScrollView below
                    // still started as if the sign were in its original,
                    // un-shifted spot, leaving a large dead gap above the
                    // ring. Padding actually pulls the sign up, closing
                    // that gap. -44 renders at the exact same position as
                    // before (this screen's old 40pt top inset combined
                    // with its old -84 offset).
                    .padding(.top, -44)

                // FitScrollView (not a plain ScrollView) so this doesn't
                // scroll/bounce on taller devices where the ring and button
                // already fit without it.
                FitScrollView {
                    VStack(spacing: 32) {
                        CircularDurationPicker(totalSeconds: $totalSeconds)
                            // Small, deliberately tight gap below the sign —
                            // matches the confirmed-correct spacing from
                            // before the fix above.
                            .padding(.top, 2)
                        // CircularDurationPicker's own frame already reserves
                        // the full space its labels need (see
                        // `interactiveDiameter`), so no extra padding is
                        // required here to keep the Start Timer button clear.

                        Button {
                            startTimer()
                        } label: {
                            HStack(spacing: 8) {
                                Image("button-footprint-play")
                                    .resizable()
                                    .scaledToFit()
                                    .frame(width: 22, height: 22)
                                Text("Start Timer")
                            }
                        }
                        .buttonStyle(
                            ChunkyButtonStyle(
                                color: totalSeconds > 0 ? .dinoGreen : .gray,
                                edgeColor: totalSeconds > 0 ? .dinoGreenShadow : .dinoGrayShadow
                            )
                        )
                        .disabled(totalSeconds == 0)
                        .padding(.horizontal, 32)
                    }
                    .padding(.bottom)
                }
            }
            .padding(.horizontal)
            .frame(maxWidth: 500)
            .frame(maxWidth: .infinity)
            .dinoWarmBackground()
            .toolbar {
                ToolbarItem(placement: .topBarTrailing) {
                    Button {
                        showSettings = true
                    } label: {
                        Image(systemName: "gearshape.fill")
                    }
                }
            }
            // Full screen rather than a sheet — see CollectionView's
            // matching change for Settings; same bleeding fauna background
            // reasoning applies here.
            .fullScreenCover(isPresented: $showSettings) {
                ParentalGateView()
            }
            .onAppear {
                // Round to the dial's snap grid in case a duration was
                // saved under a different grid (e.g. a prior build's
                // 5-minute stops).
                let snap = CircularDurationPicker.snapSeconds
                let clamped = min(engine.lastUsedDuration, CircularDurationPicker.maxSeconds)
                totalSeconds = (clamped / snap) * snap
            }
        }
    }

    private func startTimer() {
        guard totalSeconds > 0 else { return }
        let unlockedIDs = Set(unlockedDinosaurs.map(\.dinosaurID))
        let dinosaur = HatchSelector.pickNext(unlockedIDs: unlockedIDs)
        engine.start(duration: TimeInterval(totalSeconds), hatching: dinosaur.id)
        onStart(dinosaur)
    }
}
