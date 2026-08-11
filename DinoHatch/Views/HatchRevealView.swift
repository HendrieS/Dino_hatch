import SwiftUI

struct HatchRevealView: View {
    let dinosaur: Dinosaur
    var onDismiss: () -> Void

    var body: some View {
        VStack(spacing: 24) {
            Spacer()

            Text("A dinosaur hatched!")
                .font(.title2.bold())

            DinoImageView(dinosaur: dinosaur, size: 180)

            Text(localizedContent: dinosaur.name)
                .font(.largeTitle.bold())
                .fontDesign(.rounded)
                .multilineTextAlignment(.center)

            Text(localizedContent: dinosaur.funFact)
                .font(.body)
                .multilineTextAlignment(.center)
                .padding(.horizontal, 32)
                .foregroundStyle(.secondary)

            Spacer()

            Button("Awesome!", action: onDismiss)
                .buttonStyle(.dinoChunkyGreen)
                // Wider than the fun-fact text's own 32pt inset — this sits
                // right at the bottom over the fern corners, so it needs
                // extra clearance to land between them instead of over them.
                // 56 wasn't enough to clear them, confirmed on device.
                .padding(.horizontal, 80)
                .padding(.bottom, 24)
        }
        .frame(maxWidth: 500)
        .frame(maxWidth: .infinity)
        .dinoWarmBackground()
    }
}

#Preview {
    HatchRevealView(dinosaur: DinosaurCatalog.all[0]) {}
}
