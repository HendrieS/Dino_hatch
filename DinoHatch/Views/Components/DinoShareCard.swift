import SwiftUI

/// Offscreen layout rendered to an image for sharing a hatched dinosaur —
/// see `DinosaurDetailView`'s share button. Deliberately self-contained
/// (fixed white background, no `Color.dinoCardBackground`/dark-mode
/// awareness) since it's exported as a flat PNG that needs to look right
/// wherever it lands, not just inside the app.
struct DinoShareCard: View {
    let dinosaur: Dinosaur

    var body: some View {
        VStack(spacing: 18) {
            DinoImageView(dinosaur: dinosaur, size: 220)

            Text(localizedContent: dinosaur.name)
                .font(.system(size: 30, weight: .bold, design: .rounded))
                .foregroundStyle(.black)
                .multilineTextAlignment(.center)

            Text(localizedContent: dinosaur.funFact)
                .font(.body)
                .foregroundStyle(.black.opacity(0.75))
                .multilineTextAlignment(.center)
                .padding(.horizontal, 8)

            HStack(spacing: 6) {
                Text("🦕")
                Text(verbatim: "Dino Hatch")
                    .font(.footnote.bold())
                    .foregroundStyle(Color.dinoGreen)
            }
            .padding(.top, 6)
        }
        .padding(28)
        .frame(width: 360)
        .background(Color.white)
    }
}

#Preview {
    DinoShareCard(dinosaur: DinosaurCatalog.all[0])
}
