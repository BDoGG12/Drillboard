import Foundation

/// A bookmarked AI suggestion the coach wants to keep for later.
struct SavedIdea: Identifiable, Codable, Equatable, Hashable {
    var id: UUID = UUID()
    var title: String
    var content: String
    var sport: SportDiscipline
    var level: SkillLevel
    /// Category label if generated via the category row or Surprise Me (otherwise nil).
    var category: String?
    var promptUsed: String
    var savedAt: Date = Date()
}
