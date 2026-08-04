import SwiftUI

struct DinoCardView: View {
    let dinosaur: Dinosaur

    var body: some View {
        VStack(spacing: 8) {
            DinoImageView(dinosaur: dinosaur, size: 64)
            Text(localizedContent: dinosaur.name)
                .font(.subheadline.bold())
                .multilineTextAlignment(.center)
                // Reserves 2 lines of height even for one-line names, so
                // every card in the grid is the same height regardless of
                // which row a long name lands in.
                .lineLimit(2, reservesSpace: true)
                .foregroundStyle(.primary)
        }
        .frame(maxWidth: .infinity)
        .padding()
        .background(Color.dinoCollectionCardBackground)
        .clipShape(RoundedRectangle(cornerRadius: 16))
        .overlay(
            RoundedRectangle(cornerRadius: 16)
                .strokeBorder(dinosaur.rarity.tint, lineWidth: 2)
        )
    }
}

#Preview {
    DinoCardView(dinosaur: DinosaurCatalog.all[0])
        .padding()
}
