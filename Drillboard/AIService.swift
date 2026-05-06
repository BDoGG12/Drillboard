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

// MARK: - Service

enum AIError: LocalizedError {
    case missingAPIKey
    case networkError(Error)
    case invalidResponse
    case apiError(String)

    var errorDescription: String? {
        switch self {
        case .missingAPIKey:
            return "API key not set. Add your Anthropic key in Settings."
        case .networkError(let e):
            return "Network error: \(e.localizedDescription)"
        case .invalidResponse:
            return "Received an unexpected response from the API."
        case .apiError(let msg):
            return "API error: \(msg)"
        }
    }
}

class AIService {
    static let shared = AIService()
    private init() {}

    static let modelID = "claude-sonnet-4-6"

    // Reads the API key from UserDefaults (set in SettingsView)
    var apiKey: String {
        get { UserDefaults.standard.string(forKey: "drillboard_api_key") ?? "" }
        set { UserDefaults.standard.set(newValue, forKey: "drillboard_api_key") }
    }

    func generateIdeas(plan: LessonPlan, userPrompt: String) async throws -> String {
        let key = apiKey.trimmingCharacters(in: .whitespaces)
        guard !key.isEmpty else { throw AIError.missingAPIKey }

        let systemPrompt = """
        You are an expert sports coach and martial arts instructor assistant. \
        You help coaches create engaging, creative, and effective lesson plans. \
        Be concise, practical, and specific. Use numbered lists or clear sections \
        when listing multiple ideas. Tailor everything to the sport and level provided.
        """

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
            system: systemPrompt,
            messages: [AnthropicMessage(role: "user", content: contextPrompt)]
        )

        guard let url = URL(string: "https://api.anthropic.com/v1/messages") else {
            throw AIError.invalidResponse
        }

        var request = URLRequest(url: url)
        request.httpMethod = "POST"
        request.setValue("application/json", forHTTPHeaderField: "Content-Type")
        request.setValue(key, forHTTPHeaderField: "x-api-key")
        request.setValue("2023-06-01", forHTTPHeaderField: "anthropic-version")
        request.httpBody = try JSONEncoder().encode(body)

        do {
            let (data, response) = try await URLSession.shared.data(for: request)

            if let http = response as? HTTPURLResponse, http.statusCode != 200 {
                let msg = String(data: data, encoding: .utf8) ?? "Unknown error"
                throw AIError.apiError("HTTP \(http.statusCode): \(msg)")
            }

            let decoded = try JSONDecoder().decode(AnthropicResponse.self, from: data)
            let text = decoded.content.compactMap { $0.text }.joined(separator: "\n")
            guard !text.isEmpty else { throw AIError.invalidResponse }
            return text

        } catch let error as AIError {
            throw error
        } catch {
            throw AIError.networkError(error)
        }
    }
}
