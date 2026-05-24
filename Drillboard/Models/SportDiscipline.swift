import Foundation

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
