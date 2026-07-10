import SwiftUI

struct DinosaurDetailView: View {
    let dinosaur: Dinosaur
    let unlockedAt: Date?

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
                    // Length is a measurement notation (e.g. "12 m (40 ft)"),
                    // not linguistic content, so it's shown as-is in every
                    // language rather than routed through localization.
                    FactRow(icon: "ruler.fill", label: "Length", value: Text(verbatim: dinosaur.length))
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
