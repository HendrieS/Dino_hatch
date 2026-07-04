import XCTest
import SwiftData
@testable import DinoHatch

final class TimerEngineTests: XCTestCase {
    private func makeInMemoryContainer() -> ModelContainer {
        let schema = Schema([UnlockedDinosaur.self, AppSettings.self])
        let config = ModelConfiguration(schema: schema, isStoredInMemoryOnly: true)
        return try! ModelContainer(for: schema, configurations: [config])
    }

    func testStartSetsRunningStateAndPendingDinosaur() {
        let engine = TimerEngine()
        engine.configure(context: ModelContext(makeInMemoryContainer()))

        engine.start(duration: 60, hatching: "t-rex")

        XCTAssertTrue(engine.isRunning)
        XCTAssertEqual(engine.pendingDinosaurID, "t-rex")
        XCTAssertFalse(engine.isComplete())
    }

    func testIsCompleteOnceEndDateHasPassed() {
        let engine = TimerEngine()
        engine.configure(context: ModelContext(makeInMemoryContainer()))

        engine.start(duration: 5, hatching: "triceratops")
        let future = Date.now.addingTimeInterval(10)

        XCTAssertTrue(engine.isComplete(at: future))
        XCTAssertEqual(engine.remainingFraction(at: future), 0)
    }

    func testCancelClearsState() {
        let engine = TimerEngine()
        engine.configure(context: ModelContext(makeInMemoryContainer()))

        engine.start(duration: 60, hatching: "velociraptor")
        engine.cancel()

        XCTAssertFalse(engine.isRunning)
        XCTAssertNil(engine.pendingDinosaurID)
    }

    func testResumesAcrossFreshEngineInstanceUsingSameContext() {
        let container = makeInMemoryContainer()
        let context = ModelContext(container)

        let firstLaunch = TimerEngine()
        firstLaunch.configure(context: context)
        firstLaunch.start(duration: 120, hatching: "stegosaurus")

        // Simulates the app being killed and relaunched: a brand new engine,
        // same persisted context, should immediately resume the timer.
        let secondLaunch = TimerEngine()
        secondLaunch.configure(context: context)

        XCTAssertTrue(secondLaunch.isRunning)
        XCTAssertEqual(secondLaunch.pendingDinosaurID, "stegosaurus")
        XCTAssertEqual(secondLaunch.endDate, firstLaunch.endDate)
    }
}
