import SwiftUI
import SwiftData
import UIKit

struct DinosaurDetailView: View {
    let dinosaur: Dinosaur
    let unlockedAt: Date?

    @Query private var unlockedRecords: [UnlockedDinosaur]
    @State private var shareURL: URL?
    @State private var shareImage: UIImage?

    /// Looked up by `dinosaur.id` rather than passed in directly (like
    /// `unlockedAt` is) so toggling favorite here updates live — a plain
    /// `Date?` can't do that, but a `@Query`'d SwiftData reference type can.
    private var unlockedRecord: UnlockedDinosaur? {
        unlockedRecords.first(where: { $0.dinosaurID == dinosaur.id })
    }

    var body: some View {
        // Plain ScrollView — FitScrollView was tried here first (matching
        // Timer/Alarm/Collection) but its "disable scroll once content
        // fits" measurement didn't reliably enable scrolling on this
        // screen specifically, confirmed on device (the "Found in" card
        // stayed behind the ferns, unreachable). This is also the only one
        // of these screens that's a *pushed* NavigationStack destination
        // rather than the root of its own stack, which may be why its
        // GeometryReader-based measurement behaved differently. Always
        // scrollable is simple and guaranteed correct, at the minor cost
        // of allowing scroll/bounce even when content already fits.
        ScrollView {
            VStack(spacing: 20) {
                // Was: DinoImageView(dinosaur: dinosaur, size: 160)
                // Now the interactive press & hold x-ray viewer. Falls back
                // to the plain (still illustrated, not emoji, for every
                // current catalog dinosaur) DinoImageView automatically
                // once x-ray isn't unlocked yet (see XRayEligibility) or,
                // hypothetically, for a dinosaur without skin + skeleton
                // art.
                DinoAnatomyView(dinosaur: dinosaur, size: 300)

                Text(localizedContent: dinosaur.name)
                    .font(.largeTitle.bold())
                    .fontDesign(.rounded)
                    .multilineTextAlignment(.center)

                VStack(spacing: 12) {
                    FactRow(icon: "clock.fill", label: "Era", value: Text(localizedContent: dinosaur.era))
                    FactRow(icon: dinosaur.diet.symbolName, label: "Diet", value: dinosaur.diet.localizedLabel)
                    // Length/weight are measurement notations (e.g. "12 m
                    // (40 ft)"), not linguistic content, so they're shown
                    // as-is in every language rather than routed through
                    // localization.
                    FactRow(icon: "ruler.fill", label: "Length", value: Text(verbatim: dinosaur.length))
                    if let weight = dinosaur.weight {
                        FactRow(icon: "scalemass.fill", label: "Weight", value: Text(verbatim: weight))
                    }
                }
                .padding()
                .background(Color.dinoCardBackground)
                .clipShape(RoundedRectangle(cornerRadius: 16))

                VStack(alignment: .leading, spacing: 8) {
                    Label("Fun Fact", systemImage: "sparkles")
                        .font(.headline)
                    Text(localizedContent: dinosaur.funFact)
                        .font(.body)
                }
                .frame(maxWidth: .infinity, alignment: .leading)
                .padding()
                .background(Color.yellow.opacity(0.15))
                .clipShape(RoundedRectangle(cornerRadius: 16))

                if let rangeMapAssetName = dinosaur.rangeMapAssetName {
                    VStack(alignment: .leading, spacing: 9) {
                        Label("Found in", systemImage: "map.fill")
                            .font(.headline)
                        Image(rangeMapAssetName)
                            .resizable()
                            .aspectRatio(568.0 / 248.0, contentMode: .fit)
                            .clipShape(RoundedRectangle(cornerRadius: 12))
                        if let rangeLabel = dinosaur.rangeLabel {
                            Text(localizedContent: rangeLabel)
                                .font(.footnote)
                                .foregroundStyle(.secondary)
                                .frame(maxWidth: .infinity, alignment: .center)
                        }
                    }
                    .frame(maxWidth: .infinity, alignment: .leading)
                    .padding()
                    .background(Color.dinoCardBackground)
                    .clipShape(RoundedRectangle(cornerRadius: 16))
                }

                if let unlockedAt {
                    HStack(spacing: 4) {
                        Text("Hatched on")
                        Text(unlockedAt, style: .date)
                    }
                    .font(.footnote)
                    .foregroundStyle(.secondary)
                }
            }
            .padding()
            // Clearance so the top of the anatomy image and the bottom
            // "Found in" card have somewhere to scroll clear to. The real
            // fix for the vine canopy/fern corners actually covering
            // content is the fade mask below — plain padding alone (tried
            // first, up to 220pt at the bottom) either wasn't enough or
            // left the content just sitting fully opaque right up until it
            // was abruptly covered, same problem CollectionView's grid had
            // before it got a fade too.
            .padding(.top, 60)
            .padding(.bottom, 90)
            .frame(maxWidth: 500)
            .frame(maxWidth: .infinity)
        }
        // Same reasoning and asymmetric shape as CollectionView's mask:
        // the vine canopy (top) and fern corners (bottom) render in front
        // of this screen's content (via .dinoWarmBackground() below), so
        // content needs to fade to full transparency before it'd actually
        // be covered by that art rather than staying opaque right up
        // until it's abruptly clipped. The bottom needs more room than
        // the top since the fern art (plus, on Collection, the paw
        // button — not shown on this pushed screen, but the fern art
        // itself is the same size) reaches further up than the vine
        // canopy does down.
        //
        // Applied here, directly to the ScrollView, and *before*
        // `.dinoWarmBackground()` below — same ordering as CollectionView
        // (mask on the ScrollView, background/fern-overlay on the view
        // that wraps it). A mask affects only what's already composed
        // into the view it's attached to, not content layered on
        // afterward, so getting this order backwards would fade the fern
        // art itself out along with the content instead of leaving it
        // fully opaque on top.
        .mask(
            GeometryReader { proxy in
                // See CollectionView's matching mask for why every fade
                // fraction here is clamped to 0.5 — same transient-height
                // reasoning, and the same ordering guarantee holds since
                // each pair (topFadeEnd < topFadeStart,
                // bottomFadeEnd < bottomFadeStart) keeps that order through
                // the clamp, and topFadeStart + bottomFadeStart never
                // exceeds 1 even when both clamp to 0.5.
                let height = max(proxy.size.height, 1)
                let topFadeStart = min(130 / height, 0.5)
                let topFadeEnd = min(70 / height, 0.5)
                let bottomFadeStart = min(170 / height, 0.5)
                let bottomFadeEnd = min(90 / height, 0.5)
                LinearGradient(
                    stops: [
                        .init(color: .clear, location: 0),
                        .init(color: .clear, location: topFadeEnd),
                        .init(color: .black, location: topFadeStart),
                        .init(color: .black, location: 1 - bottomFadeStart),
                        .init(color: .clear, location: 1 - bottomFadeEnd),
                        .init(color: .clear, location: 1)
                    ],
                    startPoint: .top,
                    endPoint: .bottom
                )
            }
        )
        .navigationTitle(Text(localizedContent: dinosaur.name))
        .navigationBarTitleDisplayMode(.inline)
        .dinoWarmBackground()
        .toolbar {
            ToolbarItem(placement: .topBarTrailing) {
                if let unlockedRecord {
                    Button {
                        unlockedRecord.isFavorite.toggle()
                    } label: {
                        Image(systemName: unlockedRecord.isFavorite ? "heart.fill" : "heart")
                            .foregroundStyle(unlockedRecord.isFavorite ? Color.dinoRed : Color.primary)
                            // Morphs the outline into the filled heart and
                            // bounces it on every toggle, rather than the
                            // icon just snapping between the two SF Symbols.
                            .contentTransition(.symbolEffect(.replace))
                            .symbolEffect(.bounce, value: unlockedRecord.isFavorite)
                    }
                    .sensoryFeedback(.selection, trigger: unlockedRecord.isFavorite)
                    .accessibilityLabel(unlockedRecord.isFavorite ? Text("Remove from Favorites") : Text("Add to Favorites"))
                }
            }
            ToolbarItem(placement: .topBarTrailing) {
                if let shareURL, let shareImage {
                    ShareLink(
                        item: shareURL,
                        preview: SharePreview(
                            Text(localizedContent: dinosaur.name),
                            image: Image(uiImage: shareImage)
                        )
                    ) {
                        Image(systemName: "square.and.arrow.up")
                    }
                }
            }
        }
        .task {
            renderShareImage()
        }
    }

