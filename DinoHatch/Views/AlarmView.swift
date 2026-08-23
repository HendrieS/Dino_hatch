import SwiftUI
import SwiftData

struct AlarmView: View {
    @Environment(\.modelContext) private var modelContext
    @Query private var alarms: [AlarmSettings]

    @State private var isEnabled = false
    @State private var time = Calendar.current.date(bySettingHour: 7, minute: 0, second: 0, of: .now) ?? .now
    @State private var weekdays: Set<Int> = []
    @State private var notificationsDenied = false
    @State private var showSettings = false

    private let orderedWeekdays = [2, 3, 4, 5, 6, 7, 1] // Monday...Sunday

    /// Today's status, at a glance: the plain egg by default, the
    /// celebrating hatchling once today's alarm has actually been claimed
    /// within its 15-minute window, or the sad dino once that window has
    /// closed without a claim (see `AlarmClaimer`/`RootTabView`). Stays the
    /// plain egg — not sad — if the alarm was only armed after today's
    /// window already closed (`isPendingFirstChance`), since there was
    /// nothing to actually miss.
    private var headerImageName: String {
        guard let settings = alarms.first, settings.isEnabled else { return "alarm-egg" }
        if let lastHatchDate = settings.lastHatchDate, Calendar.current.isDateInToday(lastHatchDate) {
            return "alarm-reward"
        }
        if AlarmClaimer.wasMissedToday(
            hour: settings.hour,
            minute: settings.minute,
            weekdays: settings.repeatWeekdays,
            lastHatchDate: settings.lastHatchDate,
            enabledAt: settings.enabledAt
        ) {
            return "alarm-sad"
        }
        return "alarm-egg"
    }

    /// True right after the alarm is armed too late to catch today's window
    /// — shows an encouraging "get ready for next time" message (see
    /// `nextAlarmIsTomorrow`) instead of the sad "missed it" one.
    private var isPendingFirstChance: Bool {
        guard let settings = alarms.first, settings.isEnabled else { return false }
        return AlarmClaimer.isPendingFirstChance(
            hour: settings.hour,
            minute: settings.minute,
            weekdays: settings.repeatWeekdays,
            lastHatchDate: settings.lastHatchDate,
            enabledAt: settings.enabledAt
        )
    }

    /// The next concrete time the alarm will actually fire, respecting
    /// which weekdays are selected — used only to decide whether the
    /// header message below can say "tomorrow" truthfully (e.g. today's
    /// window closing on a Friday with only weekdays selected means the
    /// next occurrence is Monday, not tomorrow).
    private var nextAlarmFireDate: Date? {
        guard let settings = alarms.first, settings.isEnabled else { return nil }
        return AlarmNextFireDate.next(hour: settings.hour, minute: settings.minute, weekdays: settings.repeatWeekdays)
    }

    private var nextAlarmIsTomorrow: Bool {
        guard let nextAlarmFireDate else { return false }
        return Calendar.current.isDateInTomorrow(nextAlarmFireDate)
    }

    /// True when today simply isn't a scheduled weekday — the complement to
    /// `isPendingFirstChance` (see `AlarmClaimer.isTodayUnscheduled`).
    /// Checked after `displayedStreak` below so an active streak still shows
    /// on a non-alarm day instead of being replaced by this nudge.
    private var isTodayUnscheduled: Bool {
        guard let settings = alarms.first, settings.isEnabled else { return false }
        return AlarmClaimer.isTodayUnscheduled(weekdays: settings.repeatWeekdays, lastHatchDate: settings.lastHatchDate)
    }

    /// Consecutive scheduled alarms claimed in a row, zeroed out the moment
    /// today's window closes unclaimed rather than waiting for the next
    /// claim to overwrite the persisted count — matches how `headerImageName`
    /// reacts immediately to a missed window too.
    private var displayedStreak: Int {
        guard let settings = alarms.first, settings.isEnabled else { return 0 }
        if AlarmClaimer.wasMissedToday(
            hour: settings.hour,
            minute: settings.minute,
            weekdays: settings.repeatWeekdays,
            lastHatchDate: settings.lastHatchDate,
            enabledAt: settings.enabledAt
        ) {
            return 0
        }
        return settings.streakCount
    }

    /// Shared by `isPendingFirstChance` and `isTodayUnscheduled` — same
    /// wording either way, since from the parent's perspective both just
    /// mean "nothing to claim today, here's when the next one is."
    @ViewBuilder
    private var getReadyMessage: some View {
        Group {
            if nextAlarmIsTomorrow {
                Text("Get ready to wake up on time tomorrow!")
            } else {
                Text("Get ready to wake up on time for your next alarm!")
            }
        }
        .font(.subheadline.bold())
        .foregroundStyle(Color.dinoGreen)
        .multilineTextAlignment(.center)
        .fixedSize(horizontal: false, vertical: true)
    }

