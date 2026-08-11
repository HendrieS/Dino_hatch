import SwiftUI

/// Shown once the entire catalog (regular + Secret Rare) has been hatched —
/// see `RootTabView`'s trigger check against
/// `AppSettings.lastCollectionCompleteCatalogSize`. `mascots` is expected to
/// be the two most recently hatched dinosaurs (naturally includes whichever
/// one completed the set) rather than a hardcoded pair, so this stays
/// correct as the catalog grows across future waves — see the call site.
struct CollectionCompleteView: View {
    let mascots: [Dinosaur]
    var onDismiss: () -> Void

    var body: some View {
        VStack(spacing: 24) {
            Spacer()

            VStack(spacing: 16) {
                Image(systemName: "trophy.fill")
                    .font(.system(size: 34))
                    .foregroundStyle(.white)
                    .padding(24)
                    .background(Color.dinoGreen, in: Circle())

                Text("Collection Complete!")
                    .font(.title2.bold())

                Text("You've hatched every dinosaur in the collection. Amazing work, paleontologist!")
                    .font(.subheadline)
                    .foregroundStyle(.secondary)
                    .multilineTextAlignment(.center)
                    .fixedSize(horizontal: false, vertical: true)
                    .padding(.horizontal, 8)

                HStack(alignment: .bottom, spacing: 4) {
                    ForEach(mascots) { dinosaur in
                        DinoImageView(dinosaur: dinosaur, size: 88)
                    }
                }
                .padding(.top, 4)

                ZStack {
                    Text("More dinosaurs are on their way...")
                        .font(.footnote.bold())
                        .foregroundStyle(Color.dinoGreen)
                        .multilineTextAlignment(.center)
                        .fixedSize(horizontal: false, vertical: true)
                        .padding(.horizontal, 12)
                        .padding(.top, 20)
                        .padding(.bottom, 10)
                        .frame(maxWidth: .infinity)
                        .background(Color.dinoGreen.opacity(0.12), in: RoundedRectangle(cornerRadius: 12))

                    Image("egg-hatch-1")
                        .resizable()
                        .scaledToFit()
                        .frame(width: 30, height: 30)
                        .offset(y: -14)
                }
            }
            .padding(20)
            .background(.white.opacity(0.55), in: RoundedRectangle(cornerRadius: 20))
            .overlay(RoundedRectangle(cornerRadius: 20).stroke(Color.dinoDialTrack, lineWidth: 1.5))
            .padding(.horizontal, 24)

            Spacer()
            Spacer()

            Button("Awesome!", action: onDismiss)
                .buttonStyle(.dinoChunkyGreen)
                .padding(.horizontal, 32)
                .padding(.bottom, 12)
        }
        .frame(maxWidth: 500)
        .frame(maxWidth: .infinity, maxHeight: .infinity)
        .dinoWarmBackground()
    }
}

#Preview {
    CollectionCompleteView(mascots: [DinosaurCatalog.all[0], DinosaurCatalog.all[1]]) {}
}
