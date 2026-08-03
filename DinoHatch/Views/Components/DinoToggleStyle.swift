import SwiftUI

/// A `Toggle` style matching the app's warm palette — the system switch's
/// thumb and off-state track are always plain white/near-white with no way
/// to recolor them via modifier, which read as too stark/cold next to the
/// rest of the warmed-up chrome (the dial ring track, the leaf art, etc.),
/// so this rebuilds the same capsule shape with a `dinoDialTrack`-toned knob
/// and a `dinoWarmBackgroundBottom`-toned off track instead — a lighter tone
/// than the knob so it stays visible when off, rather than reusing
/// `dinoDialTrack` for both and losing the knob against its own track.
struct DinoToggleStyle: ToggleStyle {
    private let trackSize = CGSize(width: 51, height: 31)
    private let knobDiameter: CGFloat = 27

    func makeBody(configuration: Configuration) -> some View {
        Button {
            configuration.isOn.toggle()
        } label: {
            HStack {
                configuration.label
                Spacer()
                Capsule()
                    .fill(configuration.isOn ? Color.dinoGreen : Color.dinoWarmBackgroundBottom)
                    .frame(width: trackSize.width, height: trackSize.height)
                    .overlay(alignment: configuration.isOn ? .trailing : .leading) {
                        Circle()
                            .fill(Color.dinoDialTrack)
                            .overlay(Circle().stroke(.white, lineWidth: 1.5))
                            .shadow(radius: 1)
                            .frame(width: knobDiameter, height: knobDiameter)
                            .padding(2)
                    }
                    .animation(.easeInOut(duration: 0.2), value: configuration.isOn)
            }
        }
        .buttonStyle(.plain)
    }
}

#Preview {
    VStack(spacing: 16) {
        Toggle("Alarm On", isOn: .constant(true))
        Toggle("Alarm On", isOn: .constant(false))
    }
    .toggleStyle(DinoToggleStyle())
    .padding()
}
