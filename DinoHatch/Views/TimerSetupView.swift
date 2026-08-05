import SwiftUI
import SwiftData

struct TimerSetupView: View {
    var engine: TimerEngine
    var onStart: (Dinosaur) -> Void

    @Query private var unlockedDinosaurs: [UnlockedDinosaur]
    @State private var totalSeconds: Int = 300

    var body: some View {
        NavigationStack {
            ScrollView {
                VStack(spacing: 32) {
                    SignTitleView(text: "Dino Hatch")
                        // Experimental — pulled up toward the top of the
                        // screen per user request, to see how it looks
                        // closer to the vine canopy instead of sitting in
                        // the normal content flow.
                        .offset(y: -40)

                    CircularDurationPicker(totalSeconds: $totalSeconds)
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
