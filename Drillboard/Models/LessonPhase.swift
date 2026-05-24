import Foundation

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
