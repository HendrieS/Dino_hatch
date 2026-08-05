import SwiftUI

/// Replaces the plain-text nav title on the main screens with the
/// illustrated wooden sign art, the title "carved" into it via a light/dark
/// shadow pair. Approved via a preview mockup before implementation.
///
/// Placed as regular body content rather than a `.principal` toolbar item —
/// at this visual size it's much taller than a standard inline nav bar
/// allows, and the approved mockup shows it hanging below the top vine
/// canopy as part of the scrollable content, not squeezed into the nav bar
/// itself. Screens using this drop `.navigationTitle(...)` entirely and
/// rely on this view's own accessibility label/heading trait instead, so
/// VoiceOver still announces the screen name.
struct SignTitleView: View {
    let text: LocalizedStringKey

    /// Matches the source art's own aspect ratio (871x648 after cropping to
    /// its content bounding box) so the sign never looks stretched.
    private static let aspectRatio: CGFloat = 648.0 / 871.0

    var body: some View {
        Text(text)
            .font(.system(size: 20, weight: .bold, design: .rounded))
            .foregroundStyle(Color(red: 0.24, green: 0.16, blue: 0.07))
            // A crude "carved into wood" look — a light shadow below and a
            // dark shadow above, both with zero blur radius so they read as
            // a hard-edged emboss rather than a soft drop shadow.
            .shadow(color: .white.opacity(0.3), radius: 0, x: 0, y: 1)
            .shadow(color: .black.opacity(0.35), radius: 0, x: 0, y: -1)
            .multilineTextAlignment(.center)
            .padding(.horizontal, 26)
            .frame(width: 200, height: 200 * Self.aspectRatio)
            .background(
                Image("sign-wooden-plank")
                    .resizable()
                    .scaledToFit()
            )
            .accessibilityElement(children: .ignore)
            .accessibilityLabel(Text(text))
            .accessibilityAddTraits(.isHeader)
    }
}

#Preview {
    SignTitleView(text: "Dino Hatch")
        .padding()
}
