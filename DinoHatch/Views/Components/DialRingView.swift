import SwiftUI

/// Just the track + progress arc — shared between `CircularDurationPicker`
/// (interactive, editable during setup) and `CountdownView`'s live
/// countdown ring (read-only). Both use the same dinoDialTrack track /
/// dinoGreen arc styling; only what `progress` represents differs (how much
/// of the dial is selected vs. how much time remains), which this view
/// doesn't need to know or care about.
struct DialRingView: View {
    let progress: Double
    var ringWidth: CGFloat = 18

    var body: some View {
        ZStack {
            Circle()
                .stroke(Color.dinoDialTrack, lineWidth: ringWidth)

            Circle()
                .trim(from: 0, to: progress)
                .stroke(Color.dinoGreen, style: StrokeStyle(lineWidth: ringWidth, lineCap: .round))
                .rotationEffect(.degrees(-90))
        }
    }
}

#Preview {
    DialRingView(progress: 0.65)
        .frame(width: 200, height: 200)
        .padding()
}
