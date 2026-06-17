// AI features temporarily disabled — see DRIL-5 and DRIL-6

import Foundation

// MARK: - Errors

enum AIError: LocalizedError {
    case networkError(Error)
    case invalidResponse
    case apiError(String)

    var errorDescription: String? {
        switch self {
        case .networkError(let e):
            return "Network error: \(e.localizedDescription)"
        case .invalidResponse:
            return "Received an unexpected response from the AI service."
        case .apiError(let msg):
            return "AI error: \(msg)"
        }
    }
}

// MARK: - Service

/// Stub for the AI idea-generation service.
///
/// The production implementation will route through a Vercel proxy under DRIL-5;
/// model selection and auth happen server-side. The shape (single `generateIdeas`
/// async-throwing call) is preserved so the View Model call sites can be re-enabled
/// with a focused diff once the proxy is live.
final class AIService {
    static let shared = AIService()
    private init() {}

    /// Builds a "surprise me" prompt the proxy will hand to the model when re-enabled.
    static func surprisePrompt(for plan: LessonPlan) -> String {
        let focus = plan.focus.isEmpty ? "the discipline's fundamentals" : plan.focus
        return """
        Design a creative, memorable \(plan.durationMinutes)-minute \(plan.sport.rawValue) session \
        for \(plan.level.rawValue.lowercased()) students focused on \(focus). Surprise me — \
        include one unexpected exercise or theme that will make this lesson stand out. \
        Cover the full session arc from start to finish.
        """
    }

    /// Stubbed until the proxy is live. Always throws.
    ///
    /// Parameters are kept on the signature so DRIL-5 can drop in the real call without
    /// touching call sites. They're intentionally unused here.
    func generateIdeas(plan: LessonPlan, userPrompt: String) async throws -> String {
        _ = (plan, userPrompt)
        throw AIError.apiError("AI is temporarily disabled while the proxy is being set up — see DRIL-5.")
    }
}

// MARK: - Title parsing

extension String {
    /// Pulls the `Title:` line out of a structured AI response, falling back if absent.
    /// Kept here because the post-DRIL-5 generation pipeline will need it again.
    func extractedIdeaTitle(fallback: String) -> String {
        for raw in split(separator: "\n") {
            let line = raw.trimmingCharacters(in: .whitespaces)
            if line.lowercased().hasPrefix("title:") {
                let value = line.dropFirst("title:".count).trimmingCharacters(in: .whitespaces)
                if !value.isEmpty { return value }
            }
        }
        return fallback
    }
}
