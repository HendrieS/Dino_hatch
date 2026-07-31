import SwiftUI
import UIKit

/// Shows a dinosaur's real skin illustration when `assetName` resolves to a
/// bundled image, falling back to its emoji otherwise — mirrors
/// `DinoImageView`'s graceful-degradation pattern in the main app, in case a
/// future dinosaur ships without art yet. `Assets.xcassets` is shared into
/// this target via `project.yml` specifically so this can work.
struct DinoWidgetImage: View {
    let assetName: String?
    let emoji: String?
    var size: CGFloat

    var body: some View {
        if let assetName, UIImage(named: assetName) != nil {
            Image(assetName)
                .resizable()
                .scaledToFit()
                .frame(width: size, height: size)
        } else {
            Text(verbatim: emoji ?? "🥚")
                .font(.system(size: size * 0.85))
        }
    }
}
