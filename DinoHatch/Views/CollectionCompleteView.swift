import SwiftUI

/// Shown twice over a collection's life (see `CollectionCompleteGate`): once
/// every regular dinosaur is hatched (`.allRegular`, the 27/27 moment —
/// a star instead of the trophy, plus a teaser that secret dinosaurs are
/// still hiding in the eggs), and again once the entire catalog, Secret
/// Rare included, is (`.everything`). `mascots` is expected to
/// be the two most recently hatched dinosaurs (naturally includes whichever
/// one completed the set) rather than a hardcoded pair, so this stays
/// correct as the catalog grows across future waves — see the call site.
struct CollectionCompleteView: View {
    let mascots: [Dinosaur]
    var milestone: CollectionCompleteGate.Milestone = .everything
    var onDismiss: () -> Void

    private var isEverything: Bool { milestone == .everything }

    // Same entrance-pop-plus-haptic treatment as HatchRevealView.hasAppeared
    // — this screen is the bigger of the two celebrations (the whole
    // catalog, not just one dinosaur), so it shouldn't land with less
    // flourish than the per-dinosaur reveal.
    @State private var hasAppeared = false

    var body: some View {
        VStack(spacing: 24) {
            Spacer()

            VStack(spacing: 16) {
                Image(systemName: isEverything ? "trophy.fill" : "star.fill")
                    .font(.system(size: 34))
                    .foregroundStyle(.white)
                    .padding(24)
                    .background(Color.dinoGreen, in: Circle())
                    .scaleEffect(hasAppeared ? 1 : 0.3)
                    .opacity(hasAppeared ? 1 : 0)

                (isEverything ? Text("Collection Complete!") : Text("You Found Every Dinosaur!"))
                    .font(.title2.bold())
                    .multilineTextAlignment(.center)
                    .opacity(hasAppeared ? 1 : 0)

                (isEverything
                    ? Text("You've hatched every dinosaur in the collection. Amazing work, paleontologist!")
                    : Text("Amazing work, paleontologist! But some say secret dinosaurs are still hiding in the eggs..."))
                    .font(.subheadline)
                    .foregroundStyle(.secondary)
                    .multilineTextAlignment(.center)
                    .fixedSize(horizontal: false, vertical: true)
                    .padding(.horizontal, 8)
                    .opacity(hasAppeared ? 1 : 0)

                HStack(alignment: .bottom, spacing: 4) {
                    ForEach(mascots) { dinosaur in
                        DinoImageView(dinosaur: dinosaur, size: 88)
                    }
                }
                .padding(.top, 4)
                .opacity(hasAppeared ? 1 : 0)

                ZStack {
                    (isEverything ? Text("More dinosaurs are on their way...") : Text("Keep hatching to find them!"))
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
                .opacity(hasAppeared ? 1 : 0)
            }
            .padding(20)
            .background(.white.opacity(0.55), in: RoundedRectangle(cornerRadius: 20))
            .overlay(RoundedRectangle(cornerRadius: 20).stroke(Color.dinoDialTrack, lineWidth: 1.5))
            .padding(.horizontal, 24)

            Spacer()
            Spacer()

            Button("Awesome!", action: onDismiss)
                .buttonStyle(.dinoChunkyGreen)
                // Wider than 32pt — this sits right at the bottom over the
                // fern corners, so it needs extra clearance to land between
                // them instead of over them. 32 -> 56 -> 80 -> 100 all still
                // overlapped them, confirmed on device each time.
                .padding(.horizontal, 140)
                .padding(.bottom, 12)
        }
        .frame(maxWidth: 500)
        .frame(maxWidth: .infinity, maxHeight: .infinity)
        .dinoWarmBackground()
        .onAppear {
            withAnimation(.spring(response: 0.55, dampingFraction: 0.65)) {
                hasAppeared = true
            }
        }
        .sensoryFeedback(.success, trigger: hasAppeared) { _, newValue in newValue }
    }
}

#Preview("Everything") {
    CollectionCompleteView(mascots: [DinosaurCatalog.all[0], DinosaurCatalog.all[1]]) {}
}

#Preview("All regular") {
    CollectionCompleteView(mascots: [DinosaurCatalog.all[0], DinosaurCatalog.all[1]], milestone: .allRegular) {}
}
