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
                .foregroundStyle(.secondary)
        }
        .frame(maxWidth: .infinity)
        .padding()
        .background(Color.black.opacity(0.06))
        .clipShape(RoundedRectangle(cornerRadius: 16))
    }
}

#Preview {
    DinoSilhouetteView()
        .padding()
}
