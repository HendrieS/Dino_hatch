import SwiftUI
import UIKit

/// Renders a dinosaur's visual. Checks `imageAssetName` first — every
/// catalog dinosaur has real illustrated art today, so this is what
/// actually renders in practice — falling back to the emoji only for a
/// hypothetical future catalog entry that ships before its art does.
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
