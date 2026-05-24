import Foundation
import Observation

/// Drives `SettingsView` — owns the API key field and the transient "saved" confirmation flag.
@Observable
@MainActor
final class SettingsViewModel {
    var apiKey: String
    private(set) var saved: Bool = false

    /// Display-only model identifier shown in the About section.
    let modelID: String

    private let aiService: AIService

    init() {
        let svc = AIService.shared
        self.aiService = svc
        self.apiKey = svc.apiKey
        self.modelID = AIService.modelID
    }

    func save() {
        aiService.apiKey = apiKey.trimmingCharacters(in: .whitespaces)
        saved = true
        Task {
            try? await Task.sleep(for: .seconds(1.5))
            saved = false
        }
    }
}
