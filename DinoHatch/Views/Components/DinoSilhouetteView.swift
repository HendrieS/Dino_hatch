import SwiftUI

struct DinoSilhouetteView: View {
    var body: some View {
        VStack(spacing: 8) {
            Image(systemName: "questionmark")
                .font(.system(size: 32, weight: .bold))
                .foregroundStyle(.secondary)
                .frame(width: 64, height: 64)

            Text("???")
                .font(.subheadline.bold())
                // Matches DinoCardView's reserved 2-line name height, so
                // locked and unlocked cards stay the same size in the grid.
                .lineLimit(2, reservesSpace: true)
                .foregroundStyle(.secondary)
        }
        .frame(maxWidth: .infinity)
        .padding()
        .background(Color.dinoCollectionCardBackground)
        .clipShape(RoundedRectangle(cornerRadius: 16))
    }
}

#Preview {
    DinoSilhouetteView()
        .padding()
}
