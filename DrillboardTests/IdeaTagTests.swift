import XCTest
@testable import Drillboard

@MainActor
final class IdeaTagTests: XCTestCase {

    private func makePlan(
        sport: SportDiscipline = .karate,
        level: SkillLevel = .intermediate,
        duration: Int = 75,
        focus: String = "roundhouse kick"
    ) -> LessonPlan {
        var plan = LessonPlan()
        plan.sport = sport
        plan.level = level
        plan.durationMinutes = duration
        plan.focus = focus
        return plan
    }

    // MARK: - Cardinality

    func testReturnsExactlyTenTags() {
        let tags = IdeaTag.tags(for: makePlan())
        XCTAssertEqual(tags.count, 10)
    }

    // MARK: - Interpolation

    func testTagPromptsInterpolateSportLevelDurationAndFocus() {
        let plan = makePlan(
            sport: .boxing,
            level: .advanced,
            duration: 90,
            focus: "head movement"
        )
        let tags = IdeaTag.tags(for: plan)

        let drillHeavy = tags.first { $0.label == "Drill-heavy" }
        let partnerWork = tags.first { $0.label == "Partner work" }

        XCTAssertNotNil(drillHeavy)
        XCTAssertNotNil(partnerWork)

        XCTAssertTrue(drillHeavy?.prompt.contains("Boxing") ?? false, "Drill-heavy prompt missing sport")
        XCTAssertTrue(drillHeavy?.prompt.contains("advanced") ?? false, "Drill-heavy prompt missing level (lowercased)")
        XCTAssertTrue(drillHeavy?.prompt.contains("90") ?? false, "Drill-heavy prompt missing duration")

        XCTAssertTrue(partnerWork?.prompt.contains("Boxing") ?? false, "Partner work prompt missing sport")
        XCTAssertTrue(partnerWork?.prompt.contains("advanced") ?? false, "Partner work prompt missing level")
        XCTAssertTrue(partnerWork?.prompt.contains("head movement") ?? false, "Partner work prompt missing focus")
    }

    // MARK: - Empty focus fallbacks

    func testPartnerWorkUsesGeneralSkillsFallbackWhenFocusEmpty() {
        var plan = makePlan(focus: "")
        plan.focus = ""
        let partnerWork = IdeaTag.tags(for: plan).first { $0.label == "Partner work" }
        XCTAssertNotNil(partnerWork)
        XCTAssertTrue(
            partnerWork?.prompt.contains("general skills") ?? false,
            "Partner work should fall back to 'general skills' when focus is empty"
        )
    }

    func testSoloTechniqueUsesFundamentalsFallbackWhenFocusEmpty() {
        var plan = makePlan(focus: "")
        plan.focus = ""
        let solo = IdeaTag.tags(for: plan).first { $0.label == "Solo technique" }
        XCTAssertNotNil(solo)
        XCTAssertTrue(
            solo?.prompt.contains("fundamentals") ?? false,
            "Solo technique should fall back to 'fundamentals' when focus is empty"
        )
    }

    func testWithFocusBothPartnerWorkAndSoloTechniqueUseProvidedFocus() {
        let plan = makePlan(focus: "takedown defense")
        let tags = IdeaTag.tags(for: plan)
        let partnerWork = tags.first { $0.label == "Partner work" }
        let solo = tags.first { $0.label == "Solo technique" }
        XCTAssertTrue(partnerWork?.prompt.contains("takedown defense") ?? false)
        XCTAssertTrue(solo?.prompt.contains("takedown defense") ?? false)
        XCTAssertFalse(partnerWork?.prompt.contains("general skills") ?? true)
        XCTAssertFalse(solo?.prompt.contains("fundamentals") ?? true)
    }
}
