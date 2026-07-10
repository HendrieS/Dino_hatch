import SwiftUI

struct DinoCardView: View {
    let dinosaur: Dinosaur

    var body: some View {
        VStack(spacing: 8) {
            DinoImageView(dinosaur: dinosaur, size: 64)
            Text(localizedContent: dinosaur.name)
                .font(.subheadline.bold())
                .multilineTextAlignment(.center)
                .lineLimit(2)
                .foregroundStyle(.primary)
        }
        .frame(maxWidth: .infinity)
        .padding()
        .background(Color.dinoCardBackground)
        .clipShape(RoundedRectangle(cornerRadius: 16))
    }
}

#Preview {
    DinoCardView(dinosaur: DinosaurCatalog.all[0])
        .padding()
}
