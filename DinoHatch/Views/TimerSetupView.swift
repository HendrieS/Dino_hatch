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
            .onAppear {
                totalSeconds = min(engine.lastUsedDuration, CircularDurationPicker.maxSeconds)
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
