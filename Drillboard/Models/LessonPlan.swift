import Foundation

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
        "\(sport.rawValue) · \(level.rawValue) · \(durationMinutes.formattedAsDuration)"
    }
}
