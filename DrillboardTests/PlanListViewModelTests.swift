import XCTest
@testable import Drillboard

@MainActor
final class PlanListViewModelTests: XCTestCase {

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

    private func makeViewModel() -> PlanListViewModel {
        PlanListViewModel(store: PlanStore(defaults: defaults))
    }

    // MARK: - Add

    func testPlansArrayReflectsAddedPlan() {
        let vm = makeViewModel()
        let countBefore = vm.plans.count

        var plan = LessonPlan()
        plan.title = "Test Add"
        vm.addPlan(plan)

        XCTAssertEqual(vm.plans.count, countBefore + 1)
        XCTAssertEqual(vm.plans.first?.title, "Test Add")
    }

    // MARK: - Delete

    func testPlansArrayReflectsDeletedPlan() {
        let vm = makeViewModel()
        var a = LessonPlan(); a.title = "A"
        var b = LessonPlan(); b.title = "B"
        vm.addPlan(a)
        vm.addPlan(b)
        let countBefore = vm.plans.count

        vm.deletePlans(at: IndexSet(integer: 0))

        XCTAssertEqual(vm.plans.count, countBefore - 1)
    }
}
