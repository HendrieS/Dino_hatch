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
    /// Mirrors whether `phase` is `.hatching`/`.reveal` — `RootTabView`
    /// hides `FloatingNavMenu` while this is true, since those two phases
    /// are full-screen celebratory moments (matching how the menu is
    /// already absent during the similarly celebratory `AlarmHatchView`
    /// full-screen cover) rather than "the Timer screen" a kid would
    /// expect to navigate away from mid-animation.
    @Binding var isCelebrating: Bool

    @Environment(\.modelContext) private var modelContext
    @Environment(\.scenePhase) private var scenePhase
    @Query private var unlockedDinosaurs: [UnlockedDinosaur]
    @State private var engine = TimerEngine()
    @State private var phase: Phase = .setup
    @State private var hatchedDinosaur: Dinosaur?
    @State private var isReadyToHatch = false

    private enum Phase {
        case setup, counting, hatching, reveal
    }

    var body: some View {
        // Split from the modifier chain below into its own @ViewBuilder
        // property — inlined together, the switch's four branches plus
        // five chained modifiers made one expression large enough that the
        // compiler couldn't type-check it in reasonable time (hit after
        // adding the isCelebrating onChange, the straw that broke an
        // already-long chain). Solving `content`'s type separately first
        // gives the type-checker a much smaller problem for `body` itself.
        content
            // Unlike AlarmView/CollectionView, this tab has no
            // NavigationStack of its own to hang a .topBarLeading toolbar
            // item off of, so the badge is a plain corner overlay here
            // instead — may need a padding/position tweak once seen on a
            // real device.
            .overlay(alignment: .topLeading) {
                SupporterBadgeView()
                    .padding()
            }
            .onAppear {
                engine.configure(context: modelContext)
                resumeIfNeeded()
            }
            .onChange(of: isActive) { _, active in
                guard active, isReadyToHatch else { return }
                isReadyToHatch = false
                phase = .hatching
            }
            .onChange(of: scenePhase) { _, newPhase in
                // Only while still on the setup screen — engine.isRunning
                // stays true through .hatching/.reveal too (cleared only
                // once the animation finishes), so re-running this
                // unconditionally would yank a mid-animation view back to
                // .counting. Needed because the Quick Timer widget's
                // StartTimerIntent can now start a timer while this view
                // was already on screen but the app was merely backgrounded
                // (not relaunched, so .onAppear above doesn't fire again).
                guard newPhase == .active, phase == .setup else { return }
                engine.restoreFromSettings()
                resumeIfNeeded()
            }
            .onChange(of: phase) { _, newPhase in
                isCelebrating = newPhase == .hatching || newPhase == .reveal
            }
    }

    @ViewBuilder
    private var content: some View {
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
                    withAnimation(.easeInOut(duration: 0.4)) {
                        phase = .reveal
                    }
                }
                .transition(.opacity)
            }
        case .reveal:
            if let hatchedDinosaur {
                HatchRevealView(dinosaur: hatchedDinosaur) {
                    self.hatchedDinosaur = nil
                    phase = .setup
                }
                .transition(.opacity)
            }
        }
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
    TimerHomeView(isActive: true, isCelebrating: .constant(false))
        .modelContainer(for: [UnlockedDinosaur.self, AppSettings.self], inMemory: true)
}
