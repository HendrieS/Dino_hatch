import SwiftUI

/// Clock-face style duration picker: drag anywhere on the dial to set any
/// duration from 0:05 up to a full 60:00, or tap one of the 5-minute
/// numbers to jump straight to it (without starting the timer). The top of
/// the dial represents 60:00 rather than 0:00 — a 0-second timer makes no
/// sense to start, so that position (and the sliver of drag positions
/// nearest it) resolves to the max instead of the otherwise-meaningless
/// zero, same as how an analog clock's 12 reads as "the top of the hour"
/// rather than "zero." Dragging past the top still wraps around, which is
/// the expected feel for a dial like this rather than a bug to guard
/// against.
struct CircularDurationPicker: View {
    @Binding var totalSeconds: Int
    var diameter: CGFloat = 260

    static let maxSeconds = 3600
    static let snapSeconds = 5
    /// One full lap of the dial = 60 minutes exactly, so a round value like
    /// 5:00 lands precisely on the "5" tick — `maxSeconds` and the lap
    /// length are the same 3600 now that the top of the dial represents
    /// 60:00 rather than a separate just-short-of-max clamp.
    private static let secondsPerLap = 3600
    private let ringWidth: CGFloat = 18
    private let labelRadiusOffset: CGFloat = 20
    private let labelTapRadius: CGFloat = 18

    @State private var lastTappedMinuteMark: Int?

    private var progress: Double {
        Double(totalSeconds) / Double(Self.secondsPerLap)
    }

    private var labelRadius: CGFloat {
        diameter / 2 + labelRadiusOffset
    }

    /// The dial's own ring/ticks stay a fixed `diameter x diameter` visual
    /// size (each given an explicit frame below so they don't stretch), but
    /// the view's overall hit-testable area is grown to also cover the
    /// 5-minute labels sitting just outside that ring. Previously those
    /// labels had their own separate tap gesture, positioned outside the
    /// dial's hit area specifically so it wouldn't compete with the drag
    /// gesture — but that meant the parent gesture never saw a touch there
    /// at all, and the label's own gesture didn't reliably pick up the
    /// slack either, so tapping a number did nothing. Folding tap detection
    /// into the same already-working drag handler (`updateFromDrag`)
    /// removes the competing recognizer entirely instead of trying to win
    /// a priority race against it.
    private var interactiveDiameter: CGFloat {
        diameter + 2 * (labelRadiusOffset + labelTapRadius)
    }

    var body: some View {
        ZStack {
            Circle()
                .stroke(Color.dinoCardBackground, lineWidth: ringWidth)
                .frame(width: diameter, height: diameter)

            Circle()
                .trim(from: 0, to: progress)
                .stroke(Color.dinoGreen, style: StrokeStyle(lineWidth: ringWidth, lineCap: .round))
                .rotationEffect(.degrees(-90))
                .frame(width: diameter, height: diameter)

            ForEach(0..<60, id: \.self) { minute in
                if minute % 5 != 0 {
                    // dinoCardBackground (a near-white card-fill tone) was
                    // originally used here and was essentially invisible at
                    // this size — too little contrast against the screen
                    // background for a 4pt dot. .secondary matches the
                    // 5-minute number labels and actually shows up.
                    Circle()
                        .fill(Color.secondary.opacity(0.5))
                        .frame(width: 4, height: 4)
                        .offset(offset(forProgress: Double(minute) / 60, radius: diameter / 2 + ringWidth / 2 + 5))
                }
            }

            // Purely visual now — tapping is handled by `updateFromDrag`
            // via `interactiveDiameter`/`nearestMinuteMark`, not a gesture
            // on the label itself. Sized up from the original
            // caption-sized label since a tiny number is hard to read. The
            // mark at the top reads "60" (see `seconds(forMinuteMark:)`)
            // rather than "0", since the top position now represents the
            // max duration, not a meaningless zero.
            ForEach(Array(stride(from: 0, to: 60, by: 5)), id: \.self) { minuteMark in
                Text(minuteMark == 0 ? 60 : minuteMark, format: .number)
                    .font(.system(size: 15, weight: .bold, design: .rounded))
                    .foregroundStyle(Self.seconds(forMinuteMark: minuteMark) == totalSeconds ? Color.dinoGreen : .secondary)
                    .offset(offset(forProgress: Double(minuteMark) / 60, radius: labelRadius))
            }

            Circle()
                .fill(Color.dinoGreen)
                .frame(width: 28, height: 28)
                .overlay(Circle().stroke(.white, lineWidth: 3))
                .shadow(radius: 1)
                .offset(offset(forProgress: progress, radius: diameter / 2))

            Text(String(format: "%d:%02d", totalSeconds / 60, totalSeconds % 60))
                .font(.system(size: 40, weight: .bold, design: .rounded))
                .monospacedDigit()
        }
        .frame(width: interactiveDiameter, height: interactiveDiameter)
        .contentShape(Circle())
        .gesture(
            DragGesture(minimumDistance: 0)
                .onChanged { value in updateFromDrag(value.location) }
        )
        // Scoped to the tap shortcut specifically, rather than to every
        // `totalSeconds` change — dragging already re-snaps every 5
        // seconds, so tying feedback to that instead would buzz constantly
        // while dragging rather than confirming a deliberate tap.
        .sensoryFeedback(.selection, trigger: lastTappedMinuteMark)
        .accessibilityElement()
        .accessibilityLabel(Text("Duration"))
        .accessibilityValue(Text(String(format: "%d:%02d", totalSeconds / 60, totalSeconds % 60)))
        .accessibilityAdjustableAction { direction in
            switch direction {
            case .increment:
                totalSeconds = min(totalSeconds + 30, Self.maxSeconds)
            case .decrement:
                totalSeconds = max(totalSeconds - 30, Self.snapSeconds)
            default:
                break
            }
        }
    }

