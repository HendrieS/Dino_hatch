import SwiftUI
import SwiftData

struct CollectionView: View {
    @Environment(\.modelContext) private var modelContext
    @Query(sort: \UnlockedDinosaur.unlockedAt) private var unlocked: [UnlockedDinosaur]

    @State private var showSettings = false

    private var unlockedIDs: Set<String> {
        Set(unlocked.map(\.dinosaurID))
    }

    /// The denominator only ever reflects the regular (non-secret) set, so
    /// it stays "26" forever. The numerator counts everything unlocked —
    /// regular and secret alike — so once a secret dinosaur is found it can
    /// read e.g. "27 / 26", a small "wait, that's more than the total?"
    /// hint without ever spelling out that secret dinosaurs exist.
    private var regularDinosaurs: [Dinosaur] {
        DinosaurCatalog.all.filter { !$0.isSecret }
    }

    private var hasFoundBonusDinosaurs: Bool {
        unlockedIDs.count > regularDinosaurs.count
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
                        .foregroundStyle(hasFoundBonusDinosaurs ? .orange : .secondary)
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
            .toolbar {
                ToolbarItem(placement: .topBarTrailing) {
                    Button {
                        showSettings = true
                    } label: {
                        Image(systemName: "gearshape.fill")
                    }
                }
                #if DEBUG
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
                #endif
            }
            .sheet(isPresented: $showSettings) {
                SettingsView()
            }
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
