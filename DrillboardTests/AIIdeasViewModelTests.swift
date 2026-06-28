import XCTest
@testable import Drillboard

@MainActor
final class AIIdeasViewModelTests: XCTestCase {

    private var defaults: UserDefaults!
    private var library: IdeaLibrary!
    private var viewModel: AIIdeasViewModel!

    override func setUp() {
        super.setUp()
        TestDefaults.reset()
        defaults = TestDefaults.make()
        library = IdeaLibrary(defaults: defaults)
        viewModel = AIIdeasViewModel(aiService: .shared, library: library)
    }

    override func tearDown() {
        viewModel = nil
        library = nil
        defaults = nil
        TestDefaults.reset()
        super.tearDown()
    }

    // MARK: - Prompt history

    func testPromptHistoryRecordsEntries() {
        library.recordPrompt("first prompt")
        library.recordPrompt("second prompt")

        XCTAssertEqual(viewModel.promptHistory.count, 2)
        XCTAssertEqual(viewModel.promptHistory[0], "second prompt")
        XCTAssertEqual(viewModel.promptHistory[1], "first prompt")
    }

    func testPromptHistoryCapsAtTenEntries() {
        for i in 1...15 {
            library.recordPrompt("prompt \(i)")
        }
        XCTAssertEqual(viewModel.promptHistory.count, 10)
    }

    func testOldestPromptDroppedWhenExceedingCap() {
        for i in 1...12 {
            library.recordPrompt("prompt \(i)")
        }
        // Most recent is at index 0, so prompts 1 and 2 should be gone.
        XCTAssertFalse(viewModel.promptHistory.contains("prompt 1"))
        XCTAssertFalse(viewModel.promptHistory.contains("prompt 2"))
        XCTAssertTrue(viewModel.promptHistory.contains("prompt 12"))
        XCTAssertEqual(viewModel.promptHistory.first, "prompt 12")
    }

    // MARK: - Saved ideas persistence

    func testSavedIdeasPersistAcrossLibraryInstances() {
        let idea = SavedIdea(
            title: "Drill",
            content: "Three cones, line touches.",
            sport: .soccer,
            level: .intermediate,
            category: "Drills",
            promptUsed: "Suggest cone drills"
        )
        library.save(idea)
        XCTAssertEqual(viewModel.savedIdeas.count, 1)

        // Re-create the library from the same defaults — should re-load the idea.
        let reloaded = IdeaLibrary(defaults: defaults)
        XCTAssertEqual(reloaded.savedIdeas.count, 1)
        XCTAssertEqual(reloaded.savedIdeas.first?.title, "Drill")
    }

    func testClearingSavedIdeasRemovesFromUserDefaults() {
        let idea = SavedIdea(
            title: "T",
            content: "C",
            sport: .karate,
            level: .beginner,
            category: nil,
            promptUsed: ""
        )
        library.save(idea)
        XCTAssertNotNil(defaults.data(forKey: "drillboard_saved_ideas_v1"))

        library.clearSavedIdeas()

        XCTAssertEqual(viewModel.savedIdeas.count, 0)
        XCTAssertNil(defaults.data(forKey: "drillboard_saved_ideas_v1"))

        // A fresh library against the same defaults sees no saved ideas.
        let reloaded = IdeaLibrary(defaults: defaults)
        XCTAssertEqual(reloaded.savedIdeas.count, 0)
    }
}
