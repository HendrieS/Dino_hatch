import SwiftUI
import SwiftData

struct TimerHomeView: View {
    /// Whether the Timer tab is the one currently on screen — passed down
    /// from `RootTabView`'s tab selection. When the countdown finishes while
    /// this is false, the hatch animation is held off rather than played
    /// off-screen, so switching tabs (via `TimerReadyBanner` or manually)
    /// still shows the full reveal instead of a dinosaur that's already sat
    /// there waiting.
    var isActive: Bool
    @Binding var pendingQuickStartMinutes: Int?

    @Environment(\.modelContext) private var modelContext
    @Query private var unlockedDinosaurs: [UnlockedDinosaur]
    @State private var engine = TimerEngine()
    @State private var phase: Phase = .setup
    @State private var hatchedDinosaur: Dinosaur?
    @State private var isReadyToHatch = false

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
                    advanceToHatching()
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
            consumePendingQuickStart()
        }
        .onChange(of: isActive) { _, active in
            guard active, isReadyToHatch else { return }
            isReadyToHatch = false
            phase = .hatching
        }
        .onChange(of: pendingQuickStartMinutes) { _, _ in
            consumePendingQuickStart()
        }
    }

    /// Handles a `dinohatch://start-timer` tap from the Quick Timer widget
    /// (see `QuickStartLink`/`RootTabView.onOpenURL`) — silently ignored if
    /// a timer's already running rather than overwriting it, same
    /// no-hint-either-way spirit as the app's other gating.
    private func consumePendingQuickStart() {
        guard let minutes = pendingQuickStartMinutes else { return }
        pendingQuickStartMinutes = nil
        guard phase == .setup else { return }
        startTimer(seconds: minutes * 60)
    }

    private func startTimer(seconds: Int) {
        let unlockedIDs = Set(unlockedDinosaurs.map(\.dinosaurID))
        let dinosaur = HatchSelector.pickNext(unlockedIDs: unlockedIDs)
        engine.start(duration: TimeInterval(seconds), hatching: dinosaur.id)
        hatchedDinosaur = dinosaur
        phase = .counting
    }

    /// The countdown finished. Plays the hatch animation immediately if the
    /// Timer tab is visible; otherwise just remembers it's owed — see
    /// `RootTabView.isTimerReady` for the banner that alerts the kid, and
    /// `onChange(of: isActive)` above for where it actually gets played.
    private func advanceToHatching() {
        if isActive {
            phase = .hatching
        } else {
            isReadyToHatch = true
        }
    }

    private func resumeIfNeeded() {
        guard engine.isRunning, let pendingID = engine.pendingDinosaurID else { return }
        let dinosaur = DinosaurCatalog.all.first(where: { $0.id == pendingID }) ?? DinosaurCatalog.all[0]
        hatchedDinosaur = dinosaur
        phase = .counting
        if engine.isComplete() {
            advanceToHatching()
        }
    }

    private func unlock(_ dinosaur: Dinosaur) {
        guard !unlockedDinosaurs.contains(where: { $0.dinosaurID == dinosaur.id }) else { return }
        modelContext.insert(UnlockedDinosaur(dinosaurID: dinosaur.id))
    }
}

#Preview {
    TimerHomeView(isActive: true, pendingQuickStartMinutes: .constant(nil))
        .modelContainer(for: [UnlockedDinosaur.self, AppSettings.self], inMemory: true)
}
