import Foundation

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
