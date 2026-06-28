import XCTest
@testable import Drillboard

@MainActor
final class ModelsTests: XCTestCase {

    // MARK: - LessonPlan defaults

    func testLessonPlanDefaults() {
        let plan = LessonPlan()
        XCTAssertEqual(plan.title, "Untitled Session")
        XCTAssertEqual(plan.sport, .karate)
        XCTAssertEqual(plan.level, .beginner)
        XCTAssertEqual(plan.durationMinutes, 60)
        XCTAssertEqual(plan.focus, "")
        XCTAssertEqual(plan.phases.count, 5)
        XCTAssertEqual(plan.notes, "")
    }

    // MARK: - LessonPhase defaults

    func testLessonPhaseDefaultsContainFivePhasesInOrder() {
        let phases = LessonPhase.defaults
        XCTAssertEqual(phases.count, 5)
        XCTAssertEqual(phases[0].name, "Warm-up")
        XCTAssertEqual(phases[1].name, "Technique Focus")
        XCTAssertEqual(phases[2].name, "Application / Sparring")
        XCTAssertEqual(phases[3].name, "Conditioning")
        XCTAssertEqual(phases[4].name, "Cool-down")
    }

    func testLessonPhaseDefaultDurations() {
        let phases = LessonPhase.defaults
        XCTAssertEqual(phases[0].durationMinutes, 10)
        XCTAssertEqual(phases[1].durationMinutes, 20)
        XCTAssertEqual(phases[2].durationMinutes, 15)
        XCTAssertEqual(phases[3].durationMinutes, 10)
        XCTAssertEqual(phases[4].durationMinutes, 5)
    }

    // MARK: - Subtitle

    func testLessonPlanSubtitleFormatsCorrectly() {
        var plan = LessonPlan()
        plan.sport = .karate
        plan.level = .beginner
        plan.durationMinutes = 60
        XCTAssertEqual(plan.subtitle, "Karate · Beginner · 1 hr")

        plan.durationMinutes = 45
        XCTAssertEqual(plan.subtitle, "Karate · Beginner · 45 min")

        plan.durationMinutes = 75
        plan.sport = .boxing
        plan.level = .advanced
        XCTAssertEqual(plan.subtitle, "Boxing · Advanced · 1 hr 15 min")

        plan.durationMinutes = 120
        XCTAssertEqual(plan.subtitle, "Boxing · Advanced · 2 hrs")
    }

    // MARK: - SportDiscipline emoji coverage

    func testSportDisciplineEmojiForEveryCase() {
        let expected: [SportDiscipline: String] = [
            .karate:      "🥋",
            .judo:        "🤼",
            .boxing:      "🥊",
            .wrestling:   "🤼",
            .bjj:         "🤼",
            .kickboxing:  "🥋",
            .mma:         "🥋",
            .taekwondo:   "🥋",
            .muayThai:    "🥋",
            .fitness:     "💪",
            .yoga:        "🧘",
            .football:    "🏈",
            .basketball:  "🏀",
            .soccer:      "⚽",
            .baseball:    "⚾",
            .tennis:      "🎾",
            .swimming:    "🏊",
            .gymnastics:  "🤸",
            .dance:       "🤸",
            .other:       "🏅"
        ]
        XCTAssertEqual(SportDiscipline.allCases.count, 20)
        for sport in SportDiscipline.allCases {
            XCTAssertEqual(sport.emoji, expected[sport], "Emoji mismatch for \(sport.rawValue)")
        }
    }

    // MARK: - Codable round trips

    func testLessonPlanCodableRoundTrip() throws {
        var original = LessonPlan()
        original.title = "Tactical Footwork"
        original.sport = .bjj
        original.level = .advanced
        original.durationMinutes = 90
        original.focus = "Half-guard pass"
        original.notes = "Bring kettlebells"
        original.phases[0].content = "8-minute jog"

        let data = try JSONEncoder().encode(original)
        let decoded = try JSONDecoder().decode(LessonPlan.self, from: data)

        XCTAssertEqual(decoded.id, original.id)
        XCTAssertEqual(decoded.title, original.title)
        XCTAssertEqual(decoded.sport, original.sport)
        XCTAssertEqual(decoded.level, original.level)
        XCTAssertEqual(decoded.durationMinutes, original.durationMinutes)
        XCTAssertEqual(decoded.focus, original.focus)
        XCTAssertEqual(decoded.notes, original.notes)
        XCTAssertEqual(decoded.phases.count, original.phases.count)
        XCTAssertEqual(decoded.phases[0].content, original.phases[0].content)
    }

    func testLessonPhaseCodableRoundTrip() throws {
        let original = LessonPhase(
            key: "warmup",
            name: "Warm-up",
            durationMinutes: 12,
            colorHex: "#E4A83C",
            content: "Jumping jacks then dynamic stretches",
            placeholder: "..."
        )

        let data = try JSONEncoder().encode(original)
        let decoded = try JSONDecoder().decode(LessonPhase.self, from: data)

        XCTAssertEqual(decoded, original)
    }

    // MARK: - Custom phase durations

    func testLessonPhaseStoresArbitraryDurations() {
        for minutes in [0, 7, 23, 47, 119, 359] {
            var phase = LessonPhase.defaults[0]
            phase.durationMinutes = minutes
            XCTAssertEqual(phase.durationMinutes, minutes)
        }
    }
}
