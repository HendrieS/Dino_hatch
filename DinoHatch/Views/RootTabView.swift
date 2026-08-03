import SwiftUI
import SwiftData
import Combine
import WidgetKit

struct RootTabView: View {
    private enum Tab: Hashable {
        case timer, alarm, collection
    }

    @Environment(\.modelContext) private var modelContext
    @Environment(\.scenePhase) private var scenePhase
    @Query private var alarms: [AlarmSettings]
    @Query private var unlocked: [UnlockedDinosaur]
    @Query(sort: \AppSettings.createdAt) private var appSettings: [AppSettings]

    @State private var pendingAlarmDinosaur: Dinosaur?
    @State private var whatsNewNotes: [ReleaseNote] = []
    @State private var showWhatsNew = false
    @State private var selectedTab: Tab = .timer
    /// Refreshed every minute (and on every foreground transition) purely
    /// to keep the Alarm tab's missed-window badge current — unlike the
    /// timer banner's TimelineView, this needs to tick even while the Timer
    /// tab is showing, since the badge lives on the tab bar itself.
    @State private var now: Date = .now
    private let minuteTimer = Timer.publish(every: 60, on: .main, in: .common).autoconnect()

    var body: some View {
        Group {
            if appSettings.first?.childAge == nil {
                AgeOnboardingView()
            } else {
                mainTabView
            }
        }
    }

    private var mainTabView: some View {
        ZStack(alignment: .top) {
            TabView(selection: $selectedTab) {
                TimerHomeView(isActive: selectedTab == .timer)
                    .tabItem {
                        Label {
                            Text("Timer")
                        } icon: {
                            Image("timer-icon")
                                .resizable()
                                .scaledToFit()
                                .frame(width: 25, height: 25)
                        }
                    }
                    .tag(Tab.timer)

                AlarmView()
                    .tabItem {
                        Label {
                            Text("Alarm")
                        } icon: {
                            Image("alarm-icon")
                                .resizable()
                                .scaledToFit()
                                .frame(width: 25, height: 25)
                        }
                    }
                    .tag(Tab.alarm)
                    .badge(alarmWasMissedToday(at: now) ? Text(verbatim: "!") : nil)

                CollectionView()
                    .tabItem {
                        Label {
                            Text("Collection")
                        } icon: {
                            Image("collection-icon")
                                .resizable()
                                .scaledToFit()
                                .frame(width: 25, height: 25)
                        }
                    }
                    .tag(Tab.collection)
            }
            .onAppear(perform: checkAlarmHatch)
            .onAppear(perform: refreshWidgetSnapshot)
            .onAppear(perform: checkWhatsNew)
            .onChange(of: scenePhase) { _, newPhase in
                if newPhase == .active {
                    now = .now
                    checkAlarmHatch()
                    // Also covers the alarm's next-fire date having simply
                    // passed since the last save, with no settings change
                    // to key off of.
                    refreshWidgetSnapshot()
                }
            }
            .onChange(of: unlocked.count) { _, _ in
                refreshWidgetSnapshot()
            }
            .onChange(of: alarmFingerprint) { _, _ in
                refreshWidgetSnapshot()
            }
            .onChange(of: timerFingerprint) { _, _ in
                refreshWidgetSnapshot()
            }
            .onChange(of: appSettings.first?.supporterTierRawValue) { _, _ in
                refreshWidgetSnapshot()
            }
            .onReceive(minuteTimer) { date in
                now = date
            }
            .fullScreenCover(item: $pendingAlarmDinosaur) { dinosaur in
                AlarmHatchView(dinosaur: dinosaur) {
                    unlock(dinosaur)
                } onDone: {
                    pendingAlarmDinosaur = nil
                }
            }
            .sheet(isPresented: $showWhatsNew) {
                WhatsNewView(notes: whatsNewNotes)
            }

            if selectedTab != .timer {
                TimelineView(.periodic(from: .now, by: 1)) { context in
                    Group {
                        if isTimerReady(at: context.date) {
                            TimerReadyBanner {
                                selectedTab = .timer
                            }
                            .padding(.top, 8)
                            .transition(.move(edge: .top).combined(with: .opacity))
                        }
                    }
                    .animation(.spring(response: 0.4, dampingFraction: 0.8), value: isTimerReady(at: context.date))
                }
            }
        }
    }

    /// A cheap, `Equatable` stand-in for "have the alarm's settings
    /// changed" — `AlarmSettings` is a SwiftData reference type, so
    /// `.onChange(of: alarms)` wouldn't reliably fire on in-place property
    /// edits (toggling on/off, changing the time or weekdays) the way it
    /// does for a value type.
    private var alarmFingerprint: String {
        guard let settings = alarms.first else { return "none" }
        return "\(settings.isEnabled)-\(settings.hour)-\(settings.minute)-\(settings.repeatWeekdays.sorted())"
    }

    /// Same reasoning as `alarmFingerprint`, but for the running timer —
    /// `AppSettings` is also a SwiftData reference type, so starting,
    /// cancelling, or completing a timer (all in-place property edits from
    /// `TimerEngine`) needs an explicit key to react to.
    private var timerFingerprint: String {
        guard let settings = appSettings.first else { return "none" }
        return "\(settings.activeTimerEndDate?.timeIntervalSince1970 ?? -1)-\(settings.pendingDinosaurID ?? "")"
    }

