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
            ScrollView {
                VStack(spacing: 32) {
                    SignTitleView(text: "Dino Hatch")
                        // -40 is the original experimental "pulled up toward
                        // the top" offset; the extra -44 compensates for the
                        // nav bar that appeared once this screen got its own
                        // Settings gear (it previously had no toolbar at
                        // all, so nothing reserved that space) — without it,
                        // the sign renders a full nav-bar-height lower than
                        // this offset implies.
                        .offset(y: -84)

                    CircularDurationPicker(totalSeconds: $totalSeconds)
                        // -84 closes the gap the sign's own -84 offset above
                        // leaves behind (see SignTitleView's comment); the
                        // extra -30 on top of that tightens the sign-to-ring
                        // gap further per direct feedback (marked with two
                        // reference lines on a device screenshot showing the
                        // target spacing) and frees a bit more room at the
                        // bottom for the planned button redesign (task #26).
                        .padding(.top, -114)
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
                        .font(.title3.bold())
                        .frame(maxWidth: .infinity)
                        .padding()
                        .background(totalSeconds > 0 ? Color.dinoGreen : Color.gray)
                        .foregroundStyle(.white)
                        .clipShape(RoundedRectangle(cornerRadius: 20))
                    }
                    .disabled(totalSeconds == 0)
                    .padding(.horizontal, 32)
                }
                .padding()
                .padding(.top, 24)
                .frame(maxWidth: 500)
                .frame(maxWidth: .infinity)
            }
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
