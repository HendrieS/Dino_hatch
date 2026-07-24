import SwiftUI

/// Offscreen layout rendered to an image for sharing a hatched dinosaur —
/// see `DinosaurDetailView`'s share button. Deliberately self-contained
/// (fixed white background, no `Color.dinoCardBackground`/dark-mode
/// awareness) since it's exported as a flat PNG that needs to look right
/// wherever it lands, not just inside the app.
struct DinoShareCard: View {
    let dinosaur: Dinosaur

    var body: some View {
        ZStack(alignment: .topTrailing) {
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

            rarityBadge
                .padding(16)
        }
    }

    /// Star-rank pill in the corner, the way a trading card marks its
    /// rarity — fixed sizing like the rest of this card, since it's baked
    /// into an exported image rather than shown live in the app.
    private var rarityBadge: some View {
        HStack(spacing: 3) {
            ForEach(0..<dinosaur.rarity.starCount, id: \.self) { _ in
                Image(systemName: "star.fill")
                    .font(.system(size: 10))
            }
            dinosaur.rarity.localizedLabel
                .font(.system(size: 12, weight: .bold, design: .rounded))
        }
        .foregroundStyle(.white)
        .padding(.horizontal, 10)
        .padding(.vertical, 6)
        .background(dinosaur.rarity.tint, in: Capsule())
    }
}

#Preview {
    DinoShareCard(dinosaur: DinosaurCatalog.all[0])
}