    /// True once a running timer's egg has finished counting down but the
    /// hatch animation hasn't played yet — `TimerHomeView` deliberately
    /// holds off playing it until the Timer tab is on screen (see
    /// `TimerHomeView.advanceToHatching()`), so this banner is what tells a
    /// kid on another tab there's a dinosaur waiting.
    private func isTimerReady(at date: Date) -> Bool {
        guard let settings = appSettings.first,
              let endDate = settings.activeTimerEndDate,
              settings.pendingDinosaurID != nil else { return false }
        return date >= endDate
    }

    /// Drives the "!" badge on the Alarm tab so a missed window is
    /// noticeable without needing to open that tab — the sad-dino art in
    /// `AlarmView` shows the same thing, but only once you're already
    /// looking at it.
    private func alarmWasMissedToday(at date: Date) -> Bool {
        guard let settings = alarms.first, settings.isEnabled else { return false }
        return AlarmClaimer.wasMissedToday(
            hour: settings.hour,
            minute: settings.minute,
            weekdays: settings.repeatWeekdays,
            lastHatchDate: settings.lastHatchDate,
            enabledAt: settings.enabledAt,
            now: date
        )
    }

    /// Checked on every foreground transition rather than tied to the
    /// notification itself firing — the app can't run custom code exactly
    /// when a background notification delivers, so this works whether or
    /// not the kid taps the notification, and even if permission was
    /// denied. See `AlarmClaimer`.
    private func checkAlarmHatch() {
        guard pendingAlarmDinosaur == nil, let settings = alarms.first, settings.isEnabled else { return }
        guard AlarmClaimer.isReady(
            hour: settings.hour,
            minute: settings.minute,
            weekdays: settings.repeatWeekdays,
            lastHatchDate: settings.lastHatchDate
        ) else { return }

        settings.streakCount = AlarmStreak.nextStreak(
            currentStreak: settings.streakCount,
            lastHatchDate: settings.lastHatchDate,
            weekdays: settings.repeatWeekdays
        )
        settings.lastHatchDate = .now
        let unlockedIDs = Set(unlocked.map(\.dinosaurID))
        pendingAlarmDinosaur = HatchSelector.pickNext(unlockedIDs: unlockedIDs)
    }

    /// Checked once per `mainTabView` appearance (i.e. once per real app
    /// launch, not on every foreground — see `RootTabView`'s `onAppear`
    /// vs. `onChange(of: scenePhase)` split above), rather than gating on
    /// `scenePhase` too — a returning-from-background app shouldn't pop this
    /// up again mid-session just because a minute passed.
    private func checkWhatsNew() {
        guard let settings = appSettings.first else { return }
        let currentVersion = Bundle.main.infoDictionary?["CFBundleShortVersionString"] as? String ?? "1.0"
        let notes = WhatsNewGate.notesToShow(currentVersion: currentVersion, lastSeenVersion: settings.lastSeenAppVersion)
        settings.lastSeenAppVersion = currentVersion
        guard !notes.isEmpty else { return }
        whatsNewNotes = notes
        showWhatsNew = true
    }

    private func unlock(_ dinosaur: Dinosaur) {
        guard !unlocked.contains(where: { $0.dinosaurID == dinosaur.id }) else { return }
        modelContext.insert(UnlockedDinosaur(dinosaurID: dinosaur.id))
    }

    /// Keeps the Home Screen widgets' App Group snapshot in sync — called on
    /// every launch/foreground (to cover first install with existing data,
    /// and the alarm's next-fire date simply having passed), whenever the
    /// unlocked count changes (covers both the alarm's `unlock(_:)` above
    /// and the timer's own insert in `TimerHomeView`), and whenever the
    /// alarm's or timer's settings change (`alarmFingerprint`/
    /// `timerFingerprint`).
    private func refreshWidgetSnapshot() {
        let records = unlocked.map {
            WidgetSnapshotBuilder.UnlockRecord(dinosaurID: $0.dinosaurID, unlockedAt: $0.unlockedAt)
        }
        let alarmInfo = alarms.first.map {
            WidgetSnapshotBuilder.AlarmInfo(hour: $0.hour, minute: $0.minute, weekdays: $0.repeatWeekdays, isEnabled: $0.isEnabled)
        }
        let activeTimerEndDate = appSettings.first?.activeTimerEndDate
        let supporterTier = appSettings.first?.supporterTier
        WidgetSnapshotStore.save(WidgetSnapshotBuilder.build(unlocked: records, alarm: alarmInfo, activeTimerEndDate: activeTimerEndDate, supporterTier: supporterTier))
        WidgetCenter.shared.reloadTimelines(ofKind: WidgetSnapshotStore.widgetKind)
        WidgetCenter.shared.reloadTimelines(ofKind: WidgetSnapshotStore.alarmWidgetKind)
        WidgetCenter.shared.reloadTimelines(ofKind: WidgetSnapshotStore.quickTimerWidgetKind)
    }
}

#Preview {
    RootTabView()
        .modelContainer(for: [UnlockedDinosaur.self, AppSettings.self, AlarmSettings.self], inMemory: true)
}
