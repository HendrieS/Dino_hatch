#if DEBUG
import SwiftUI

/// Debug-only screen to try the press & hold x-ray interaction using vector
/// placeholder art, without needing real skin/skeleton image assets wired
/// up yet. Reached from the Collection tab's debug menu.
struct AnatomyDemoView: View {
    var body: some View {
        VStack(spacing: 24) {
            Text("X-Ray Demo")
                .font(.title2.bold())

            XRayRevealView(size: 280) {
                PlaceholderAnatomyArt.skin()
            } skeleton: {
                PlaceholderAnatomyArt.skeleton()
            }

            Text("Placeholder art only. Once real dinosaur artwork is in Assets.xcassets, set imageAssetName / skeletonAssetName on the catalog entry and this same interaction runs on the real images via DinoAnatomyView.")
                .font(.footnote)
                .foregroundStyle(.secondary)
                .multilineTextAlignment(.center)
                .padding(.horizontal, 32)

            Spacer()
        }
        .padding(.top, 40)
    }
}

#Preview {
    AnatomyDemoView()
}
#endif
