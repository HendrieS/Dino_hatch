import SwiftUI
import SwiftData

struct AlarmView: View {
    @Environment(\.modelContext) private var modelContext
    @Query private var alarms: [AlarmSettings]

    @State private var isEnabled = false
    @State private var time = Calendar.current.date(bySettingHour: 7, minute: 0, second: 0, of: .now) ?? .now
    @State private var weekdays: Set<Int> = []
    @State private var notificationsDenied = false

    private let orderedWeekdays = [2, 3, 4, 5, 6, 7, 1] // Monday...Sunday

    /// Today's status, at a glance: the plain egg by default, the
    /// celebrating hatchling once today's alarm has actually been claimed
    /// within its 15-minute window, or the sad dino once that window has
    /// closed without a claim (see `AlarmClaimer`/`RootTabView`).
    private var headerImageName: String {
        guard let settings = alarms.first, settings.isEnabled else { return "alarm-egg" }
        if let lastHatchDate = settings.lastHatchDate, Calendar.current.isDateInToday(lastHatchDate) {
            return "alarm-reward"
        }
        if AlarmClaimer.wasMissedToday(
            hour: settings.hour,
            minute: settings.minute,
            weekdays: settings.repeatWeekdays,
            lastHatchDate: settings.lastHatchDate
        ) {
            return "alarm-sad"
        }
        return "alarm-egg"
    }

    var body: some View {
        NavigationStack {
            ScrollView {
                VStack(spacing: 24) {
                    Image(headerImageName)
                        .resizable()
                        .scaledToFit()
                        .frame(width: 130, height: 130)
                        .padding(.top, 12)

                    if headerImageName == "alarm-sad" {
                        Text("Missed it today — try again tomorrow!")
                            .font(.subheadline.bold())
                            .foregroundStyle(.secondary)
                            .multilineTextAlignment(.center)
                            .fixedSize(horizontal: false, vertical: true)
                    }

                    Text("Set a wake-up time and hatch\na dinosaur when you open the app!")
                        .font(.title3.bold())
                        .multilineTextAlignment(.center)
                        .fixedSize(horizontal: false, vertical: true)

                    Toggle("Alarm On", isOn: $isEnabled)
                        .padding(.horizontal, 40)

                    DatePicker("Wake-up time", selection: $time, displayedComponents: .hourAndMinute)
                        .datePickerStyle(.wheel)
                        .labelsHidden()
                        .disabled(!isEnabled)
                        .opacity(isEnabled ? 1 : 0.4)

                    VStack(spacing: 8) {
                        Text("Repeats on")
                            .font(.caption)
                            .foregroundStyle(.secondary)
                        HStack(spacing: 8) {
                            ForEach(orderedWeekdays, id: \.self) { weekday in
                                WeekdayToggle(weekday: weekday, isOn: weekdays.contains(weekday)) {
                                    toggle(weekday)
                                }
                            }
                        }
                    }
                    .disabled(!isEnabled)
                    .opacity(isEnabled ? 1 : 0.4)

                    if isEnabled {
                        Text("Open the app within 15 minutes of your alarm to hatch a dinosaur!")
                            .font(.footnote)
                            .foregroundStyle(.secondary)
                            .multilineTextAlignment(.center)
                            .fixedSize(horizontal: false, vertical: true)
                            .padding(.horizontal, 32)
                    }

                    if notificationsDenied {
                        Text("Notifications are off — you'll need to open the app yourself within that window.")
                            .font(.footnote)
                            .foregroundStyle(.secondary)
                            .multilineTextAlignment(.center)
                            .fixedSize(horizontal: false, vertical: true)
                            .padding(.horizontal, 32)
                    }
                }
                .padding()
                .padding(.bottom, 24)
            }
            .navigationTitle("Dino Alarm")
            .navigationBarTitleDisplayMode(.inline)
            .onAppear(perform: load)
            .onChange(of: isEnabled) { _, newValue in
                if newValue && weekdays.isEmpty {
                    weekdays = Set(1...7)
                }
                save()
            }
            .onChange(of: time) { _, _ in save() }
            .onChange(of: weekdays) { _, _ in save() }
        }
    }

    private func toggle(_ weekday: Int) {
        if weekdays.contains(weekday) {
            weekdays.remove(weekday)
        } else {
            weekdays.insert(weekday)
        }
    }

    private func load() {
        let settings = alarmSettings()
        isEnabled = settings.isEnabled
        weekdays = Set(settings.repeatWeekdays)
        time = Calendar.current.date(bySettingHour: settings.hour, minute: settings.minute, second: 0, of: .now) ?? time
    }

    private func save() {
        let settings = alarmSettings()
        let components = Calendar.current.dateComponents([.hour, .minute], from: time)
        settings.isEnabled = isEnabled
        settings.hour = components.hour ?? 7
        settings.minute = components.minute ?? 0
        settings.repeatWeekdays = Array(weekdays)

        if isEnabled {
            NotificationAuthorization.requestIfNeeded { granted in
                DispatchQueue.main.async {
                    notificationsDenied = !granted
                }
            }
            AlarmScheduler.reschedule(hour: settings.hour, minute: settings.minute, weekdays: settings.repeatWeekdays)
        } else {
            AlarmScheduler.cancelAll()
        }
    }

    private func alarmSettings() -> AlarmSettings {
        if let existing = alarms.first { return existing }
        let created = AlarmSettings()
        modelContext.insert(created)
        return created
    }
}

#Preview {
    AlarmView()
        .modelContainer(for: [AlarmSettings.self, UnlockedDinosaur.self, AppSettings.self], inMemory: true)
}
