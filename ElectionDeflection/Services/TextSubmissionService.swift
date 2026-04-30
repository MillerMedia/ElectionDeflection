import Foundation

/// Handles anonymous text submissions to the crowdsourced data endpoint.
/// Only the text content is sent — no device IDs, user IDs, or metadata.
final class TextSubmissionService {
    static let shared = TextSubmissionService()

    private let endpointURL = URL(string: "https://electiondeflection.com/api/submit")!
    private let minTextLength = 20
    private let maxTextLength = 2000
    private let session: URLSession

    private var apiKey: String {
        guard let url = Bundle.main.url(forResource: "Secrets", withExtension: "plist"),
              let data = try? Data(contentsOf: url),
              let dict = try? PropertyListSerialization.propertyList(from: data, format: nil) as? [String: Any],
              let key = dict["ED_SUBMIT_API_KEY"] as? String else {
            return ""
        }
        return key
    }

    private var userAgent: String {
        let version = Bundle.main.infoDictionary?["CFBundleShortVersionString"] as? String ?? "0"
        return "ElectionDeflection/\(version)"
    }

    init(session: URLSession = .shared) {
        self.session = session
    }

    /// Sanitizes text before submission: trims whitespace, enforces max length,
    /// anonymizes PII (phone numbers, emails, URLs) while preserving format so
    /// the training data keeps its structural patterns without leaking personal info.
    func sanitize(_ text: String) -> String {
        var sanitized = text.trimmingCharacters(in: .whitespacesAndNewlines)

        // Anonymize URLs: keep scheme + path structure, replace domain, redact query values
        sanitized = anonymizeURLs(in: sanitized)

        // Anonymize email addresses with randomized but realistic-looking replacements
        sanitized = anonymizeEmails(in: sanitized)

        // Anonymize phone numbers: replace digits with 0, keep separators/format
        sanitized = anonymizePhoneNumbers(in: sanitized)

        // Enforce max length
        if sanitized.count > maxTextLength {
            let endIndex = sanitized.index(sanitized.startIndex, offsetBy: maxTextLength)
            sanitized = String(sanitized[..<endIndex])
        }

        return sanitized
    }

    /// Replaces digits in phone number matches with random digits, preserving separators and format.
    private func anonymizePhoneNumbers(in text: String) -> String {
        var result = text
        let phonePatterns = [
            #"\+\d{1,3}[-.\s]?\(?\d{1,4}\)?[-.\s]?\d{1,4}[-.\s]?\d{1,4}[-.\s]?\d{0,4}"#,
            #"(\+?1[-.\s]?)?\(?\d{3}\)?[-.\s]?\d{3}[-.\s]?\d{4}"#,
        ]
        let combinedPattern = phonePatterns.joined(separator: "|")
        guard let regex = try? NSRegularExpression(pattern: combinedPattern) else { return result }

        let matches = regex.matches(in: result, range: NSRange(result.startIndex..., in: result))
        for match in matches.reversed() {
            guard let range = Range(match.range, in: result) else { continue }
            let phone = String(result[range])
            let anonymized = String(phone.map { char -> Character in
                char.isNumber ? Character(String(Int.random(in: 0...9))) : char
            })
            result.replaceSubrange(range, with: anonymized)
        }
        return result
    }

    /// Anonymizes emails: replaces with random user/domain while keeping the @ format.
    private func anonymizeEmails(in text: String) -> String {
        var result = text
        guard let emailRegex = try? NSRegularExpression(
            pattern: #"[A-Za-z0-9._%+\-]+@[A-Za-z0-9.\-]+\.[A-Za-z]{2,}"#
        ) else { return result }

        let matches = emailRegex.matches(in: result, range: NSRange(result.startIndex..., in: result))
        let users = ["user", "info", "contact", "hello", "support", "admin", "team", "mail"]
        let domains = ["example.com", "sample.org", "test.net", "demo.com", "mail.org"]

        for match in matches.reversed() {
            guard let range = Range(match.range, in: result) else { continue }
            let randomEmail = "\(users.randomElement()!)\(Int.random(in: 10...99))@\(domains.randomElement()!)"
            result.replaceSubrange(range, with: randomEmail)
        }
        return result
    }

    /// Anonymizes URLs: replaces domain with random domain, keeps path, randomizes query param values.
    private func anonymizeURLs(in text: String) -> String {
        var result = text
        guard let urlRegex = try? NSRegularExpression(
            pattern: #"https?://[^\s<>\"\')}\]]+"#,
            options: .caseInsensitive
        ) else { return result }

        let matches = urlRegex.matches(in: result, range: NSRange(result.startIndex..., in: result))
        for match in matches.reversed() {
            guard let range = Range(match.range, in: result) else { continue }
            let urlString = String(result[range])

            if let components = URLComponents(string: urlString) {
                var anonymized = URLComponents()
                anonymized.scheme = components.scheme
                let randomDomains = ["example.com", "sample.org", "test.net", "demo.com", "site.org"]
                anonymized.host = randomDomains.randomElement()!
                anonymized.path = components.path

                // Keep query param keys but replace values with random strings
                if let queryItems = components.queryItems, !queryItems.isEmpty {
                    anonymized.queryItems = queryItems.map {
                        URLQueryItem(name: $0.name, value: randomAlphanumeric(length: min(max(($0.value ?? "").count, 3), 8)))
                    }
                }

                if let anonymizedURL = anonymized.string {
                    result.replaceSubrange(range, with: anonymizedURL)
                }
            } else {
                // Fallback if URL can't be parsed
                result.replaceSubrange(range, with: "[URL]")
            }
        }
        return result
    }

    private func randomAlphanumeric(length: Int) -> String {
        let chars = "abcdefghijklmnopqrstuvwxyz0123456789"
        return String((0..<length).map { _ in chars.randomElement()! })
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
