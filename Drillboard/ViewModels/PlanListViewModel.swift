import Foundation
import Observation

/// Drives `ContentView` — owns the plans collection and mediates between the view and `PlanStore`.
@Observable
@MainActor
final class PlanListViewModel {
    /// The shared persistence layer. Exposed so child screens can construct their own
    /// `PlanDetailViewModel` against the same store.
    let store: PlanStore

    init() {
        self.store = PlanStore()
    }

    /// Injection init for tests — production code uses the no-arg `init()`.
    init(store: PlanStore) {
        self.store = store
    }

    /// View-facing read of the plans collection. `@Observable` tracks reads through `store`.
    var plans: [LessonPlan] { store.plans }

    func addPlan(_ plan: LessonPlan) {
        store.add(plan)
    }

    func deletePlans(at offsets: IndexSet) {
        store.delete(at: offsets)
    }

    // Workaround for Swift 6.2 / iOS 26.2 @Observable + @MainActor deinit bug.
    nonisolated deinit {}
}
