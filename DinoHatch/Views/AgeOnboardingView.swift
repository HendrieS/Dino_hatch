import SwiftUI
import SwiftData

/// Shown once, the first time the app is opened (whenever
/// `AppSettings.childAge` is nil — including after a full data reset from
/// `SettingsView`), gating the rest of the app until answered. See
/// `RootTabView`.
struct AgeOnboardingView: View {
    @Environment(\.modelContext) private var modelContext
    @Query private var settings: [AppSettings]

    @State private var age = 5

    var body: some View {
        VStack(spacing: 28) {
            Spacer()

            Text("🦕")
                .font(.system(size: 80))

            Text("How old is your child?")
                .font(.title2.bold())
                .multilineTextAlignment(.center)

            Text("This helps tailor what's unlocked in the app.")
                .font(.footnote)
                .foregroundStyle(.secondary)
                .multilineTextAlignment(.center)
                .padding(.horizontal, 40)

            Picker("Age", selection: $age) {
                ForEach(1...12, id: \.self) { value in
                    Text(value, format: .number).tag(value)
                }
            }
            .pickerStyle(.wheel)
            .frame(height: 140)
            .padding(.horizontal, 60)

            Button(action: save) {
                Text("Continue")
                    .font(.title3.bold())
                    .frame(maxWidth: .infinity)
                    .padding()
                    .background(Color.dinoGreen)
                    .foregroundStyle(.white)
                    .clipShape(RoundedRectangle(cornerRadius: 20))
            }
            .padding(.horizontal, 32)

            Spacer()
            Spacer()
        }
        .padding()
    }

    private func save() {
        let row = settings.first ?? {
            let created = AppSettings()
            modelContext.insert(created)
            return created
        }()
        row.childAge = age
    }
}

#Preview {
    AgeOnboardingView()
        .modelContainer(for: [AppSettings.self], inMemory: true)
}
