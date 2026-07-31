import SwiftUI
import UIKit

/// Alternate Home Screen icons, one per dinosaur — gated behind having
/// hatched that dinosaur first, so picking an icon is itself a small
/// collection reward rather than a plain settings toggle. `assetName`
/// must match both the `.appiconset` name in `Assets.xcassets` and an
/// entry in project.yml's `ASSETCATALOG_COMPILER_ALTERNATE_APPICON_NAMES`.
enum AppIconOption: CaseIterable, Identifiable {
    /// `velociraptor` and `spinosaurus` were illustrated by Alexis.
    case trex, triceratops, pteranodon, patagotitan, velociraptor, spinosaurus

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

    /// The catalog entry this icon is unlocked by and named after.
    var dinosaurID: String {
        switch self {
        case .trex: "t-rex"
        case .triceratops: "triceratops"
        case .pteranodon: "pteranodon"
        case .patagotitan: "patagotitan"
        case .velociraptor: "velociraptor"
        case .spinosaurus: "spinosaurus"
        }
    }

    /// Reuses the matching catalog entry's name rather than duplicating a
    /// fresh localized label — falls back to the raw asset name in the
    /// (unreachable in practice) case the catalog lookup fails.
    var displayLabel: Text {
        if let dinosaur = DinosaurCatalog.all.first(where: { $0.id == dinosaurID }) {
            Text(localizedContent: dinosaur.name)
        } else {
            Text(verbatim: assetName)
        }
    }

    static func isUnlocked(_ option: AppIconOption, unlockedIDs: Set<String>) -> Bool {
        unlockedIDs.contains(option.dinosaurID)
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