    /// `progress` is 0...1 around the dial, 0 = top, sweeping clockwise.
    /// Computed directly via sin/cos (rather than an `.offset` +
    /// `.rotationEffect` pair) so content stays upright — no ambiguity
    /// about what a chained rotation would do to already-offset content.
    private func offset(forProgress progress: Double, radius: CGFloat) -> CGSize {
        let angle = progress * 2 * .pi
        return CGSize(width: radius * sin(angle), height: -radius * cos(angle))
    }

    /// The 5-minute mark, if any, whose label sits within `labelTapRadius`
    /// of `location` — same center/offset math used to actually draw the
    /// labels, so hit-testing always matches what's on screen.
    private func nearestMinuteMark(to location: CGPoint, center: CGPoint) -> Int? {
        for minuteMark in stride(from: 0, to: 60, by: 5) {
            let labelOffset = offset(forProgress: Double(minuteMark) / 60, radius: labelRadius)
            let dx = location.x - (center.x + labelOffset.width)
            let dy = location.y - (center.y + labelOffset.height)
            if dx * dx + dy * dy <= labelTapRadius * labelTapRadius {
                return minuteMark
            }
        }
        return nil
    }

    /// Maps a tick's minute mark to the duration it actually represents —
    /// the mark at the top (0) means 60:00, the full lap, not a
    /// meaningless 0:00 (see the type's doc comment).
    private static func seconds(forMinuteMark minuteMark: Int) -> Int {
        minuteMark == 0 ? secondsPerLap : minuteMark * 60
    }

    private func updateFromDrag(_ location: CGPoint) {
        let center = CGPoint(x: interactiveDiameter / 2, y: interactiveDiameter / 2)

        if let minuteMark = nearestMinuteMark(to: location, center: center) {
            totalSeconds = min(Self.seconds(forMinuteMark: minuteMark), Self.maxSeconds)
            lastTappedMinuteMark = minuteMark
            return
        }

        let vector = CGPoint(x: location.x - center.x, y: location.y - center.y)
        var degrees = atan2(vector.y, vector.x) * 180 / .pi + 90
        if degrees < 0 { degrees += 360 }

        let rawSeconds = Int((degrees / 360) * Double(Self.secondsPerLap))
        // Self-qualified: an earlier version referenced `snapSeconds` bare
        // here (unlike `Self.maxSeconds` above) and that failed to compile
        // — always qualify static member references from instance scope.
        let snapped = (rawSeconds / Self.snapSeconds) * Self.snapSeconds
        // The sliver of drag positions right at/after the top snaps to 0 —
        // resolve that to the full lap (60:00) instead, same reasoning as
        // the top tick mark reading "60" rather than "0".
        let resolved = snapped == 0 ? Self.secondsPerLap : snapped
        totalSeconds = min(resolved, Self.maxSeconds)
    }
}

#Preview {
    CircularDurationPicker(totalSeconds: .constant(331))
        .padding()
}
