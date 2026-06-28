import XCTest
@testable import Drillboard

@MainActor
final class PlanStoreTests: XCTestCase {

    private var defaults: UserDefaults!

    override func setUp() {
        super.setUp()
        TestDefaults.reset()
        defaults = TestDefaults.make()
    }

    override func tearDown() {
        TestDefaults.reset()
        defaults = nil
        super.tearDown()
    }

    // MARK: - Add

    func testAddInsertsPlanAtIndexZero() {
        let store = PlanStore(defaults: defaults)
        let initialCount = store.plans.count

        var newPlan = LessonPlan()
        newPlan.title = "Newly Added"
        store.add(newPlan)

        XCTAssertEqual(store.plans.count, initialCount + 1)
        XCTAssertEqual(store.plans.first?.title, "Newly Added")
    }

    // MARK: - Update

    func testUpdatePersistsChangedFields() {
        let store = PlanStore(defaults: defaults)
        var plan = LessonPlan()
        plan.title = "Original"
        store.add(plan)

        var edited = plan
        edited.title = "Renamed"
        edited.focus = "Inside roundhouse"
        store.update(edited)

        let updated = store.plans.first { $0.id == plan.id }
        XCTAssertEqual(updated?.title, "Renamed")
        XCTAssertEqual(updated?.focus, "Inside roundhouse")
    }

    // MARK: - Delete by IndexSet

    func testDeleteAtIndexSetRemovesPlan() {
        let store = PlanStore(defaults: defaults)
        var a = LessonPlan(); a.title = "A"
        var b = LessonPlan(); b.title = "B"
        store.add(a)  // index 0
        store.add(b)  // index 0; a is now index 1
        let countBefore = store.plans.count

        store.delete(at: IndexSet(integer: 0))  // remove b
        XCTAssertEqual(store.plans.count, countBefore - 1)
        XCTAssertFalse(store.plans.contains { $0.id == b.id })
        XCTAssertTrue(store.plans.contains { $0.id == a.id })
    }

    // MARK: - Delete by reference

    func testDeleteByReferenceRemovesCorrectPlan() {
        let store = PlanStore(defaults: defaults)
        var keep = LessonPlan(); keep.title = "Keep"
        var drop = LessonPlan(); drop.title = "Drop"
        store.add(keep)
        store.add(drop)

        store.delete(drop)

        XCTAssertFalse(store.plans.contains { $0.id == drop.id })
        XCTAssertTrue(store.plans.contains { $0.id == keep.id })
    }

    // MARK: - Persistence across re-init

    func testDataPersistsAcrossReinitialization() {
        let firstStore = PlanStore(defaults: defaults)
        var plan = LessonPlan()
        plan.title = "Persisted"
        firstStore.add(plan)

        let secondStore = PlanStore(defaults: defaults)
        XCTAssertTrue(secondStore.plans.contains { $0.id == plan.id })
        XCTAssertTrue(secondStore.plans.contains { $0.title == "Persisted" })
    }

    // MARK: - Sample seed

    func testSamplePlanSeededOnEmptyStorage() {
        XCTAssertNil(defaults.data(forKey: "drillboard_plans_v1"))

        let store = PlanStore(defaults: defaults)

        XCTAssertEqual(store.plans.count, 1)
        XCTAssertEqual(store.plans[0].sport, .karate)
        XCTAssertEqual(store.plans[0].title, "Intro Karate — First Class")
    }
}
