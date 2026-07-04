import SwiftUI
import SwiftData

struct TimerHomeView: View {
    @Environment(\.modelContext) private var modelContext
    @Query private var unlockedDinosaurs: [UnlockedDinosaur]
    @State private var engine = TimerEngine()
    @State private var phase: Phase = .setup
    @State private var hatchedDinosaur: Dinosaur?

    private enum Phase {
        case setup, counting, hatching, reveal
    }

    var body: some View {
        Group {
            switch phase {
            case .setup:
                TimerSetupView(engine: engine) { dinosaur in
                    hatchedDinosaur = dinosaur
                    phase = .counting
                }
            case .counting:
                CountdownView(engine: engine) {
                    phase = .hatching
                } onCancel: {
                    hatchedDinosaur = nil
                    phase = .setup
                }
            case .hatching:
                if let hatchedDinosaur {
                    HatchAnimationView(dinosaur: hatchedDinosaur) {
                        unlock(hatchedDinosaur)
                        engine.completeHatch()
                        phase = .reveal
                    }
                }
            case .reveal:
                if let hatchedDinosaur {
                    HatchRevealView(dinosaur: hatchedDinosaur) {
                        self.hatchedDinosaur = nil
                        phase = .setup
                    }
                }
            }
        }
        .onAppear {
            engine.configure(context: modelContext)
            resumeIfNeeded()
        }
    }

    private func resumeIfNeeded() {
        guard engine.isRunning, let pendingID = engine.pendingDinosaurID else { return }
        let dinosaur = DinosaurCatalog.all.first(where: { $0.id == pendingID }) ?? DinosaurCatalog.all[0]
        hatchedDinosaur = dinosaur
        phase = engine.isComplete() ? .hatching : .counting
    }

    private func unlock(_ dinosaur: Dinosaur) {
        guard !unlockedDinosaurs.contains(where: { $0.dinosaurID == dinosaur.id }) else { return }
        modelContext.insert(UnlockedDinosaur(dinosaurID: dinosaur.id))
    }
}
