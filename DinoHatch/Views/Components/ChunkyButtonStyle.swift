import SwiftUI

/// A "chunky" 3D press button: a darker slab of `edgeColor` peeks out as a
/// rim below the colored face, and tapping flattens the face down to cover
/// that rim — like a real button being pressed in — rather than the plain
/// flat pill every primary action button used before. Chosen over new
/// illustrated art (a wood-plank or paw-shaped button, the other two
/// directions considered) specifically so every existing green/red action
/// button gets it for free just by swapping its button style, no new art
/// needed.
struct ChunkyButtonStyle: ButtonStyle {
    var color: Color
    var edgeColor: Color
    var cornerRadius: CGFloat = 20

    private let edgeHeight: CGFloat = 6

    func makeBody(configuration: Configuration) -> some View {
        let pressed = configuration.isPressed
        configuration.label
            .font(.title3.bold())
            .foregroundStyle(.white)
            .frame(maxWidth: .infinity)
            .padding()
            .background(color, in: RoundedRectangle(cornerRadius: cornerRadius))
            // The extra bottom padding (removed on press) is transparent,
            // so the edge color behind it — sized to match this whole
            // padded shape — only ever shows through in that bottom
            // sliver, never behind the opaque face above it.
            .padding(.bottom, pressed ? 0 : edgeHeight)
            .background(RoundedRectangle(cornerRadius: cornerRadius).fill(edgeColor))
            .animation(.spring(response: 0.25, dampingFraction: 0.55), value: pressed)
    }
}

extension ButtonStyle where Self == ChunkyButtonStyle {
    static var dinoChunkyGreen: ChunkyButtonStyle {
        ChunkyButtonStyle(color: .dinoGreen, edgeColor: .dinoGreenShadow)
    }
    static var dinoChunkyRed: ChunkyButtonStyle {
        ChunkyButtonStyle(color: .dinoRed, edgeColor: .dinoRedShadow)
    }
}

#Preview {
    VStack(spacing: 24) {
        Button("Start Timer") {}
            .buttonStyle(.dinoChunkyGreen)
        Button("Cancel Timer") {}
            .buttonStyle(.dinoChunkyRed)
        Button("Disabled") {}
            .buttonStyle(ChunkyButtonStyle(color: .gray, edgeColor: .dinoGrayShadow))
            .disabled(true)
    }
    .padding(32)
}
