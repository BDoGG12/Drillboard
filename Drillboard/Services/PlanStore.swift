import Foundation
import Observation

/// Persists lesson plans to `UserDefaults`. Mutating methods auto-save.
@Observable
@MainActor
final class PlanStore {
    private(set) var plans: [LessonPlan] = []

    private let storageKey = "drillboard_plans_v1"

    init() {
        load()
        if plans.isEmpty {
            seedSample()
        }
    }

    func add(_ plan: LessonPlan) {
        plans.insert(plan, at: 0)
        save()
    }

    func update(_ plan: LessonPlan) {
        if let idx = plans.firstIndex(where: { $0.id == plan.id }) {
            var updated = plan
            updated.updatedAt = Date()
            plans[idx] = updated
            save()
        }
    }

    func delete(at offsets: IndexSet) {
        for index in offsets.sorted(by: >) {
            plans.remove(at: index)
        }
        save()
    }

    func delete(_ plan: LessonPlan) {
        plans.removeAll { $0.id == plan.id }
        save()
    }

    // MARK: - Persistence

    private func save() {
        if let data = try? JSONEncoder().encode(plans) {
            UserDefaults.standard.set(data, forKey: storageKey)
        }
    }

    private func load() {
        if let data = UserDefaults.standard.data(forKey: storageKey),
           let decoded = try? JSONDecoder().decode([LessonPlan].self, from: data) {
            plans = decoded
        }
    }

    private func seedSample() {
        var sample = LessonPlan()
        sample.title = "Intro Karate — First Class"
        sample.sport = .karate
        sample.level = .beginner
        sample.durationMinutes = 60
        sample.focus = "Basic stances and etiquette"
        sample.phases[0].content = "Line up, bow in. 5-min jog around the dojo. Jumping jacks x20, arm circles, hip rotations."
        sample.phases[1].content = "Teach zenkutsu-dachi (front stance). Demonstrate and walk through correct posture. Students mirror and hold for 30s each side."
        sample.phases[2].content = "Partner up — one student holds a pad, the other practices stepping into stance and throwing a straight punch x10. Switch."
        sample.phases[3].content = "Push-ups x15, squats x20, plank 30s x2. Focus on core stability."
        sample.phases[4].content = "Seated forward fold, butterfly stretch. Reflection circle: what did everyone learn today?"
        plans = [sample]
        save()
    }
}
