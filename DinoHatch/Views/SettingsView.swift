import SwiftUI
import SwiftData

struct SettingsView: View {
    @Environment(\.modelContext) private var modelContext
    @Environment(\.dismiss) private var dismiss
    @Query(sort: \AppSettings.createdAt) private var settings: [AppSettings]
    @Query private var unlocked: [UnlockedDinosaur]
    @Query private var alarms: [AlarmSettings]

    @State private var age = 5
    @State private var isTimerLockEnabled = false
    @State private var showResetConfirmation = false
    @State private var showSupportUs = false

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
                    Toggle("Timer Lock", isOn: $isTimerLockEnabled)
                        .onChange(of: isTimerLockEnabled) { _, newValue in
                            settingsRow().isTimerLockEnabled = newValue
                        }
                } footer: {
                    Text("When on, cancelling a running timer needs this same math check — handy for quiet time, waiting turns, or anything else you don't want ended early. Picking or changing the duration before starting is never gated.")
                }

                Section {
                    AppIconPicker(unlockedIDs: Set(unlocked.map(\.dinosaurID)))
                } header: {
                    Text("App Icon")
                } footer: {
                    Text("Icons unlock as you hatch dinosaurs — some for a specific species, others once you've hatched enough in total.")
                }

                Section {
                    NavigationLink("Help Center") {
                        HelpCenterView()
                    }
                }

                if FeatureFlags.supporterDonationsEnabled {
                    Section {
                        Button("Support Dino Hatch") {
                            showSupportUs = true
                        }
                    } footer: {
                        Text("Dino Hatch is free and always will be — this is completely optional.")
                    }
                }

                Section {
                    Button("Reset All Data", role: .destructive) {
                        showResetConfirmation = true
                    }
                } footer: {
                    // This is the last row in the Form, so scrolling to the
                    // bottom can put it directly over the fern corners —
                    // a plain footer Text there was unreadable against
                    // that busy art, so it gets its own opaque card like
                    // other floating text elsewhere in the app (e.g.
                    // AlarmView's "Notifications are off" banner).
                    Text("Erases the dinosaur collection, timer, and alarm settings, and asks for the child's age again.")
                        .padding(10)
                        .background(Color.dinoCardBackground, in: RoundedRectangle(cornerRadius: 10))
                }

                // Invisible spacer row — without it, this Form's content
                // ends right where the fern corners start, and since the
                // ferns now render in front of content (not behind it),
                // there was no way to scroll this section clear of them.
                Section {
                    Color.clear
                        .frame(height: 90)
                        .listRowBackground(Color.clear)
                        .listRowSeparator(.hidden)
                }
            }
            .navigationTitle("Settings")
            .scrollContentBackground(.hidden)
            .dinoWarmBackground()
            .toolbar {
                ToolbarItem(placement: .confirmationAction) {
                    Button("Done") { dismiss() }
                }
            }
            .onAppear {
                age = settings.first?.childAge ?? 5
                isTimerLockEnabled = settings.first?.isTimerLockEnabled ?? false
            }
            // .alert rather than .confirmationDialog — the dialog was
            // anchored to the triggering button, which sits at the very
            // bottom of the Form, and ended up presenting in an unexpected
            // spot near the top of the screen instead. An alert always
            // presents centered, independent of where it was triggered
            // from.
            .alert("Are you sure?", isPresented: $showResetConfirmation) {
                Button("Reset Everything", role: .destructive, action: resetAll)
                Button("Cancel", role: .cancel) {}
            } message: {
                Text("This can't be undone.")
            }
            // Full screen rather than a sheet — see CollectionView's
            // matching change for Settings itself; same reasoning applies
            // here since SupportUsView also uses the bleeding fauna
            // background.
            .fullScreenCover(isPresented: $showSupportUs) {
                SupportUsView()
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
