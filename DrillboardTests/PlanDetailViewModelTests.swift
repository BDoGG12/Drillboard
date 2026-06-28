import XCTest
@testable import Drillboard

@MainActor
final class PlanDetailViewModelTests: XCTestCase {

    private var defaults: UserDefaults!
    private var store: PlanStore!

    override func setUp() {
        super.setUp()
        TestDefaults.reset()
        defaults = TestDefaults.make()
        store = PlanStore(defaults: defaults)
    }

    override func tearDown() {
        TestDefaults.reset()
        store = nil
        defaults = nil
        super.tearDown()
    }

    // MARK: - Update propagation

    func testEditingPlanCallsStoreUpdate() {
        var plan = LessonPlan()
        plan.title = "Before"
        store.add(plan)

        let vm = PlanDetailViewModel(plan: plan, store: store)
        vm.plan.title = "After"

        let persisted = store.plans.first { $0.id == plan.id }
        XCTAssertEqual(persisted?.title, "After")
    }

    // MARK: - Phase content writes through

    func testPhaseContentEditPersistsToStore() {
        var plan = LessonPlan()
        plan.title = "With Phases"
        store.add(plan)

        let vm = PlanDetailViewModel(plan: plan, store: store)
        vm.plan.phases[0].content = "Edited warm-up notes"

        let persisted = store.plans.first { $0.id == plan.id }
        XCTAssertEqual(persisted?.phases[0].content, "Edited warm-up notes")
    }

    // MARK: - Apply-to-phase + apply-to-notes helpers

    func testApplyToPhaseAppendsText() {
        var plan = LessonPlan()
        plan.title = "Apply target"
        store.add(plan)

        let vm = PlanDetailViewModel(plan: plan, store: store)
        vm.applyToPhase(index: 0, text: "Generated drill")

        XCTAssertTrue(vm.plan.phases[0].content.contains("Generated drill"))
    }

    func testApplyToNotesAppendsText() {
        let plan = LessonPlan()
        store.add(plan)

        let vm = PlanDetailViewModel(plan: plan, store: store)
        vm.applyToNotes(text: "Bring extra mats")

        XCTAssertTrue(vm.plan.notes.contains("Bring extra mats"))
    }
}
