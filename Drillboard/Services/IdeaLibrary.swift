import Foundation
import Observation

/// Persists saved AI ideas and the user's recent prompt history.
///
/// A shared `@Observable` instance backed by `UserDefaults`. Views observe it
/// via `@State private var library = IdeaLibrary.shared`.
@Observable
@MainActor
final class IdeaLibrary {
    static let shared = IdeaLibrary()

    private(set) var savedIdeas: [SavedIdea] = []
    private(set) var promptHistory: [String] = []

    private let savedKey   = "drillboard_saved_ideas_v1"
    private let historyKey = "drillboard_prompt_history_v1"
    private let maxHistory = 10

    private init() {
        load()
    }

    // MARK: - Saved ideas

    func save(_ idea: SavedIdea) {
        savedIdeas.insert(idea, at: 0)
        persistIdeas()
    }

    func remove(_ idea: SavedIdea) {
        savedIdeas.removeAll { $0.id == idea.id }
        persistIdeas()
    }

    func removeIdeas(at offsets: IndexSet) {
        for index in offsets.sorted(by: >) {
            savedIdeas.remove(at: index)
        }
        persistIdeas()
    }

    /// True if an idea with the exact same generated text is already saved.
    func contains(content: String) -> Bool {
        savedIdeas.contains { $0.content == content }
    }

    // MARK: - Prompt history

    /// Records a user-typed prompt at the front of the history, deduped, capped at `maxHistory`.
    func recordPrompt(_ prompt: String) {
        let trimmed = prompt.trimmingCharacters(in: .whitespacesAndNewlines)
        guard !trimmed.isEmpty else { return }
        promptHistory.removeAll { $0 == trimmed }
        promptHistory.insert(trimmed, at: 0)
        if promptHistory.count > maxHistory {
            promptHistory = Array(promptHistory.prefix(maxHistory))
        }
        persistHistory()
    }

    func clearHistory() {
        promptHistory.removeAll()
        persistHistory()
    }

    // MARK: - Persistence

    private func load() {
        if let data = UserDefaults.standard.data(forKey: savedKey),
           let decoded = try? JSONDecoder().decode([SavedIdea].self, from: data) {
            savedIdeas = decoded
        }
        if let arr = UserDefaults.standard.stringArray(forKey: historyKey) {
            promptHistory = arr
        }
    }

    private func persistIdeas() {
        if let data = try? JSONEncoder().encode(savedIdeas) {
            UserDefaults.standard.set(data, forKey: savedKey)
        }
    }

    private func persistHistory() {
        UserDefaults.standard.set(promptHistory, forKey: historyKey)
    }
}
