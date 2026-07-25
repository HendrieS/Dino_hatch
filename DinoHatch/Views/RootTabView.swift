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
    @Query private var appSettings: [AppSettings]

    @State private var pendingAlarmDinosaur: Dinosaur?
    @State private var selectedTab: Tab = .timer
    /// Set from the Quick Timer widget's `dinohatch://start-timer` link (see
    /// `QuickStartLink`) and cleared once `TimerHomeView` consumes it —
    /// `Binding` rather than a callback so `TimerHomeView` can ignore it
    /// while a timer's already running instead of stomping on one.
    @State private var pendingQuickStartMinutes: Int?
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
                TimerHomeView(isActive: selectedTab == .timer, pendingQuickStartMinutes: $pendingQuickStartMinutes)
                    .tabItem {
                        Label("Timer", systemImage: "hourglass")
                    }
                    .tag(Tab.timer)

                AlarmView()
                    .tabItem {
                        Label("Alarm", systemImage: "alarm.fill")
                    }
                    .tag(Tab.alarm)
                    .badge(alarmWasMissedToday(at: now) ? Text(verbatim: "!") : nil)

                CollectionView()
                    .tabItem {
                        Label("Collection", systemImage: "book.closed.fill")
                    }
                    .tag(Tab.collection)
            }
            .onAppear(perform: checkAlarmHatch)
            .onAppear(perform: refreshWidgetSnapshot)
            .onChange(of: scenePhase) { _, newPhase in
                if newPhase == .active {
                    now = .now
                    checkAlarmHatch()
                }
            }
            .onChange(of: unlocked.count) { _, _ in
                refreshWidgetSnapshot()
            }
            .onReceive(minuteTimer) { date in
                now = date
            }
            .onOpenURL { url in
                guard let minutes = QuickStartLink.minutes(from: url) else { return }
                pendingQuickStartMinutes = minutes
                selectedTab = .timer
            }
            .fullScreenCover(item: $pendingAlarmDinosaur) { dinosaur in
                AlarmHatchView(dinosaur: dinosaur) {
                    unlock(dinosaur)
                } onDone: {
                    pendingAlarmDinosaur = nil
                }
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

    private func unlock(_ dinosaur: Dinosaur) {
        guard !unlocked.contains(where: { $0.dinosaurID == dinosaur.id }) else { return }
        modelContext.insert(UnlockedDinosaur(dinosaurID: dinosaur.id))
    }

    /// Keeps the Home Screen widget's App Group snapshot in sync — called on
    /// every launch/foreground (to cover first install with existing data)
    /// and whenever the unlocked count changes (covers both the alarm's
    /// `unlock(_:)` above and the timer's own insert in `TimerHomeView`).
    private func refreshWidgetSnapshot() {
        let records = unlocked.map {
            WidgetSnapshotBuilder.UnlockRecord(dinosaurID: $0.dinosaurID, unlockedAt: $0.unlockedAt)
        }
        WidgetSnapshotStore.save(WidgetSnapshotBuilder.build(unlocked: records))
        WidgetCenter.shared.reloadTimelines(ofKind: WidgetSnapshotStore.widgetKind)
    }
}

#Preview {
    RootTabView()
        .modelContainer(for: [UnlockedDinosaur.self, AppSettings.self, AlarmSettings.self], inMemory: true)
}
