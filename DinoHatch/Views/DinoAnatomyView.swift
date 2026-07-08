import SwiftUI
import UIKit

/// Interactive "press & hold to x-ray" viewer for a dinosaur, backed by real
/// skin/skeleton image assets. The interaction itself lives in
/// `XRayRevealView`; this type just supplies the two images and decides
/// whether to show them at all.
///
/// Degrades gracefully: if a dinosaur is missing either its skin or its
/// skeleton artwork, this shows the standard `DinoImageView` (emoji
/// placeholder) and the x-ray interaction is disabled — so dinos without art
/// yet keep working exactly as before.
struct DinoAnatomyView: View {
    let dinosaur: Dinosaur
    var size: CGFloat = 300

    /// True only when BOTH the skin and skeleton assets are present in the
    /// asset catalog. Anything less falls back to the emoji placeholder.
    private var hasAnatomy: Bool {
        guard let skin = dinosaur.imageAssetName,
              let skeleton = dinosaur.skeletonAssetName else { return false }
        return UIImage(named: skin) != nil && UIImage(named: skeleton) != nil
    }

    var body: some View {
        if hasAnatomy {
            XRayRevealView(size: size) {
                Image(dinosaur.imageAssetName!)
                    .resizable()
                    .scaledToFit()
            } skeleton: {
                Image(dinosaur.skeletonAssetName!)
                    .resizable()
                    .scaledToFit()
            }
        } else {
            DinoImageView(dinosaur: dinosaur, size: size)
        }
    }
}

#Preview {
    DinoAnatomyView(dinosaur: DinosaurCatalog.all[0], size: 320)
        .padding()
}
