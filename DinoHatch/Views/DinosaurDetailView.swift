import SwiftUI
import UIKit

struct DinosaurDetailView: View {
    let dinosaur: Dinosaur
    let unlockedAt: Date?

    @State private var shareURL: URL?
    @State private var shareImage: UIImage?

    var body: some View {
        ScrollView {
            VStack(spacing: 20) {
                // Was: DinoImageView(dinosaur: dinosaur, size: 160)
                // Now the interactive press & hold x-ray viewer. It falls
                // back to the emoji placeholder automatically for dinosaurs
                // that don't have skin + skeleton art yet.
                DinoAnatomyView(dinosaur: dinosaur, size: 300)

                Text(localizedContent: dinosaur.name)
                    .font(.system(size: 30, weight: .bold, design: .rounded))

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
        }
        .navigationTitle(Text(localizedContent: dinosaur.name))
        .navigationBarTitleDisplayMode(.inline)
        .toolbar {
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
}
