import SwiftUI
import SwiftData

struct CollectionView: View {
    @Environment(\.modelContext) private var modelContext
    @Query(sort: \UnlockedDinosaur.unlockedAt) private var unlocked: [UnlockedDinosaur]

    private var unlockedIDs: Set<String> {
        Set(unlocked.map(\.dinosaurID))
    }

    private let columns = [GridItem(.adaptive(minimum: 140), spacing: 16)]

    var body: some View {
        NavigationStack {
            ScrollView {
                // Composed from separate Text views (rather than one
                // interpolated string) so the numeral formatting doesn't
                // depend on guessing the exact %-format Xcode would have
                // extracted for a hand-authored String Catalog.
                HStack(spacing: 4) {
                    Text(unlockedIDs.count, format: .number)
                    Text(verbatim: "/")
                    Text(DinosaurCatalog.all.count, format: .number)
                    Text("discovered")
                }
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
            #if DEBUG
            .toolbar {
                ToolbarItem(placement: .topBarTrailing) {
                    Menu {
                        Button("Unlock All (Testing)", systemImage: "lock.open.fill") {
                            unlockAll()
                        }
                        Button("Reset Collection (Testing)", systemImage: "trash", role: .destructive) {
                            resetCollection()
                        }
                    } label: {
                        Image(systemName: "ladybug.fill")
                    }
                }
            }
            #endif
        }
    }

    #if DEBUG
    private func unlockAll() {
        for dinosaur in DinosaurCatalog.all where !unlockedIDs.contains(dinosaur.id) {
            modelContext.insert(UnlockedDinosaur(dinosaurID: dinosaur.id))
        }
    }

    private func resetCollection() {
        for record in unlocked {
            modelContext.delete(record)
        }
    }
    #endif
}

#Preview {
    CollectionView()
        .modelContainer(for: [UnlockedDinosaur.self, AppSettings.self], inMemory: true)
}
