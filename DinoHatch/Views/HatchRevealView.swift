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

            Text(dinosaur.name)
                .font(.system(size: 34, weight: .bold, design: .rounded))

            Text(dinosaur.funFact)
                .font(.body)
                .multilineTextAlignment(.center)
                .padding(.horizontal, 32)
                .foregroundStyle(.secondary)

            Spacer()

            Button(action: onDismiss) {
                Text("Awesome!")
                    .font(.title3.bold())
                    .frame(maxWidth: .infinity)
                    .padding()
                    .background(Color.dinoGreen)
                    .foregroundStyle(.white)
                    .clipShape(RoundedRectangle(cornerRadius: 20))
            }
            .padding(.horizontal, 32)
            .padding(.bottom, 24)
        }
    }
}

#Preview {
    HatchRevealView(dinosaur: DinosaurCatalog.all[0]) {}
}
