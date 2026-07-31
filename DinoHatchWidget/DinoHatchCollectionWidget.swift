import WidgetKit
import SwiftUI

struct CollectionEntry: TimelineEntry {
    let date: Date
    let snapshot: WidgetSnapshot
}

/// Single-entry timeline, refreshed on demand rather than on a schedule —
/// `RootTabView` calls `WidgetCenter.reloadTimelines` whenever the unlocked
/// collection changes, so there's nothing this provider needs to poll for.
struct CollectionProvider: TimelineProvider {
    func placeholder(in context: Context) -> CollectionEntry {
        CollectionEntry(
            date: .now,
            snapshot: WidgetSnapshot(
                unlockedCount: 4, totalCount: 26,
                lastDinosaurEmoji: "🦖", lastDinosaurImageAssetName: "trex-skin", lastDinosaurName: "Tyrannosaurus Rex"
            )
        )
    }

    func getSnapshot(in context: Context, completion: @escaping (CollectionEntry) -> Void) {
        completion(CollectionEntry(date: .now, snapshot: WidgetSnapshotStore.load() ?? .empty))
    }

    func getTimeline(in context: Context, completion: @escaping (Timeline<CollectionEntry>) -> Void) {
        let entry = CollectionEntry(date: .now, snapshot: WidgetSnapshotStore.load() ?? .empty)
        completion(Timeline(entries: [entry], policy: .never))
    }
}

struct DinoHatchCollectionWidgetView: View {
    var entry: CollectionProvider.Entry
    @Environment(\.widgetFamily) private var family

    private var snapshot: WidgetSnapshot { entry.snapshot }

    var body: some View {
        Group {
            switch family {
            case .systemMedium:
                mediumView
            default:
                smallView
            }
        }
        .containerBackground(for: .widget) {
            LinearGradient(
                colors: [Color(red: 0.93, green: 0.96, blue: 1.00), Color(red: 0.89, green: 0.94, blue: 0.84)],
                startPoint: .top, endPoint: .bottom
            )
        }
    }

    private var smallView: some View {
        VStack(alignment: .leading, spacing: 6) {
            Image("egg-hatch-1")
                .resizable()
                .scaledToFit()
                .frame(width: 32, height: 32)
            Spacer(minLength: 4)
            progressLine(numberSize: 30, secondarySize: 16)
            Text("discovered")
                .font(.caption)
                .foregroundStyle(.secondary)
        }
        .frame(maxWidth: .infinity, alignment: .leading)
    }

    private var mediumView: some View {
        HStack(spacing: 16) {
            DinoWidgetImage(assetName: snapshot.lastDinosaurImageAssetName, emoji: snapshot.lastDinosaurEmoji, size: 60)

            VStack(alignment: .leading, spacing: 4) {
                if let name = snapshot.lastDinosaurName {
                    Text("Newest hatch")
                        .font(.caption)
                        .foregroundStyle(.secondary)
                    Text(verbatim: name)
                        .font(.system(size: 18, weight: .bold, design: .rounded))
                        .lineLimit(1)
                } else {
                    Text("No dinosaurs yet")
                        .font(.system(size: 16, weight: .bold, design: .rounded))
                }
                Spacer(minLength: 4)
                HStack(spacing: 4) {
                    progressLine(numberSize: 20, secondarySize: 14)
                    Text("discovered")
                        .font(.caption)
                        .foregroundStyle(.secondary)
                }
            }
            Spacer(minLength: 0)
        }
        .frame(maxWidth: .infinity, alignment: .leading)
    }

    private func progressLine(numberSize: CGFloat, secondarySize: CGFloat) -> some View {
        HStack(alignment: .firstTextBaseline, spacing: 2) {
            Text(snapshot.unlockedCount, format: .number)
                .font(.system(size: numberSize, weight: .bold, design: .rounded))
            Text(verbatim: "/")
                .font(.system(size: secondarySize, weight: .semibold, design: .rounded))
                .foregroundStyle(.secondary)
            Text(snapshot.totalCount, format: .number)
                .font(.system(size: secondarySize, weight: .semibold, design: .rounded))
                .foregroundStyle(.secondary)
        }
    }
}

struct DinoHatchCollectionWidget: Widget {
    var body: some WidgetConfiguration {
        StaticConfiguration(kind: WidgetSnapshotStore.widgetKind, provider: CollectionProvider()) { entry in
            DinoHatchCollectionWidgetView(entry: entry)
        }
        .configurationDisplayName("Dino Collection")
        .description("See how many dinosaurs you've hatched.")
        .supportedFamilies([.systemSmall, .systemMedium])
    }
}

#Preview(as: .systemSmall) {
    DinoHatchCollectionWidget()
} timeline: {
    CollectionEntry(
        date: .now,
        snapshot: WidgetSnapshot(
            unlockedCount: 7, totalCount: 26,
            lastDinosaurEmoji: "🦕", lastDinosaurImageAssetName: "brachiosaurus-skin", lastDinosaurName: "Brachiosaurus"
        )
    )
}

#Preview(as: .systemMedium) {
    DinoHatchCollectionWidget()
} timeline: {
    CollectionEntry(
        date: .now,
        snapshot: WidgetSnapshot(
            unlockedCount: 7, totalCount: 26,
            lastDinosaurEmoji: "🦕", lastDinosaurImageAssetName: "brachiosaurus-skin", lastDinosaurName: "Brachiosaurus"
        )
    )
}
