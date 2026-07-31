import SwiftUI
import UIKit

/// Shows a dinosaur's real skin illustration when a widget-sized variant of
/// `assetName` resolves to a bundled image, falling back to its emoji
/// otherwise — mirrors `DinoImageView`'s graceful-degradation pattern in the
/// main app, in case a future dinosaur ships without art yet.
///
/// Looks up `"\(assetName)-widget"` rather than `assetName` itself: widgets
/// and especially Live Activities have a tight memory budget, and the main
/// app's skin art is 1024×1024 (~4MB once decoded) — loading that directly
/// rendered as a grey placeholder block instead of content on the Lock
/// Screen. The `-widget` variants are pre-downscaled to 240×240 (plenty for
/// the largest size these render at) specifically to stay well under that
/// budget. `Assets.xcassets` is shared into this target via `project.yml`.
struct DinoWidgetImage: View {
    let assetName: String?
    let emoji: String?
    var size: CGFloat

    private var widgetAssetName: String? {
        assetName.map { "\($0)-widget" }
    }

    var body: some View {
        if let widgetAssetName, UIImage(named: widgetAssetName) != nil {
            Image(widgetAssetName)
                .resizable()
                .scaledToFit()
                .frame(width: size, height: size)
        } else {
            Text(verbatim: emoji ?? "🥚")
                .font(.system(size: size * 0.85))
        }
    }
}
