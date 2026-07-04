import SwiftUI
import SwiftData

struct CollectionView: View {
    @Query(sort: \UnlockedDinosaur.unlockedAt) private var unlocked: [UnlockedDinosaur]

    private var unlockedIDs: Set<String> {
        Set(unlocked.map(\.dinosaurID))
    }

    private let columns = [GridItem(.adaptive(minimum: 140), spacing: 16)]

    var body: some View {
        NavigationStack {
            ScrollView {
                Text("\(unlockedIDs.count) / \(DinosaurCatalog.all.count) discovered")
                    .font(.headline)
                    .foregroundStyle(.secondary)
                    .padding(.top, 8)

                LazyVGrid(columns: columns, spacing: 16) {
                    ForEach(DinosaurCatalog.all) { dinosaur in
                        if unlockedIDs.contains(dinosaur.id) {
                            NavigationLink {
                                DinosaurDetailView(
                                    dinosaur: dinosaur,
                                    unlockedAt: unlocked.first(where: { $0.dinosaurID == dinosaur.id })?.unlockedAt
                                )
                            } label: {
                                DinoCardView(dinosaur: dinosaur)
                            }
                            .buttonStyle(.plain)
                        } else {
                            DinoSilhouetteView()
                        }
                    }
                }
                .padding()
            }
            .navigationTitle("Dino-pedia")
        }
    }
}

#Preview {
    CollectionView()
        .modelContainer(for: [UnlockedDinosaur.self, AppSettings.self], inMemory: true)
}
