import SwiftUI
import SwiftData

struct SettingsView: View {
    @Environment(\.modelContext) private var modelContext
    @Environment(\.dismiss) private var dismiss
    @Query private var settings: [AppSettings]
    @Query private var unlocked: [UnlockedDinosaur]
    @Query private var alarms: [AlarmSettings]

    @State private var age = 5
    @State private var showResetConfirmation = false

    var body: some View {
        NavigationStack {
            Form {
                Section("Child's Age") {
                    Picker("Age", selection: $age) {
                        ForEach(1...12, id: \.self) { value in
                            Text(value, format: .number).tag(value)
                        }
                    }
                    .onChange(of: age) { _, newValue in
                        settingsRow().childAge = newValue
                    }
                }

                Section {
                    NavigationLink("Help Center") {
                        HelpCenterView()
                    }
                }

                Section {
                    Button("Reset All Data", role: .destructive) {
                        showResetConfirmation = true
                    }
                } footer: {
                    Text("Erases the dinosaur collection, timer, and alarm settings, and asks for the child's age again.")
                }
            }
            .navigationTitle("Settings")
            .toolbar {
                ToolbarItem(placement: .confirmationAction) {
                    Button("Done") { dismiss() }
                }
            }
            .onAppear {
                age = settings.first?.childAge ?? 5
            }
            .confirmationDialog(
                "Are you sure?",
                isPresented: $showResetConfirmation,
                titleVisibility: .visible
            ) {
                Button("Reset Everything", role: .destructive, action: resetAll)
                Button("Cancel", role: .cancel) {}
            } message: {
                Text("This can't be undone.")
            }
        }
    }

    private func settingsRow() -> AppSettings {
        if let existing = settings.first { return existing }
        let created = AppSettings()
        modelContext.insert(created)
        return created
    }

    private func resetAll() {
        for record in unlocked {
            modelContext.delete(record)
        }
        for row in settings {
            modelContext.delete(row)
        }
        for alarm in alarms {
            modelContext.delete(alarm)
        }
        dismiss()
    }
}

#Preview {
    SettingsView()
        .modelContainer(for: [AppSettings.self, UnlockedDinosaur.self, AlarmSettings.self], inMemory: true)
}
