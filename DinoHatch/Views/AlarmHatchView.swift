import SwiftUI

/// Full-screen hatch celebration shown when a dino-alarm reward is ready to
/// claim. Mirrors the timer's hatching -> reveal sequence, but skips the
/// countdown screen entirely since the wait already happened overnight.
struct AlarmHatchView: View {
    let dinosaur: Dinosaur
    var onUnlock: () -> Void
    var onDone: () -> Void

    @State private var revealed = false

    var body: some View {
        Group {
            if revealed {
                HatchRevealView(dinosaur: dinosaur, onDismiss: onDone)
                    .transition(.opacity)
            } else {
                HatchAnimationView(dinosaur: dinosaur) {
                    onUnlock()
                    withAnimation(.easeInOut(duration: 0.4)) {
                        revealed = true
                    }
                }
                .transition(.opacity)
            }
        }
    }
}

#Preview {
    AlarmHatchView(dinosaur: DinosaurCatalog.all[0]) {} onDone: {}
}
