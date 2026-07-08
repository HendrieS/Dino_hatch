import SwiftUI
import SwiftData

struct TimerSetupView: View {
    var engine: TimerEngine
    var onStart: (Dinosaur) -> Void

    @Query private var unlockedDinosaurs: [UnlockedDinosaur]
    @State private var minutes: Int = 5
    @State private var seconds: Int = 0

    private var totalSeconds: Int { minutes * 60 + seconds }

    var body: some View {
        NavigationStack {
            VStack(spacing: 32) {
                Spacer()

                Text("🥚")
                    .font(.system(size: 120))

                Text("Set a timer and watch\nan egg hatch!")
                    .font(.title2.bold())
                    .multilineTextAlignment(.center)

                DurationPickerView(minutes: $minutes, seconds: $seconds)

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
            .navigationTitle("Dino Hatch")
            .onAppear {
                let last = engine.lastUsedDuration
                minutes = last / 60
                seconds = last % 60
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
