import SwiftUI
import SwiftData

struct RootTabView: View {
    @Environment(\.modelContext) private var modelContext
    @Environment(\.scenePhase) private var scenePhase
    @Query private var alarms: [AlarmSettings]
    @Query private var unlocked: [UnlockedDinosaur]
    @Query private var appSettings: [AppSettings]

    @State private var pendingAlarmDinosaur: Dinosaur?

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
        TabView {
            TimerHomeView()
                .tabItem {
                    Label("Timer", systemImage: "hourglass")
                }

            AlarmView()
                .tabItem {
                    Label("Alarm", systemImage: "alarm.fill")
                }

            CollectionView()
                .tabItem {
                    Label("Collection", systemImage: "book.closed.fill")
                }
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
