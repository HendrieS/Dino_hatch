import SwiftUI
import SwiftData
import Combine
import WidgetKit

struct RootTabView: View {
    /// Not `private` — `FloatingNavMenu` (a separate file) binds to this
    /// same type so it can drive `selectedTab` without RootTabView needing
    /// to translate to/from some more generic representation.
    enum Tab: Hashable {
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
    @State private var collectionCompleteMascots: [Dinosaur] = []
    @State private var showCollectionComplete = false
    @State private var selectedTab: Tab = .timer
    /// True while `TimerHomeView` is showing its hatch animation or reveal
    /// — see `FloatingNavMenu`'s conditional rendering below.
    @State private var isTimerCelebrating = false
    /// True while `CollectionView` has a dinosaur's detail view pushed —
    /// same reasoning and same conditional rendering as
    /// `isTimerCelebrating`.
    @State private var isCollectionShowingDetail = false
    /// True once `CollectionView`'s grid actually needs to scroll — drives
    /// its own `.scrollDisabled`; see `CollectionView.isScrollable`.
    @State private var isCollectionScrollable = true
    /// Refreshed every minute (and on every foreground transition) purely
    /// to keep the Alarm destination's missed-window badge current — unlike
    /// the timer banner's TimelineView, this needs to tick even while the
    /// Timer screen is showing, since the badge lives on `FloatingNavMenu`,
    /// which stays on screen across every tab.
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
            // A plain switch rather than TabView — .toolbar(.hidden, for:
            // .tabBar) plus .toolbarBackground(.hidden, for: .tabBar) still
            // left an empty translucent bar-shaped background on screen,
            // confirmed on device, so this sidesteps that instead of
            // continuing to fight it.
            //
            // Trade-off: each screen is torn down and rebuilt when its tab
            // isn't selected, rather than staying alive underneath like
            // TabView's pages do — e.g. Collection loses its pushed detail
            // view on switching away and back. Timer is fine either way:
            // TimerHomeView already fully restores a running countdown from
            // persisted state in its own .onAppear (see resumeIfNeeded()),
            // for the widget/relaunch case, so a tab switch rebuilding it
            // hits that same path.
            Group {
                switch selectedTab {
                case .timer:
                    TimerHomeView(isActive: selectedTab == .timer, isCelebrating: $isTimerCelebrating)
                case .alarm:
                    AlarmView()
                case .collection:
                    CollectionView(
                        isShowingDetail: $isCollectionShowingDetail,
                        isScrollable: $isCollectionScrollable
                    )
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

            // Hidden during Timer's own hatching/reveal phases (full-screen
            // celebratory moments, not "the Timer screen" itself — matching
            // how the menu is already absent during the similarly
            // celebratory AlarmHatchView full-screen cover) and while a
            // dinosaur's detail view is pushed on Collection, for the same
            // "screen the kid has drilled into" reasoning.
            let hideForTimer = selectedTab == .timer && isTimerCelebrating
            let hideForCollection = selectedTab == .collection && isCollectionShowingDetail
            if !hideForTimer && !hideForCollection {
                FloatingNavMenu(selectedTab: $selectedTab, showAlarmBadge: alarmWasMissedToday(at: now))
            }
        }
        // Tints every native control in the app (pickers, toggles, date
        // pickers, ...) green instead of system blue — no longer needed to
        // match a tab bar label's color specifically (that bar is gone),
        // but still the only thing giving those controls their green
        // accent, so it stays.
        .tint(Color.dinoGreen)
        // Attached to the outer ZStack rather than the switching Group
        // above — that Group's content changes identity on every tab
        // switch, which would make these fire repeatedly (.onAppear) or
        // stop being observed (.onChange/.fullScreenCover) each time,
        // instead of behaving as "once per real app launch/foreground."
        .onAppear(perform: checkAlarmHatch)
        .onAppear(perform: refreshWidgetSnapshot)
        .onAppear(perform: checkWhatsNew)
        .onChange(of: scenePhase) { _, newPhase in
            if newPhase == .active {
                now = .now
                checkAlarmHatch()
                // Also covers the alarm's next-fire date having simply
                // passed since the last save, with no settings change to
                // key off of.
                refreshWidgetSnapshot()
            }
        }
        .onChange(of: unlocked.count) { _, _ in
            refreshWidgetSnapshot()
            checkCollectionComplete()
        }
        .onChange(of: pendingAlarmDinosaur) { _, newValue in
            // The alarm-hatch cover below can itself be what completes the
            // collection (unlock(_:) runs while it's still on screen) —
            // checkCollectionComplete() deliberately no-ops while that
            // cover is up rather than trying to stack a second
            // fullScreenCover on top of it, so re-check the instant it
            // closes to catch that case.
            if newValue == nil {
                checkCollectionComplete()
            }
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
            checkAlarmHatch()
        }
        .fullScreenCover(item: $pendingAlarmDinosaur) { dinosaur in
            AlarmHatchView(dinosaur: dinosaur) {
                unlock(dinosaur)
            } onDone: {
                pendingAlarmDinosaur = nil
            }
        }
        // Full screen rather than a sheet — see CollectionView's matching
        // change for Settings; WhatsNewView also uses the bleeding fauna
        // background.
        .fullScreenCover(isPresented: $showWhatsNew) {
            WhatsNewView(notes: whatsNewNotes)
        }
        .fullScreenCover(isPresented: $showCollectionComplete) {
            CollectionCompleteView(mascots: collectionCompleteMascots) {
                showCollectionComplete = false
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

    /// Checked on every foreground transition (and every minute tick — see
    /// `onReceive(minuteTimer)` — so a continuously-foregrounded app still
    /// catches the window closing without needing a fresh background/
    /// foreground cycle) rather than tied to the notification itself firing
    /// — the app can't run custom code exactly when a background
    /// notification delivers, so this works whether or not the kid taps the
    /// notification, and even if permission was denied. See `AlarmClaimer`.
    ///
    /// Claims either on time (`isReady`, continues the streak) or, failing
    /// that, via the catch-up window (`isCatchUpReady`) — same reward
    /// either way, but a catch-up resets the streak to 1 instead of
    /// continuing it, since the streak specifically rewards responding
    /// within the window rather than just hatching something that day.
    private func checkAlarmHatch() {
        guard pendingAlarmDinosaur == nil, let settings = alarms.first, settings.isEnabled else { return }
        let unlockedIDs = Set(unlocked.map(\.dinosaurID))

        if AlarmClaimer.isReady(
            hour: settings.hour,
            minute: settings.minute,
            weekdays: settings.repeatWeekdays,
            lastHatchDate: settings.lastHatchDate
        ) {
            settings.streakCount = AlarmStreak.nextStreak(
                currentStreak: settings.streakCount,
                lastHatchDate: settings.lastHatchDate,
                weekdays: settings.repeatWeekdays
            )
            settings.lastHatchDate = .now
            pendingAlarmDinosaur = HatchSelector.pickNext(unlockedIDs: unlockedIDs)
        }
        // Catch-up claiming temporarily disabled for testing — re-enable by
        // restoring this branch (logic untouched in `AlarmClaimer`):
        //
        // else if AlarmClaimer.isCatchUpReady(
        //     hour: settings.hour,
        //     minute: settings.minute,
        //     weekdays: settings.repeatWeekdays,
        //     lastHatchDate: settings.lastHatchDate,
        //     enabledAt: settings.enabledAt
        // ) {
        //     settings.streakCount = 1
        //     settings.lastHatchDate = .now
        //     pendingAlarmDinosaur = HatchSelector.pickNext(unlockedIDs: unlockedIDs)
        // }
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

    /// Fires the first time the *entire* catalog (regular + Secret Rare) is
    /// hatched, whether that happened via the timer or the alarm — both
    /// paths insert into the same `UnlockedDinosaur` table this view already
    /// queries, so watching `unlocked.count` catches either one without
    /// needing separate logic per path. Compares against
    /// `lastCollectionCompleteCatalogSize` (not a plain Bool) so this
    /// naturally fires again if a future catalog expansion gets fully
    /// hatched too. Deliberately skipped while `pendingAlarmDinosaur` is
    /// still showing its own fullScreenCover — see the `onChange` above.
    private func checkCollectionComplete() {
        guard pendingAlarmDinosaur == nil, let settings = appSettings.first else { return }
        let totalCatalogCount = DinosaurCatalog.all.count
        guard unlocked.count == totalCatalogCount,
              settings.lastCollectionCompleteCatalogSize != totalCatalogCount else { return }
        settings.lastCollectionCompleteCatalogSize = totalCatalogCount
        collectionCompleteMascots = mostRecentlyHatched(count: 2)
        showCollectionComplete = true
    }

    /// The dinosaurs `CollectionCompleteView` shows as its mascot pair —
    /// whichever were hatched most recently, so it naturally includes the
    /// one that just completed the set rather than a hardcoded species pair.
    private func mostRecentlyHatched(count: Int) -> [Dinosaur] {
        unlocked
            .sorted { $0.unlockedAt > $1.unlockedAt }
            .prefix(count)
            .compactMap { record in DinosaurCatalog.all.first(where: { $0.id == record.dinosaurID }) }
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
