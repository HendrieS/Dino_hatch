import SwiftUI

struct DinosaurDetailView: View {
    let dinosaur: Dinosaur
    let unlockedAt: Date?

    var body: some View {
        ScrollView {
            VStack(spacing: 20) {
                DinoImageView(dinosaur: dinosaur, size: 160)

                Text(dinosaur.name)
                    .font(.system(size: 30, weight: .bold, design: .rounded))

                VStack(spacing: 12) {
                    FactRow(icon: "clock.fill", label: "Era", value: dinosaur.era)
                    FactRow(icon: dinosaur.diet.symbolName, label: "Diet", value: dinosaur.diet.label)
                    FactRow(icon: "ruler.fill", label: "Length", value: dinosaur.length)
                }
                .padding()
                .background(Color.dinoCardBackground)
                .clipShape(RoundedRectangle(cornerRadius: 16))

                VStack(alignment: .leading, spacing: 8) {
                    Label("Fun Fact", systemImage: "sparkles")
                        .font(.headline)
                    Text(dinosaur.funFact)
                        .font(.body)
                }
                .frame(maxWidth: .infinity, alignment: .leading)
                .padding()
                .background(Color.yellow.opacity(0.15))
                .clipShape(RoundedRectangle(cornerRadius: 16))

                if let unlockedAt {
                    Text("Hatched on \(unlockedAt.formatted(date: .abbreviated, time: .omitted))")
                        .font(.footnote)
                        .foregroundStyle(.secondary)
                }
            }
            .padding()
        }
        .navigationTitle(dinosaur.name)
        .navigationBarTitleDisplayMode(.inline)
    }
}

private struct FactRow: View {
    let icon: String
    let label: String
    let value: String

    var body: some View {
        HStack {
            Label(label, systemImage: icon)
                .font(.subheadline.bold())
            Spacer()
            Text(value)
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
