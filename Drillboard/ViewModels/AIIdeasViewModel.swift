import Foundation
import Observation
#if canImport(UIKit)
import UIKit
#endif

/// Drives `AIIdeasSheet` *and* `IdeaLibraryView`.
///
/// Owns prompt input, AI output state, loading flag, error state, and re-exposes
/// the shared `IdeaLibrary`'s saved ideas and prompt history. Views never touch
/// `AIService` or `IdeaLibrary` directly — every call goes through this VM.
@Observable
@MainActor
final class AIIdeasViewModel {
    // MARK: - Prompt input
    var promptText: String = ""

    // MARK: - Generation state
    private(set) var isLoading: Bool = false
    private(set) var generatedIdeas: String = ""
    private(set) var generatedTitle: String = ""
    private(set) var generatedPrompt: String = ""
    private(set) var generatedCategory: String?
    private(set) var savedCurrent: Bool = false

    // MARK: - Error state
    var errorMessage: String = ""
    var showingError: Bool = false

    private let aiService: AIService
    private let library: IdeaLibrary

    init() {
        self.aiService = .shared
        self.library = .shared
    }

    /// Injection init for tests — production code uses the no-arg `init()`.
    init(aiService: AIService, library: IdeaLibrary) {
        self.aiService = aiService
        self.library = library
    }

    // MARK: - Library re-exposure (read-only)

    var savedIdeas: [SavedIdea] { library.savedIdeas }
    var promptHistory: [String] { library.promptHistory }

    // MARK: - Actions

    /// One-tap "Surprise me" — builds the prompt internally so the View doesn't touch `AIService`.
    func generateSurprise(for plan: LessonPlan) async {
        await generate(plan: plan, prompt: AIService.surprisePrompt(for: plan), categoryLabel: "Surprise")
    }

    /// Generates ideas for the given plan. `categoryLabel` is non-nil for category buttons
    /// or "Surprise" — those don't get recorded in prompt history.
    func generate(plan: LessonPlan, prompt rawPrompt: String, categoryLabel: String?) async {
        let prompt = rawPrompt.trimmingCharacters(in: .whitespaces)
        guard !prompt.isEmpty else { return }

        isLoading = true
        generatedIdeas = ""
        generatedTitle = ""
        generatedPrompt = prompt
        generatedCategory = categoryLabel
        savedCurrent = false

        if categoryLabel == nil {
            library.recordPrompt(prompt)
        }

        // TODO: DRIL-5 — re-enable once Vercel proxy is live.
        // do {
        //     let response = try await aiService.generateIdeas(plan: plan, userPrompt: prompt)
        //     generatedIdeas = response
        //     generatedTitle = response.extractedIdeaTitle(fallback: categoryLabel ?? "AI Idea")
        //     savedCurrent = library.contains(content: response)
        // } catch {
        //     errorMessage = error.localizedDescription
        //     showingError = true
        // }

        isLoading = false
    }

    func saveCurrent(for plan: LessonPlan) {
        guard !generatedIdeas.isEmpty, !savedCurrent else { return }
        let idea = SavedIdea(
            title: generatedTitle.isEmpty ? "AI Idea" : generatedTitle,
            content: generatedIdeas,
            sport: plan.sport,
            level: plan.level,
            category: generatedCategory,
            promptUsed: generatedPrompt
        )
        library.save(idea)
        savedCurrent = true
    }

    func clearHistory() {
        library.clearHistory()
    }

    func removeIdeas(at offsets: IndexSet) {
        library.removeIdeas(at: offsets)
    }

    func copyOutputToPasteboard() {
        #if canImport(UIKit)
        UIPasteboard.general.string = generatedIdeas
        #endif
    }

    // Workaround for Swift 6.2 / iOS 26.2 @Observable + @MainActor deinit bug.
    nonisolated deinit {}
}
