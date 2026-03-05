import Foundation

/// Handles anonymous text submissions to the crowdsourced data endpoint.
/// Only the text content is sent — no device IDs, user IDs, or metadata.
final class TextSubmissionService {
    static let shared = TextSubmissionService()

    private let endpointURL = URL(string: "https://electiondeflection.com/api/submit")!
    private let apiKey = "ed-submit-v1-a7f3b9c2e1d4"
    private let minTextLength = 20
    private let maxTextLength = 2000
    private let session: URLSession

    private var userAgent: String {
        let version = Bundle.main.infoDictionary?["CFBundleShortVersionString"] as? String ?? "0"
        return "ElectionDeflection/\(version)"
    }

    init(session: URLSession = .shared) {
        self.session = session
    }

    /// Sanitizes text before submission: trims whitespace, enforces max length, strips phone numbers.
    func sanitize(_ text: String) -> String {
        var sanitized = text.trimmingCharacters(in: .whitespacesAndNewlines)

        // Strip phone numbers (US formats: 10-11 digits with optional separators)
        let phonePattern = #"(\+?1[-.\s]?)?\(?\d{3}\)?[-.\s]?\d{3}[-.\s]?\d{4}"#
        if let regex = try? NSRegularExpression(pattern: phonePattern) {
            sanitized = regex.stringByReplacingMatches(
                in: sanitized,
                range: NSRange(sanitized.startIndex..., in: sanitized),
                withTemplate: "[phone removed]"
            )
        }

        // Enforce max length
        if sanitized.count > maxTextLength {
            let endIndex = sanitized.index(sanitized.startIndex, offsetBy: maxTextLength)
            sanitized = String(sanitized[..<endIndex])
        }

        return sanitized
    }

    /// Submits text anonymously. Returns true on success.
    func submitText(_ text: String) async throws {
        let sanitized = sanitize(text)

        guard !sanitized.isEmpty else {
            throw SubmissionError.emptyText
        }

        guard sanitized.count >= minTextLength else {
            throw SubmissionError.tooShort
        }

        var request = URLRequest(url: endpointURL)
        request.httpMethod = "POST"
        request.setValue("application/json", forHTTPHeaderField: "Content-Type")
        request.setValue(apiKey, forHTTPHeaderField: "X-API-Key")
        request.setValue(userAgent, forHTTPHeaderField: "User-Agent")

        let body = ["text": sanitized]
        let bodyData = try JSONSerialization.data(withJSONObject: body)
        request.httpBody = bodyData

        let (data, response) = try await session.data(for: request)

        guard let httpResponse = response as? HTTPURLResponse else {
            throw SubmissionError.networkError
        }

        if httpResponse.statusCode == 429 {
            throw SubmissionError.rateLimited
        }

        guard (200...299).contains(httpResponse.statusCode) else {
            // Try to parse error message from response
            if let json = try? JSONSerialization.jsonObject(with: data) as? [String: Any],
               let errorMessage = json["error"] as? String {
                throw SubmissionError.serverError(errorMessage)
            }
            throw SubmissionError.serverError("Server returned status \(httpResponse.statusCode)")
        }
    }

    enum SubmissionError: LocalizedError {
        case emptyText
        case tooShort
        case networkError
        case rateLimited
        case serverError(String)

        var errorDescription: String? {
            switch self {
            case .emptyText:
                return "Please enter some text to submit."
            case .tooShort:
                return "Text is too short. Please submit a complete political text (at least 20 characters)."
            case .networkError:
                return "Unable to connect. Check your internet connection and try again."
            case .rateLimited:
                return "Too many submissions. Please wait an hour and try again."
            case .serverError(let message):
                return message
            }
        }
    }
}