    /// Renders `DinoShareCard` offscreen to a PNG on disk once, so the
    /// share button can present it via `ShareLink` — a file URL shares
    /// cleanly to Messages/Mail/Photos/AirDrop without any extra plumbing.
    @MainActor
    private func renderShareImage() {
        let renderer = ImageRenderer(content: DinoShareCard(dinosaur: dinosaur))
        renderer.scale = 3
        guard let uiImage = renderer.uiImage, let data = uiImage.pngData() else { return }

        let url = FileManager.default.temporaryDirectory.appendingPathComponent("\(dinosaur.id)-dino-hatch-share.png")
        guard (try? data.write(to: url)) != nil else { return }

        shareImage = uiImage
        shareURL = url
    }
}

private struct FactRow: View {
    let icon: String
    let label: LocalizedStringKey
    let value: Text

    var body: some View {
        HStack {
            Label(label, systemImage: icon)
                .font(.subheadline.bold())
            Spacer()
            value
                .font(.subheadline)
                .foregroundStyle(.secondary)
        }
    }
}

#Preview {
    NavigationStack {
        DinosaurDetailView(dinosaur: DinosaurCatalog.all[0], unlockedAt: .now)
    }
    .modelContainer(for: [UnlockedDinosaur.self], inMemory: true)
}
