import SwiftUI
import SwiftData

struct CollectionView: View {
    private enum SortOption: String, CaseIterable, Identifiable {
        case collectionOrder, name, rarity

        var id: String { rawValue }

        var label: Text {
            switch self {
            case .collectionOrder: Text("Collection Order")
            case .name: Text("Name")
            case .rarity: Text("Rarity")
            }
        }
    }

    @Environment(\.modelContext) private var modelContext
    @Query(sort: \UnlockedDinosaur.unlockedAt) private var unlocked: [UnlockedDinosaur]

    @State private var showSettings = false
    @State private var searchText = ""
    @State private var dietFilter: Dinosaur.Diet?
    @State private var rarityFilter: Dinosaur.Rarity?
    @State private var sortOption: SortOption = .collectionOrder

    private var unlockedIDs: Set<String> {
        Set(unlocked.map(\.dinosaurID))
    }

    private var unlockedAtByID: [String: Date] {
        Dictionary(uniqueKeysWithValues: unlocked.map { ($0.dinosaurID, $0.unlockedAt) })
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

    private var isFiltering: Bool {
        dietFilter != nil || rarityFilter != nil
    }

    /// Search/filter/sort all operate on the full catalog, including locked
    /// (and, if unlocked, secret) entries — which species exist was never
    /// hidden, only their art and facts are (via `DinoSilhouetteView`), so
    /// none of this reveals anything the grid didn't already structurally
    /// show. A locked match still renders as a plain silhouette below.
    private var visibleDinosaurs: [Dinosaur] {
        var list = DinosaurCatalog.all
        if let dietFilter {
            list = list.filter { $0.diet == dietFilter }
        }
        if let rarityFilter {
            list = list.filter { $0.rarity == rarityFilter }
        }
        let trimmedSearch = searchText.trimmingCharacters(in: .whitespacesAndNewlines)
        if !trimmedSearch.isEmpty {
            list = list.filter { $0.localizedName.localizedCaseInsensitiveContains(trimmedSearch) }
        }
        switch sortOption {
        case .collectionOrder:
            // Hatched dinosaurs in the order you actually unlocked them
            // (oldest first); still-locked ones have no unlock date, so
            // they fall in behind every unlocked one — `.distantFuture`
            // as their sort key, tie-broken by catalog position so their
            // relative order among themselves stays stable and predictable
            // rather than depending on `sort`'s unspecified tie behavior.
            let unlockedAtByID = unlockedAtByID
            list = list.enumerated()
                .sorted { lhs, rhs in
                    let lhsDate = unlockedAtByID[lhs.element.id] ?? .distantFuture
                    let rhsDate = unlockedAtByID[rhs.element.id] ?? .distantFuture
                    if lhsDate != rhsDate { return lhsDate < rhsDate }
                    return lhs.offset < rhs.offset
                }
                .map(\.element)
        case .name:
            list.sort {
                if let unlockedFirst = unlockedFirstComparison($0, $1) { return unlockedFirst }
                return $0.localizedName.localizedCaseInsensitiveCompare($1.localizedName) == .orderedAscending
            }
        case .rarity:
            list.sort {
                if let unlockedFirst = unlockedFirstComparison($0, $1) { return unlockedFirst }
                return $0.rarity.starCount < $1.rarity.starCount
            }
        }
        return list
    }

    /// Unlocked dinosaurs always sort before any locked one, regardless of
    /// which sort option is active — otherwise a locked "???" card would
    /// land wherever its hidden real name/rarity happens to fall, breaking
    /// up the run of visible, named cards in a way the user has no way to
    /// make sense of (they can't see what they're being sorted against).
    /// Returns nil when both share the same unlock status, meaning the
    /// caller's own comparator should decide the order between them.
    private func unlockedFirstComparison(_ lhs: Dinosaur, _ rhs: Dinosaur) -> Bool? {
        let lhsUnlocked = unlockedIDs.contains(lhs.id)
        let rhsUnlocked = unlockedIDs.contains(rhs.id)
        guard lhsUnlocked != rhsUnlocked else { return nil }
        return lhsUnlocked
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

                if visibleDinosaurs.isEmpty {
                    ContentUnavailableView {
                        Label("No Dinosaurs Found", systemImage: "questionmark.square.dashed")
                    } description: {
                        Text("Try a different search or filter.")
                    }
                    .padding(.top, 40)
                } else {
                    LazyVGrid(columns: columns, spacing: 16) {
                        ForEach(visibleDinosaurs) { dinosaur in
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
            }
            .navigationTitle("Dino-pedia")
            .navigationBarTitleDisplayMode(.inline)
            .searchable(text: $searchText, prompt: Text("Search dinosaurs"))
            .toolbar {
                ToolbarItem(placement: .topBarLeading) {
                    SupporterBadgeView()
                }

                ToolbarItem(placement: .topBarTrailing) {
                    Menu {
                        Picker(selection: $sortOption) {
                            ForEach(SortOption.allCases) { option in
                                option.label.tag(option)
                            }
                        } label: {
                            Text("Sort By")
                        }

                        Picker(selection: $dietFilter) {
                            Text("All").tag(Dinosaur.Diet?.none)
                            ForEach(Dinosaur.Diet.allCases, id: \.self) { diet in
                                diet.localizedLabel.tag(Dinosaur.Diet?.some(diet))
                            }
                        } label: {
                            Text("Diet")
                        }

                        Picker(selection: $rarityFilter) {
                            Text("All").tag(Dinosaur.Rarity?.none)
                            ForEach(Dinosaur.Rarity.allCases, id: \.self) { rarity in
                                rarity.localizedLabel.tag(Dinosaur.Rarity?.some(rarity))
                            }
                        } label: {
                            Text("Rarity")
                        }

                        if isFiltering {
                            Button(role: .destructive) {
                                dietFilter = nil
                                rarityFilter = nil
                            } label: {
                                Text("Clear Filters")
                            }
                        }
                    } label: {
                        Image(systemName: isFiltering ? "line.3.horizontal.decrease.circle.fill" : "line.3.horizontal.decrease.circle")
                    }
                    .accessibilityLabel(Text("Sort and Filter"))
                }
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
                ParentalGateView()
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