    var body: some View {
        NavigationStack {
            VStack(spacing: 0) {
                SignTitleView(text: "Dino Alarm")
                    // Pinned here, outside the ScrollView below, so it stays
                    // fixed in place while the rest of the screen scrolls
                    // underneath rather than scrolling away with it. The
                    // offset itself is unchanged from before this split —
                    // still -60 against this VStack's own default 16pt
                    // `.padding()` below (rather than TimerSetupView's -84,
                    // whose own top inset is 24pt taller) — only where the
                    // sign lives in the hierarchy changed, not its rendered
                    // position.
                    .offset(y: -60)

                ScrollView {
                    VStack(spacing: 24) {
                    Image(headerImageName)
                        .resizable()
                        .scaledToFit()
                        .frame(width: 130, height: 130)
                        // -24 reproduces the exact +12pt gap the old -48
                        // did back when this sat right after the sign in
                        // one shared VStack (24 declared spacing - 48 = -24
                        // net): now that this is the ScrollView's own first
                        // child, it gets no automatic spacing before it, so
                        // that 24 has to be folded directly into this
                        // padding instead — see TimerSetupView's matching
                        // CircularDurationPicker comment for the same
                        // reasoning.
                        .padding(.top, -24)

                    // The invisible placeholder reserves one line's worth of
                    // height at all times, so toggling a weekday (which can
                    // flip any of the branches below on or off) doesn't
                    // collapse this area to zero height and shift the time
                    // picker and everything under it up or down.
                    ZStack {
                        Text(verbatim: "placeholder")
                            .font(.subheadline.bold())
                            .opacity(0)
                            .accessibilityHidden(true)

                        if headerImageName == "alarm-sad" {
                            Group {
                                if nextAlarmIsTomorrow {
                                    Text("Missed it today — try again tomorrow!")
                                } else {
                                    Text("Missed it today — try again next time!")
                                }
                            }
                            .font(.subheadline.bold())
                            .foregroundStyle(.secondary)
                            .multilineTextAlignment(.center)
                            .fixedSize(horizontal: false, vertical: true)
                        } else if isPendingFirstChance {
                            getReadyMessage
                        } else if displayedStreak > 0 {
                            HStack(spacing: 4) {
                                Text("🔥")
                                Text(displayedStreak, format: .number)
                                Text("day streak")
                            }
                            .font(.subheadline.bold())
                            .foregroundStyle(Color.dinoGreen)
                        } else if isTodayUnscheduled {
                            getReadyMessage
                        }
                    }

                    Text("Set a wake-up time and hatch\na dinosaur when you open the app!")
                        .font(.title3.bold())
                        .multilineTextAlignment(.center)
                        .fixedSize(horizontal: false, vertical: true)

                    Toggle("Alarm On", isOn: $isEnabled)
                        .toggleStyle(DinoToggleStyle())
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
                            .padding(.horizontal, 12)
                            .padding(.vertical, 8)
                            .background(Color.dinoDialTrack.opacity(0.6), in: RoundedRectangle(cornerRadius: 12))
                            .padding(.horizontal, 32)
                    }

                    if notificationsDenied {
                        Text("Notifications are off — you'll need to open the app yourself within that window.")
                            .font(.footnote)
                            .foregroundStyle(.secondary)
                            .multilineTextAlignment(.center)
                            .fixedSize(horizontal: false, vertical: true)
                            .padding(.horizontal, 12)
                            .padding(.vertical, 8)
                            .background(Color.dinoDialTrack, in: RoundedRectangle(cornerRadius: 12))
                            .padding(.horizontal, 32)
                    }
                    }
                    .padding(.bottom)
                    .padding(.bottom, 24)
                }
            }
            .padding(.horizontal)
            .padding(.top)
            .frame(maxWidth: 500)
            .frame(maxWidth: .infinity)
            .dinoWarmBackground()
            .toolbar {
                ToolbarItem(placement: .topBarLeading) {
                    SupporterBadgeView()
                }
                ToolbarItem(placement: .topBarTrailing) {
                    Button {
                        showSettings = true
                    } label: {
                        Image(systemName: "gearshape.fill")
                    }
                }
            }
            // Full screen rather than a sheet — see CollectionView's
            // matching change for Settings; same bleeding fauna background
            // reasoning applies here.
            .fullScreenCover(isPresented: $showSettings) {
                ParentalGateView()
            }
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
        let wasEnabled = settings.isEnabled
        let components = Calendar.current.dateComponents([.hour, .minute], from: time)
        settings.isEnabled = isEnabled
        settings.hour = components.hour ?? 7
        settings.minute = components.minute ?? 0
        settings.repeatWeekdays = Array(weekdays)

        if isEnabled && !wasEnabled {
            settings.enabledAt = .now
        }

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
