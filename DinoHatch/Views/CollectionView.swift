import SwiftUI
import SwiftData

struct CollectionView: View {
    @Environment(\.modelContext) private var modelContext
    @Query(sort: \UnlockedDinosaur.unlockedAt) private var unlocked: [UnlockedDinosaur]

    private var unlockedIDs: Set<String> {
        Set(unlocked.map(\.dinosaurID))
    }

    /// Counter only ever reflects the regular (non-secret) set, so it caps
    /// at "26/26" and stays there even once secret dinosaurs start being
    /// found — nothing about the counter hints that more exist.
    private var regularDinosaurs: [Dinosaur] {
        DinosaurCatalog.all.filter { !$0.isSecret }
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
                    Text(unlockedIDs.intersection(regularDinosaurs.map(\.id)).count, format: .number)
                    Text(verbatim: "/")
                    Text(regularDinosaurs.count, format: .number)
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
                        } else if !dinosaur.isSecret {
                            DinoSilhouetteView()
                        }
                        // Locked secret dinosaurs render nothing at all —
                        // no silhouette, no placeholder, no hint they exist.
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
