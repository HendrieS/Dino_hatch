import SwiftUI

/// A single tappable day-of-week circle. `weekday` uses `Calendar`'s
/// convention (1 = Sunday ... 7 = Saturday). The label comes straight from
/// `Calendar.current.veryShortWeekdaySymbols`, which is already
/// locale-correct, so it's shown `.verbatim` rather than routed through
/// our own localization catalog.
struct WeekdayToggle: View {
    let weekday: Int
    let isOn: Bool
    let action: () -> Void

    private var label: String {
        Calendar.current.veryShortWeekdaySymbols[weekday - 1]
    }

    var body: some View {
        Button(action: action) {
            Text(verbatim: label)
                .font(.subheadline.bold())
                .frame(width: 36, height: 36)
                .background(isOn ? Color.dinoGreen : Color.dinoCardBackground)
                .foregroundStyle(isOn ? .white : .primary)
                .clipShape(Circle())
        }
        .buttonStyle(.plain)
    }
}

#Preview {
    HStack {
        ForEach([2, 3, 4, 5, 6, 7, 1], id: \.self) { weekday in
            WeekdayToggle(weekday: weekday, isOn: weekday % 2 == 0) {}
        }
    }
    .padding()
}
