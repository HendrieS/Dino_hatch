import SwiftUI
import SwiftData

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
                        Label("Timer", systemImage: "hourglass")
                    }
                    .tag(Tab.timer)

                AlarmView()
                    .tabItem {
                        Label("Alarm", systemImage: "alarm.fill")
                    }
                    .tag(Tab.alarm)

                CollectionView()
                    .tabItem {
                        Label("Collection", systemImage: "book.closed.fill")
                    }
                    .tag(Tab.collection)
            }
            .onAppear(perform: checkAlarmHatch)
            .onChange(of: scenePhase) { _, newPhase in
                if newPhase == .active {
                    checkAlarmHatch()
                }
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

        settings.lastHatchDate = .now
        let unlockedIDs = Set(unlocked.map(\.dinosaurID))
        pendingAlarmDinosaur = HatchSelector.pickNext(unlockedIDs: unlockedIDs)
    }

    private func unlock(_ dinosaur: Dinosaur) {
        guard !unlocked.contains(where: { $0.dinosaurID == dinosaur.id }) else { return }
        modelContext.insert(UnlockedDinosaur(dinosaurID: dinosaur.id))
    }
}

#Preview {
    RootTabView()
        .modelContainer(for: [UnlockedDinosaur.self, AppSettings.self, AlarmSettings.self], inMemory: true)
}
