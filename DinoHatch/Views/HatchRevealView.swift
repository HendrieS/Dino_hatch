import SwiftUI

struct HatchRevealView: View {
    let dinosaur: Dinosaur
    var onDismiss: () -> Void

    // Drives the reveal's entrance pop and the success haptic that
    // accompanies it — false for one frame after appearing, then flipped
    // inside a spring animation, so the reward actually lands with a beat
    // instead of the whole card just being present on the first frame.
    @State private var hasAppeared = false

    var body: some View {
        VStack(spacing: 24) {
            Spacer()

            Text("A dinosaur hatched!")
                .font(.title2.bold())
                .opacity(hasAppeared ? 1 : 0)

            DinoImageView(dinosaur: dinosaur, size: 180)
                .scaleEffect(hasAppeared ? 1 : 0.4)
                .opacity(hasAppeared ? 1 : 0)

            Text(localizedContent: dinosaur.name)
                .font(.largeTitle.bold())
                .fontDesign(.rounded)
                .multilineTextAlignment(.center)
                .opacity(hasAppeared ? 1 : 0)

            Text(localizedContent: dinosaur.funFact)
                .font(.body)
                .multilineTextAlignment(.center)
                .padding(.horizontal, 32)
                .foregroundStyle(.secondary)
                .opacity(hasAppeared ? 1 : 0)

            Spacer()

            Button("Awesome!", action: onDismiss)
                .buttonStyle(.dinoChunkyGreen)
                // Wider than the fun-fact text's own 32pt inset — this sits
                // right at the bottom over the fern corners, so it needs
                // extra clearance to land between them instead of over them.
                // 32 -> 56 -> 80 -> 100 all still overlapped them, confirmed on
                // device each time.
                .padding(.horizontal, 140)
                .padding(.bottom, 24)
        }
        .frame(maxWidth: 500)
        .frame(maxWidth: .infinity)
        .dinoWarmBackground()
        .onAppear {
            withAnimation(.spring(response: 0.55, dampingFraction: 0.7)) {
                hasAppeared = true
            }
        }
        .sensoryFeedback(.success, trigger: hasAppeared) { _, newValue in newValue }
    }
}

#Preview {
    HatchRevealView(dinosaur: DinosaurCatalog.all[0]) {}
}
