import Foundation
import Observation

/// Drives `PlanDetailView` — owns the editable plan state and mediates updates/deletion.
///
/// Every mutation to `plan` auto-persists via `didSet`, matching the previous
/// `.onChange(of: plan)` behavior without leaking persistence concerns into the view.
@Observable
@MainActor
final class PlanDetailViewModel {
    var plan: LessonPlan {
        didSet { store.update(plan) }
    }

    private let store: PlanStore

    init(plan: LessonPlan, store: PlanStore) {
        self.plan = plan
        self.store = store
    }

    func delete() {
        store.delete(plan)
    }

    // MARK: - AI suggestion application

    func applyToPhase(index: Int, text: String) {
        guard index < plan.phases.count else { return }
        let separator = plan.phases[index].content.isEmpty ? "" : "\n\n--- AI Suggestions ---\n"
        plan.phases[index].content += separator + text
    }

    func applyToNotes(text: String) {
        let separator = plan.notes.isEmpty ? "" : "\n\n--- AI Suggestions ---\n"
        plan.notes += separator + text
    }

    // Workaround for Swift 6.2 / iOS 26.2 @Observable + @MainActor deinit bug.
    nonisolated deinit {}
}
