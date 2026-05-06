import Foundation

// MARK: - Enums

enum SportDiscipline: String, CaseIterable, Codable {
    case karate = "Karate"
    case judo = "Judo"
    case boxing = "Boxing"
    case wrestling = "Wrestling"
    case bjj = "BJJ"
    case kickboxing = "Kickboxing"
    case mma = "MMA"
    case taekwondo = "Taekwondo"
    case muayThai = "Muay Thai"
    case fitness = "Fitness"
    case yoga = "Yoga"
    case football = "Football"
    case basketball = "Basketball"
    case soccer = "Soccer"
    case baseball = "Baseball"
    case tennis = "Tennis"
    case swimming = "Swimming"
    case gymnastics = "Gymnastics"
    case dance = "Dance"
    case other = "Other"

    var emoji: String {
        switch self {
        case .karate, .taekwondo, .muayThai, .kickboxing, .mma: return "🥋"
        case .judo, .wrestling, .bjj: return "🤼"
        case .boxing: return "🥊"
        case .fitness: return "💪"
        case .yoga: return "🧘"
        case .football: return "🏈"
        case .basketball: return "🏀"
        case .soccer: return "⚽"
        case .baseball: return "⚾"
        case .tennis: return "🎾"
        case .swimming: return "🏊"
        case .gymnastics, .dance: return "🤸"
        case .other: return "🏅"
        }
    }
}

enum SkillLevel: String, CaseIterable, Codable {
    case beginner = "Beginner"
    case intermediate = "Intermediate"
    case advanced = "Advanced"
    case mixed = "Mixed"

    var color: String {
        switch self {
        case .beginner: return "green"
        case .intermediate: return "blue"
        case .advanced: return "red"
        case .mixed: return "purple"
        }
    }
}

// MARK: - Lesson Phase

struct LessonPhase: Identifiable, Codable, Equatable {
    var id: UUID = UUID()
    var key: String
    var name: String
    var durationMinutes: Int
    var colorHex: String
    var content: String = ""
    var placeholder: String

    static let defaults: [LessonPhase] = [
        LessonPhase(key: "warmup",      name: "Warm-up",                durationMinutes: 10, colorHex: "#E4A83C", placeholder: "Opening stretches, light cardio, movement drills..."),
        LessonPhase(key: "technique",   name: "Technique Focus",        durationMinutes: 20, colorHex: "#378ADD", placeholder: "Main skill or technique to teach and drill..."),
        LessonPhase(key: "application", name: "Application / Sparring", durationMinutes: 15, colorHex: "#D85A30", placeholder: "Controlled practice, partner work, situational drills..."),
        LessonPhase(key: "conditioning",name: "Conditioning",           durationMinutes: 10, colorHex: "#1D9E75", placeholder: "Strength, endurance, or flexibility work..."),
        LessonPhase(key: "cooldown",    name: "Cool-down",               durationMinutes: 5, colorHex: "#888780", placeholder: "Stretching, breathing, group reflection...")
    ]
}

// MARK: - Lesson Plan

struct LessonPlan: Identifiable, Codable, Equatable {
    var id: UUID = UUID()
    var title: String = "Untitled Session"
    var sport: SportDiscipline = .karate
    var level: SkillLevel = .beginner
    var durationMinutes: Int = 60
    var focus: String = ""
    var phases: [LessonPhase] = LessonPhase.defaults
    var notes: String = ""
    var createdAt: Date = Date()
    var updatedAt: Date = Date()

    var subtitle: String {
        "\(sport.rawValue) · \(level.rawValue) · \(durationMinutes) min"
    }
}

// MARK: - AI Idea Tags

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
