import XCTest
@testable import Drillboard

@MainActor
final class SessionTimerViewModelTests: XCTestCase {

    private func makePlan() -> LessonPlan {
        var plan = LessonPlan()
        plan.title = "Test Session"
        // Defaults already give us 5 phases with non-zero durations:
        // 10, 20, 15, 10, 5 minutes.
        return plan
    }

    // MARK: - Initialization

    func testInitializesWithPhaseCountAndFirstPhaseDuration() {
        let plan = makePlan()
        let vm = SessionTimerViewModel(plan: plan)

        XCTAssertEqual(vm.plan.phases.count, 5)
        XCTAssertEqual(vm.currentPhaseIndex, 0)
        XCTAssertEqual(vm.secondsRemaining, plan.phases[0].durationMinutes * 60)
        XCTAssertFalse(vm.isPaused)
        XCTAssertFalse(vm.isComplete)
        XCTAssertEqual(vm.totalSecondsElapsed, 0)
    }

    // MARK: - Skip forward

    func testSkipToNextIncrementsPhaseIndex() {
        let plan = makePlan()
        let vm = SessionTimerViewModel(plan: plan)
        vm.start()
        defer { vm.cancel() }

        let before = vm.currentPhaseIndex
        vm.skipToNext()
        XCTAssertEqual(vm.currentPhaseIndex, before + 1)
    }

    func testSkipToNextOnLastPhaseSetsIsComplete() {
        let plan = makePlan()
        let vm = SessionTimerViewModel(plan: plan)
        vm.start()
        defer { vm.cancel() }

        // Skip through every phase boundary except the last hand-off.
        for _ in 0..<(plan.phases.count - 1) {
            vm.skipToNext()
        }
        XCTAssertFalse(vm.isComplete, "Should not be complete until skipping the last phase")
        XCTAssertEqual(vm.currentPhaseIndex, plan.phases.count - 1)

        vm.skipToNext()
        XCTAssertTrue(vm.isComplete)
    }

    // MARK: - Go back

    func testGoBackDecrementsPhaseIndex() {
        let plan = makePlan()
        let vm = SessionTimerViewModel(plan: plan)
        vm.start()
        defer { vm.cancel() }

        vm.skipToNext()
        XCTAssertEqual(vm.currentPhaseIndex, 1)

        vm.goBack()
        XCTAssertEqual(vm.currentPhaseIndex, 0)
    }

    func testGoBackOnFirstPhaseDoesNotMovePastZero() {
        let plan = makePlan()
        let vm = SessionTimerViewModel(plan: plan)
        vm.start()
        defer { vm.cancel() }

        XCTAssertEqual(vm.currentPhaseIndex, 0)
        vm.goBack()
        XCTAssertEqual(vm.currentPhaseIndex, 0)
    }

    // MARK: - Pause / resume

    func testPauseSetsIsPausedTrue() {
        let plan = makePlan()
        let vm = SessionTimerViewModel(plan: plan)
        vm.start()
        defer { vm.cancel() }

        vm.pause()
        XCTAssertTrue(vm.isPaused)
    }

    func testResumeSetsIsPausedFalse() {
        let plan = makePlan()
        let vm = SessionTimerViewModel(plan: plan)
        vm.start()
        defer { vm.cancel() }

        vm.pause()
        XCTAssertTrue(vm.isPaused)

        vm.resume()
        XCTAssertFalse(vm.isPaused)
    }

    // MARK: - Restart

    func testRestartResetsState() {
        let plan = makePlan()
        let vm = SessionTimerViewModel(plan: plan)
        vm.start()
        defer { vm.cancel() }

        // Drive forward to a non-trivial state.
        vm.skipToNext()
        vm.skipToNext()
        XCTAssertEqual(vm.currentPhaseIndex, 2)

        // Now force completion, then restart.
        for _ in 0..<(plan.phases.count - vm.currentPhaseIndex) {
            vm.skipToNext()
        }
        XCTAssertTrue(vm.isComplete)

        vm.restart()

        XCTAssertEqual(vm.currentPhaseIndex, 0)
        XCTAssertFalse(vm.isComplete)
        XCTAssertEqual(vm.secondsRemaining, plan.phases[0].durationMinutes * 60)
    }
}
