import SwiftUI
import UIKit

/// Alternate Home Screen icons — each gated behind an `UnlockRequirement`,
/// so picking one is itself a small collection reward rather than a plain
/// settings toggle. `assetName` must match both the `.appiconset` name in
/// `Assets.xcassets` and an entry in project.yml's
/// `ASSETCATALOG_COMPILER_ALTERNATE_APPICON_NAMES`.
enum AppIconOption: CaseIterable, Identifiable {
    /// `velociraptor` and `spinosaurus` were illustrated by Alexis.
    case trex, triceratops, pteranodon, patagotitan, velociraptor, spinosaurus

    enum UnlockRequirement {
        /// Unlocked once the given catalog dinosaur has been hatched.
        case hatch(dinosaurID: String)
        /// Unlocked once at least this many dinosaurs (any species) have
        /// been hatched in total — not tied to one specific catalog entry.
        case collectionSize(Int)
    }

    var id: String { assetName }

    var assetName: String {
        switch self {
        case .trex: "icon-trex"
        case .triceratops: "icon-triceratops"
        case .pteranodon: "icon-pteranodon"
        case .patagotitan: "icon-patagotitan"
        case .velociraptor: "icon-velociraptor"
        case .spinosaurus: "icon-spinosaurus"
        }
    }

    /// A plain (non-App-Icon-typed) copy of the same artwork, purely for
    /// `AppIconPicker`'s preview thumbnail — `.appiconset` entries aren't
    /// reliably loadable through `Image(_:)`/`UIImage(named:)` across Xcode
    /// versions, so the picker can't just point at `assetName` directly.
    var thumbnailAssetName: String {
        "\(assetName)-thumb"
    }

    var unlockRequirement: UnlockRequirement {
        switch self {
        case .trex: .hatch(dinosaurID: "t-rex")
        case .triceratops: .hatch(dinosaurID: "triceratops")
        case .pteranodon: .hatch(dinosaurID: "pteranodon")
        case .patagotitan: .hatch(dinosaurID: "patagotitan")
        case .velociraptor: .collectionSize(5)
        case .spinosaurus: .collectionSize(10)
        }
    }

    /// For `.hatch`, reuses the matching catalog entry's name rather than
    /// duplicating a fresh localized label (falls back to the raw asset
    /// name in the unreachable-in-practice case the catalog lookup fails).
    /// For `.collectionSize`, describes the icon itself rather than the
    /// unlock condition, since this is only read once already unlocked
    /// (see `AppIconPicker`) — the milestone no longer matters at that point.
    var displayLabel: Text {
        switch unlockRequirement {
        case .hatch(let dinosaurID):
            if let dinosaur = DinosaurCatalog.all.first(where: { $0.id == dinosaurID }) {
                return Text(localizedContent: dinosaur.name)
            }
            return Text(verbatim: assetName)
        case .collectionSize:
            switch self {
            case .velociraptor: return Text("Brown dino icon")
            case .spinosaurus: return Text("Green dino icon")
            default: return Text(verbatim: assetName)
            }
        }
    }

    static func isUnlocked(_ option: AppIconOption, unlockedIDs: Set<String>) -> Bool {
        switch option.unlockRequirement {
        case .hatch(let dinosaurID):
            unlockedIDs.contains(dinosaurID)
        case .collectionSize(let count):
            unlockedIDs.count >= count
        }
    }

    /// The currently active Home Screen icon, or `nil` for the default.
    static var current: AppIconOption? {
        guard let name = UIApplication.shared.alternateIconName else { return nil }
        return AppIconOption.allCases.first { $0.assetName == name }
    }

    /// Switches the Home Screen icon, or restores the default when passed
    /// `nil`. Silently does nothing if the device doesn't support alternate
    /// icons or this option is already active.
    static func apply(_ option: AppIconOption?, completion: @escaping () -> Void = {}) {
        guard UIApplication.shared.supportsAlternateIcons else { return }
        guard UIApplication.shared.alternateIconName != option?.assetName else { return }
        UIApplication.shared.setAlternateIconName(option?.assetName) { _ in
            completion()
        }
    }
}
