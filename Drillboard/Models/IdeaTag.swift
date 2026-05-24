import Foundation

struct IdeaTag: Identifiable {
    let id = UUID()
    let label: String
    let prompt: String
}

extension IdeaTag {
    static func tags(for plan: LessonPlan) -> [IdeaTag] {
        [
            IdeaTag(label: "Drill-heavy",        prompt: "Give me 3 creative drill-heavy exercises for \(plan.sport.rawValue) \(plan.level.rawValue.lowercased()) students in a \(plan.durationMinutes)-min session."),
            IdeaTag(label: "Games & fun",         prompt: "Suggest 2-3 fun game-based activities for \(plan.sport.rawValue) \(plan.level.rawValue.lowercased()) students that teach real skills."),
            IdeaTag(label: "Partner work",        prompt: "Describe engaging partner drills for \(plan.sport.rawValue) at \(plan.level.rawValue.lowercased()) level focused on \(plan.focus.isEmpty ? "general skills" : plan.focus)."),
            IdeaTag(label: "Solo technique",      prompt: "Give me solo technique exercises for a \(plan.sport.rawValue) student working on \(plan.focus.isEmpty ? "fundamentals" : plan.focus)."),
            IdeaTag(label: "Footwork",            prompt: "Suggest creative footwork and movement drills appropriate for \(plan.sport.rawValue) \(plan.level.rawValue.lowercased()) students."),
            IdeaTag(label: "Mental focus",        prompt: "Recommend mindfulness and mental focus activities to incorporate in a \(plan.sport.rawValue) class."),
            IdeaTag(label: "Competition prep",    prompt: "What competition preparation drills and mindset exercises work well for \(plan.sport.rawValue) \(plan.level.rawValue.lowercased()) students?"),
            IdeaTag(label: "High intensity",      prompt: "Design a high-intensity segment for a \(plan.sport.rawValue) session that is safe for \(plan.level.rawValue.lowercased()) students."),
            IdeaTag(label: "Warm-up ideas",       prompt: "Give me 3 memorable and unique warm-up routines for a \(plan.sport.rawValue) class of \(plan.level.rawValue.lowercased()) students."),
            IdeaTag(label: "Cool-down ideas",     prompt: "Suggest calming and reflective cool-down activities for a \(plan.sport.rawValue) session that help students absorb what they learned.")
        ]
    }
}
