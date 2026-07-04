import SwiftUI
import UIKit

/// Renders a dinosaur's visual. Checks `imageAssetName` first so real
/// artwork can be dropped into the asset catalog later without touching
/// any call site; falls back to the placeholder emoji today.
struct DinoImageView: View {
    let dinosaur: Dinosaur
    var size: CGFloat = 80

    var body: some View {
        Group {
            if let imageAssetName = dinosaur.imageAssetName, UIImage(named: imageAssetName) != nil {
                Image(imageAssetName)
                    .resizable()
                    .scaledToFit()
            } else {
                Text(dinosaur.emoji)
                    .font(.system(size: size * 0.85))
            }
        }
        .frame(width: size, height: size)
    }
}

#Preview {
    DinoImageView(dinosaur: DinosaurCatalog.all[0], size: 160)
}
