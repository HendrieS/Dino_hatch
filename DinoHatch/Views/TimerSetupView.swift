import SwiftUI
import SwiftData

struct TimerSetupView: View {
    var engine: TimerEngine
    var onStart: (Dinosaur) -> Void

    @Query private var unlockedDinosaurs: [UnlockedDinosaur]
    @State private var totalSeconds: Int = 300

    var body: some View {
        NavigationStack {
            VStack(spacing: 32) {
                Spacer()

                Text("Set a timer and watch\nan egg hatch!")
                    .font(.title2.bold())
                    .multilineTextAlignment(.center)

                CircularDurationPicker(totalSeconds: $totalSeconds)

                Button {
                    startTimer()
                } label: {
                    Text("Start Timer")
                        .font(.title3.bold())
                        .frame(maxWidth: .infinity)
                        .padding()
                        .background(totalSeconds > 0 ? Color.dinoGreen : Color.gray)
                        .foregroundStyle(.white)
                        .clipShape(RoundedRectangle(cornerRadius: 20))
                }
                .disabled(totalSeconds == 0)
                .padding(.horizontal, 32)

                Spacer()
                Spacer()
            }
            .padding()
            .navigationTitle("Dino Hatch")
            .navigationBarTitleDisplayMode(.inline)
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
