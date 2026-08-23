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
                    // rather than scrolling away with them. The offset
                    // itself is unchanged from before this split — still
                    // -84 against this VStack's own 40pt top inset (from
                    // `.padding()` + `.padding(.top, 24)` below) — only
                    // where the sign lives in the hierarchy changed, not
                    // its rendered position.
                    .offset(y: -84)

                ScrollView {
                    VStack(spacing: 32) {
                        CircularDurationPicker(totalSeconds: $totalSeconds)
                            // -82 reproduces the exact gap the old -114 did
                            // back when this sat right after the sign in
                            // one shared VStack (32 declared spacing - 114
                            // = -82 net): now that this is the ScrollView's
                            // own first child, it gets no automatic spacing
                            // before it, so that 32 has to be folded
                            // directly into this padding instead.
                            .padding(.top, -82)
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
            .padding(.top)
            .padding(.top, 24)
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
