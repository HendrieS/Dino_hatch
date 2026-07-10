import SwiftUI

struct DurationPickerView: View {
    @Binding var minutes: Int
    @Binding var seconds: Int

    var body: some View {
        VStack(spacing: 12) {
            Text(String(format: "%d:%02d", minutes, seconds))
                .font(.system(size: 44, weight: .bold, design: .rounded))
                .monospacedDigit()

            HStack(spacing: 0) {
                VStack(spacing: 4) {
                    Text("Minutes")
                        .font(.caption)
                        .foregroundStyle(.secondary)
                    Picker("Minutes", selection: $minutes) {
                        ForEach(0..<60, id: \.self) { value in
                            Text(value, format: .number).tag(value)
                        }
                    }
                    .pickerStyle(.wheel)
                }

                VStack(spacing: 4) {
                    Text("Seconds")
                        .font(.caption)
                        .foregroundStyle(.secondary)
                    Picker("Seconds", selection: $seconds) {
                        ForEach(0..<60, id: \.self) { value in
                            Text(value, format: .number).tag(value)
                        }
                    }
                    .pickerStyle(.wheel)
                }
            }
            .frame(height: 140)
            .padding(.horizontal, 16)
        }
    }
}

#Preview {
    DurationPickerView(minutes: .constant(5), seconds: .constant(31))
}
