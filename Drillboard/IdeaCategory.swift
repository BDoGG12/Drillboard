import Foundation

/// Pre-built AI prompt categories that let coaches generate ideas with one tap.
enum IdeaCategory: String, CaseIterable, Identifiable {
    case warmup       = "Warm-up"
    case drills       = "Drills"
    case games        = "Games"
    case cooldown     = "Cool-down"
    case partnerWork  = "Partner Work"
    case conditioning = "Conditioning"

    var id: String { rawValue }

    var systemIcon: String {
        switch self {
        case .warmup:       return "flame"
        case .drills:       return "figure.run"
        case .games:        return "gamecontroller"
        case .cooldown:     return "leaf"
        case .partnerWork:  return "person.2"
        case .conditioning: return "dumbbell"
        }
    }

    /// Builds a fully-formed prompt tailored to the plan's sport, level, and focus.
    func prompt(for plan: LessonPlan) -> String {
        let level = plan.level.rawValue.lowercased()
        let sport = plan.sport.rawValue
        let focus = plan.focus.isEmpty ? "general skills" : plan.focus

        switch self {
        case .warmup:
            return "Design an engaging 8–12 minute warm-up routine for a \(sport) class of \(level) students. Focus area: \(focus)."
        case .drills:
            return "Give me 3 creative skill drills for \(sport) \(level) students working on \(focus). Each drill should be safe and easy to set up with minimal equipment."
        case .games:
            return "Suggest 2 fun game-based activities for \(sport) \(level) students that secretly teach \(focus)."
        case .cooldown:
            return "Recommend a calming 5-minute cool-down for a \(sport) session that helps \(level) students reflect on \(focus)."
        case .partnerWork:
            return "Describe partner drills for \(sport) at \(level) level focused on \(focus). Make pairing and rotation logistics clear."
        case .conditioning:
            return "Design a conditioning segment for a \(sport) session that builds the physical attributes needed for \(focus). Safe and progressive for \(level) students."
        }
    }
}
