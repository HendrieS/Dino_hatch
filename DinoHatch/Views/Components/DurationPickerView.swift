import SwiftUI

struct DurationPickerView: View {
    @Binding var minutes: Int
    let options: [Int]

    var body: some View {
        VStack(spacing: 12) {
            Text("\(minutes) min")
                .font(.system(size: 44, weight: .bold, design: .rounded))

            Picker("Minutes", selection: $minutes) {
                ForEach(options, id: \.self) { value in
                    Text("\(value) min").tag(value)
                }
            }
            .pickerStyle(.wheel)
            .frame(height: 120)
            .padding(.horizontal, 32)
        }
    }
}

#Preview {
    DurationPickerView(minutes: .constant(5), options: [1, 3, 5, 10, 15, 20, 30, 45, 60])
}
