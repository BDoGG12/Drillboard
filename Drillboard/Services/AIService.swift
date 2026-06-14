import Foundation

// MARK: - Request / Response types

private struct AnthropicRequest: Codable {
    let model: String
    let max_tokens: Int
    let system: String
    let messages: [AnthropicMessage]
}

private struct AnthropicMessage: Codable {
    let role: String
    let content: String
}

private struct AnthropicResponse: Codable {
    let content: [AnthropicContent]
}

private struct AnthropicContent: Codable {
    let type: String
    let text: String?
}

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
            return "Received an unexpected response from the API."
        case .apiError(let msg):
            return "API error: \(msg)"
        }
    }
}

// MARK: - Service

final class AIService {
    static let shared = AIService()
    private init() {}

    static let modelID = "claude-sonnet-4-6"

    /// Structured system prompt — coaches get a scannable Title / Steps / Coaching tip block.
    private static let systemPrompt = """
    You are an expert sports coach and lesson-planning assistant. ALWAYS respond \
    in this exact structured format so coaches can scan results in seconds:

    Title: A short, vivid name for the suggestion (under 8 words).

    Steps:
    1. First step as a direct coaching instruction.
    2. Next step.
    3. Continue with 3–6 numbered steps total.

    Coaching tip: One concise sentence with the single most important thing for the coach to remember while running this.

    Keep instructions specific, level-appropriate, and safe. Avoid filler, preamble, or markdown headers — just the three labeled sections above.
    """

    /// Builds a "surprise me" prompt that asks the model to design a full creative session.
    static func surprisePrompt(for plan: LessonPlan) -> String {
        let focus = plan.focus.isEmpty ? "the discipline's fundamentals" : plan.focus
        return """
        Design a creative, memorable \(plan.durationMinutes)-minute \(plan.sport.rawValue) session \
        for \(plan.level.rawValue.lowercased()) students focused on \(focus). Surprise me — \
        include one unexpected exercise or theme that will make this lesson stand out. \
        Cover the full session arc from start to finish.
        """
    }

    func generateIdeas(plan: LessonPlan, userPrompt: String) async throws -> String {
        // TODO: DRIL-5 — once the Vercel proxy is live, point this URL at the proxy
        // and remove the direct Anthropic auth path. The proxy handles auth server-side.

        let contextPrompt = """
        Session context:
        - Sport/Discipline: \(plan.sport.rawValue)
        - Student level: \(plan.level.rawValue)
        - Session duration: \(plan.durationMinutes) minutes
        - Focus area: \(plan.focus.isEmpty ? "General skills" : plan.focus)

        Coach's request: \(userPrompt)
        """

        let body = AnthropicRequest(
            model: Self.modelID,
            max_tokens: 1000,
            system: Self.systemPrompt,
            messages: [AnthropicMessage(role: "user", content: contextPrompt)]
        )

        guard let url = URL(string: "https://api.anthropic.com/v1/messages") else {
            throw AIError.invalidResponse
        }

        var request = URLRequest(url: url)
        request.httpMethod = "POST"
        request.setValue("application/json", forHTTPHeaderField: "Content-Type")
        request.setValue("2023-06-01", forHTTPHeaderField: "anthropic-version")
        request.httpBody = try JSONEncoder().encode(body)

        do {
            let (data, response) = try await URLSession.shared.data(for: request)

            if let http = response as? HTTPURLResponse, http.statusCode != 200 {
                let msg = String(data: data, encoding: .utf8) ?? "Unknown error"
                throw AIError.apiError("HTTP \(http.statusCode): \(msg)")
            }

            let decoded = try JSONDecoder().decode(AnthropicResponse.self, from: data)
            let text = decoded.content.compactMap(\.text).joined(separator: "\n")
            guard !text.isEmpty else { throw AIError.invalidResponse }
            return text

        } catch let error as AIError {
            throw error
        } catch {
            throw AIError.networkError(error)
        }
    }
}

// MARK: - Title parsing

extension String {
    /// Pulls the `Title:` line out of a structured AI response, falling back if absent.
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
