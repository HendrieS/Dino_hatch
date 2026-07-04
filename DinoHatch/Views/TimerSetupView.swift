import SwiftUI
import SwiftData

struct TimerSetupView: View {
    var engine: TimerEngine
    var onStart: (Dinosaur) -> Void

    @Query private var unlockedDinosaurs: [UnlockedDinosaur]
    @State private var durationMinutes: Int = 5

    private let availableMinutes = [1, 3, 5, 10, 15, 20, 30, 45, 60]

    var body: some View {
        NavigationStack {
            VStack(spacing: 32) {
                Spacer()

                Text("🥚")
                    .font(.system(size: 120))

                Text("Set a timer and watch\nan egg hatch!")
                    .font(.title2.bold())
                    .multilineTextAlignment(.center)

                DurationPickerView(minutes: $durationMinutes, options: availableMinutes)

                Button {
                    startTimer()
                } label: {
                    Text("Start Timer")
                        .font(.title3.bold())
                        .frame(maxWidth: .infinity)
                        .padding()
                        .background(Color.dinoGreen)
                        .foregroundStyle(.white)
                        .clipShape(RoundedRectangle(cornerRadius: 20))
                }
                .padding(.horizontal, 32)

                Spacer()
                Spacer()
            }
            .navigationTitle("Dino Hatch")
            .onAppear {
                durationMinutes = closestOption(to: max(1, engine.lastUsedDuration / 60))
            }
        }
    }

    private func closestOption(to value: Int) -> Int {
        availableMinutes.min(by: { abs($0 - value) < abs($1 - value) }) ?? value
    }

    private func startTimer() {
        let unlockedIDs = Set(unlockedDinosaurs.map(\.dinosaurID))
        let dinosaur = HatchSelector.pickNext(unlockedIDs: unlockedIDs)
        engine.start(duration: TimeInterval(durationMinutes * 60), hatching: dinosaur.id)
        onStart(dinosaur)
    }
}
