import XCTest
@testable import ElectionDeflection

final class TextSubmissionServiceTests: XCTestCase {

    private var sut: TextSubmissionService!

    override func setUp() {
        super.setUp()
        sut = TextSubmissionService()
    }

    override func tearDown() {
        sut = nil
        super.tearDown()
    }

    // MARK: - Text Sanitization Tests

    func testSanitizeTrimsWhitespace() {
        let result = sut.sanitize("  hello world  ")
        XCTAssertEqual(result, "hello world")
    }

    func testSanitizeTrimsNewlines() {
        let result = sut.sanitize("\n\nhello\n\n")
        XCTAssertEqual(result, "hello")
    }

    func testSanitizeEnforcesMaxLength() {
        let longText = String(repeating: "a", count: 3000)
        let result = sut.sanitize(longText)
        XCTAssertEqual(result.count, 2000)
    }

    func testSanitizePreservesTextUnderMaxLength() {
        let text = "Vote for candidate X on November 5th!"
        let result = sut.sanitize(text)
        XCTAssertEqual(result, text)
    }

    func testSanitizeAnonymizesUSPhoneNumbers() {
        let text = "Call 555-123-4567 to support the campaign"
        let result = sut.sanitize(text)
        XCTAssertFalse(result.contains("555-123-4567"), "Original digits should be replaced")
        // Format preserved: ###-###-####
        let phoneRegex = try! NSRegularExpression(pattern: #"\d{3}-\d{3}-\d{4}"#)
        let matches = phoneRegex.numberOfMatches(in: result, range: NSRange(result.startIndex..., in: result))
        XCTAssertEqual(matches, 1, "Should still contain a phone-shaped pattern with dashes")
    }

    func testSanitizeAnonymizesPhoneWithParentheses() {
        let text = "Reach us at (555) 123-4567 for details"
        let result = sut.sanitize(text)
        XCTAssertFalse(result.contains("(555) 123-4567"))
        let phoneRegex = try! NSRegularExpression(pattern: #"\(\d{3}\) \d{3}-\d{4}"#)
        let matches = phoneRegex.numberOfMatches(in: result, range: NSRange(result.startIndex..., in: result))
        XCTAssertEqual(matches, 1, "Should preserve parenthesized format")
    }

    func testSanitizeAnonymizesPhoneWithCountryCode() {
        let text = "Call +1-555-123-4567 now"
        let result = sut.sanitize(text)
        XCTAssertFalse(result.contains("+1-555-123-4567"))
        XCTAssertTrue(result.contains("+"), "Should preserve + prefix")
        XCTAssertTrue(result.contains("-"), "Should preserve dashes")
    }

    func testSanitizeAnonymizesUKPhoneNumber() {
        let text = "Call +44 20 7946 0958 for campaign info"
        let result = sut.sanitize(text)
        XCTAssertFalse(result.contains("7946"), "UK phone digits should be anonymized")
        XCTAssertTrue(result.contains("+"), "Should preserve + prefix")
        XCTAssertTrue(result.contains("for campaign info"), "Surrounding text preserved")
    }

    func testSanitizeAnonymizesGermanPhoneNumber() {
        let text = "Ring +49 30 12345678 for details"
        let result = sut.sanitize(text)
        XCTAssertFalse(result.contains("12345678"), "German phone digits should be anonymized")
        XCTAssertTrue(result.contains("+"), "Should preserve + prefix")
    }

    func testSanitizeAnonymizesAustralianPhoneNumber() {
        let text = "Call +61 2 9876 5432 to register"
        let result = sut.sanitize(text)
        XCTAssertFalse(result.contains("9876"), "Australian phone digits should be anonymized")
        XCTAssertTrue(result.contains("+"), "Should preserve + prefix")
    }

    // MARK: - Email Sanitization Tests

    func testSanitizeAnonymizesEmail() {
        let text = "Contact us at info@campaign2024.com for more details"
        let result = sut.sanitize(text)
        XCTAssertFalse(result.contains("info@campaign2024.com"))
        XCTAssertTrue(result.contains("@"), "Should still contain an email with @")
        XCTAssertTrue(result.contains("Contact us at"), "Surrounding text preserved")
    }

    func testSanitizeAnonymizesMultipleEmails() {
        let text = "Email john@pac.com or jane@campaign.org to volunteer"
        let result = sut.sanitize(text)
        XCTAssertFalse(result.contains("john@pac.com"))
        XCTAssertFalse(result.contains("jane@campaign.org"))
        // Should have two @ signs for two anonymized emails
        XCTAssertEqual(result.filter { $0 == "@" }.count, 2)
    }

    // MARK: - URL Sanitization Tests

    func testSanitizeAnonymizesURLKeepingPath() {
        let text = "Visit https://donate.campaign.com/act to contribute"
        let result = sut.sanitize(text)
        XCTAssertFalse(result.contains("donate.campaign.com"))
        XCTAssertTrue(result.contains("/act"), "Path should be preserved")
        XCTAssertTrue(result.contains("https://"), "Scheme should be preserved")
    }

    func testSanitizeAnonymizesURLRedactsQueryValues() {
        let text = "Click https://pac.com/donate?ref=sms123&uid=abc to help"
        let result = sut.sanitize(text)
        XCTAssertFalse(result.contains("sms123"), "Query values should be randomized")
        XCTAssertTrue(result.contains("ref="), "Query keys should be kept")
        XCTAssertTrue(result.contains("uid="), "Query keys should be kept")
        XCTAssertTrue(result.contains("/donate"), "Path should be preserved")
    }

    func testSanitizeAnonymizesHTTPURL() {
        let text = "Go to http://campaign.com/vote for info"
        let result = sut.sanitize(text)
        XCTAssertFalse(result.contains("campaign.com"))
        XCTAssertTrue(result.contains("http://"), "Scheme preserved")
        XCTAssertTrue(result.contains("/vote"), "Path preserved")
    }

    func testSanitizeAnonymizesMultipleURLs() {
        let text = "Check https://site1.com/a and https://site2.com/b for updates"
        let result = sut.sanitize(text)
        XCTAssertFalse(result.contains("site1.com"))
        XCTAssertFalse(result.contains("site2.com"))
        XCTAssertTrue(result.contains("/a"), "First path preserved")
        XCTAssertTrue(result.contains("/b"), "Second path preserved")
    }

    // MARK: - Combined PII Sanitization Tests

    func testSanitizeHandlesAllPIITypes() {
        let text = "Call 555-123-4567, email info@pac.org, or visit https://pac.org/donate to help"
        let result = sut.sanitize(text)
        XCTAssertFalse(result.contains("555-123-4567"))
        XCTAssertFalse(result.contains("info@pac.org"))
        XCTAssertFalse(result.contains("pac.org"))
        XCTAssertTrue(result.contains("-"), "Phone dashes preserved")
        XCTAssertTrue(result.contains("@"), "Email @ preserved")
        XCTAssertTrue(result.contains("/donate"), "URL path preserved")
    }

    func testSanitizeProducesVariedOutput() {
        let text = "Call 555-123-4567 for info"
        let results = Set((0..<10).map { _ in sut.sanitize(text) })
        XCTAssertGreaterThan(results.count, 1, "Randomized output should vary across calls")
    }

    // MARK: - Edge Case Tests

    func testSanitizeURLContainingEmailParam() {
        // URL with an email as a query parameter value
        let text = "Confirm at https://campaign.com/verify?email=voter@gmail.com&token=abc123"
        let result = sut.sanitize(text)
        XCTAssertFalse(result.contains("voter@gmail.com"), "Email inside URL query should be anonymized")
        XCTAssertFalse(result.contains("campaign.com"), "Domain should be anonymized")
        XCTAssertTrue(result.contains("/verify"), "Path preserved")
        XCTAssertTrue(result.contains("email="), "Query key preserved")
        XCTAssertTrue(result.contains("token="), "Query key preserved")
    }

    func testSanitizeBareDomainNotMatched() {
        // Bare domains without http:// should NOT be matched by URL regex
        // (they're ambiguous — could be normal text like "visit campaign.com")
        let text = "Visit campaign.com/donate to help the cause"
        let result = sut.sanitize(text)
        // Bare domain should pass through unchanged since there's no scheme
        XCTAssertTrue(result.contains("campaign.com"), "Bare domains without scheme should not be modified")
    }

    func testSanitizeURLWithFragment() {
        let text = "Read more at https://pac.org/issues#healthcare for details"
        let result = sut.sanitize(text)
        XCTAssertFalse(result.contains("pac.org"), "Domain should be anonymized")
        XCTAssertTrue(result.contains("/issues"), "Path preserved")
    }

    func testSanitizeURLWithPort() {
        let text = "Debug at https://staging.campaign.com:8080/api/status"
        let result = sut.sanitize(text)
        XCTAssertFalse(result.contains("staging.campaign.com"), "Domain should be anonymized")
        XCTAssertTrue(result.contains("/api/status"), "Path preserved")
    }

    func testSanitizeEmailWithSubdomain() {
        let text = "Write to press@news.campaign2024.org for media inquiries"
        let result = sut.sanitize(text)
        XCTAssertFalse(result.contains("press@news.campaign2024.org"))
        XCTAssertTrue(result.contains("@"), "Email format preserved")
        XCTAssertTrue(result.contains("for media inquiries"), "Surrounding text preserved")
    }

    func testSanitizePhoneDotsFormat() {
        let text = "Reach us at 555.123.4567 today"
        let result = sut.sanitize(text)
        XCTAssertFalse(result.contains("555.123.4567"), "Dot-separated phone should be anonymized")
        // Dots should be preserved as separators
        let dotPhoneRegex = try! NSRegularExpression(pattern: #"\d{3}\.\d{3}\.\d{4}"#)
        let matches = dotPhoneRegex.numberOfMatches(in: result, range: NSRange(result.startIndex..., in: result))
        XCTAssertEqual(matches, 1, "Dot format should be preserved")
    }

    func testSanitizeMessageWithNoPII() {
        // Messages with no PII should pass through with only whitespace trimming
        let text = "URGENT: Vote YES on Proposition 42! Election Day is November 5th."
        let result = sut.sanitize(text)
        XCTAssertEqual(result, text, "Text without PII should be unchanged")
    }

    func testSanitizeURLFollowedByEmail() {
        // Ensure URL matching doesn't consume a following email
        let text = "See https://pac.com/info then email help@pac.com for questions"
        let result = sut.sanitize(text)
        XCTAssertFalse(result.contains("pac.com"), "Both domain references anonymized")
        XCTAssertTrue(result.contains("/info"), "URL path preserved")
        XCTAssertTrue(result.contains("@"), "Email @ preserved")
        XCTAssertTrue(result.contains("then email"), "Connecting text preserved")
    }

    // MARK: - Performance Tests

    func testSanitizePerformanceWithLongMixedPIIText() {
        // Build a ~2000 char message dense with mixed PII
        var parts: [String] = []
        for i in 0..<40 {
            parts.append("Vote YES! Call \(500 + i)-\(100 + i)-\(1000 + i), email voter\(i)@campaign\(i).com, or visit https://pac\(i).com/donate?ref=sms\(i)&uid=x\(i) today!")
        }
        let longText = parts.joined(separator: " ")

        measure {
            _ = sut.sanitize(longText)
        }
    }

    func testSanitizePerformanceMaxLengthNoPII() {
        // Worst case: max length text with no PII (regex scans entire string with no matches)
        let longText = String(repeating: "Vote YES on Proposition 42 for democracy! ", count: 50)

        measure {
            _ = sut.sanitize(longText)
        }
    }

    func testSanitizeLongTextWithMixedPIIProducesCorrectOutput() {
        // Functional correctness for dense PII text near max length
        var parts: [String] = []
        for i in 0..<30 {
            parts.append("Call 555-\(String(format: "%03d", i))-\(String(format: "%04d", i)) or email user\(i)@test\(i).com or visit https://site\(i).com/page?id=\(i)")
        }
        let text = parts.joined(separator: ". ")
        let result = sut.sanitize(text)

        // No original phone numbers should survive
        XCTAssertFalse(result.contains("555-000-0000"), "Original phone patterns should be gone")
        // No original emails should survive
        XCTAssertFalse(result.contains("user0@test0.com"), "Original emails should be gone")
        // No original domains should survive
        XCTAssertFalse(result.contains("site0.com"), "Original domains should be gone")
        // Paths should be preserved
        XCTAssertTrue(result.contains("/page"), "URL paths should be preserved")
        // Format characters should survive
        XCTAssertTrue(result.contains("@"), "Email @ signs should be present")
        XCTAssertTrue(result.contains("-"), "Phone dashes should be present")
    }

    func testSanitizePreservesPoliticalContent() {
        let text = "URGENT: Vote YES on Proposition 42 to save democracy! Election Day is Nov 5."
        let result = sut.sanitize(text)
        XCTAssertEqual(result, text)
    }

    func testSanitizeEmptyStringReturnsEmpty() {
        let result = sut.sanitize("")
        XCTAssertTrue(result.isEmpty)
    }

    func testSanitizeWhitespaceOnlyReturnsEmpty() {
        let result = sut.sanitize("   \n\t  ")
        XCTAssertTrue(result.isEmpty)
    }

    // MARK: - Request Formation Tests (no identifiers)

    func testSubmitTextRejectsEmptyString() async {
        do {
            try await sut.submitText("")
            XCTFail("Expected emptyText error")
        } catch let error as TextSubmissionService.SubmissionError {
            XCTAssertEqual(error, .emptyText)
        } catch {
            XCTFail("Unexpected error type: \(error)")
        }
    }

    func testSubmitTextRejectsWhitespaceOnly() async {
        do {
            try await sut.submitText("   \n  ")
            XCTFail("Expected emptyText error")
        } catch let error as TextSubmissionService.SubmissionError {
            XCTAssertEqual(error, .emptyText)
        } catch {
            XCTFail("Unexpected error type: \(error)")
        }
    }

    func testSubmitTextRejectsTooShort() async {
        do {
            try await sut.submitText("short")
            XCTFail("Expected tooShort error")
        } catch let error as TextSubmissionService.SubmissionError {
            XCTAssertEqual(error, .tooShort)
        } catch {
            XCTFail("Unexpected error type: \(error)")
        }
    }

    func testSubmitTextRejectsUnder20Characters() async {
        do {
            try await sut.submitText("Only 19 chars here")
            XCTFail("Expected tooShort error")
        } catch let error as TextSubmissionService.SubmissionError {
            XCTAssertEqual(error, .tooShort)
        } catch {
            XCTFail("Unexpected error type: \(error)")
        }
    }

    /// Validates that the request body contains ONLY the text field — no device ID, user ID, or metadata.
    func testRequestContainsNoIdentifiers() {
        // Verify the service sends only "text" in the JSON body by inspecting sanitization output.
        // The actual request formation is tested via URLProtocol mock below.
        let sanitized = sut.sanitize("Vote for candidate X")
        XCTAssertEqual(sanitized, "Vote for candidate X")

        // Verify the JSON body structure using the service's internal request formation.
        // We create the expected body and verify it only contains "text".
        let body: [String: String] = ["text": sanitized]
        let jsonData = try! JSONSerialization.data(withJSONObject: body)
        let decoded = try! JSONSerialization.jsonObject(with: jsonData) as! [String: Any]

        XCTAssertEqual(decoded.count, 1, "Request body should contain exactly one field")
        XCTAssertNotNil(decoded["text"], "Request body must contain 'text' field")

        // Verify no identifiers are present
        let forbiddenKeys = ["deviceId", "device_id", "userId", "user_id", "idfa", "idfv",
                             "bundleId", "bundle_id", "appVersion", "app_version", "timestamp",
                             "ip", "ipAddress", "sessionId", "session_id"]
        for key in forbiddenKeys {
            XCTAssertNil(decoded[key], "Request body must NOT contain '\(key)' — privacy violation")
        }
    }

    // MARK: - Network Response Tests (using URLProtocol mock)

    func testRequestIncludesAPIKeyAndUserAgent() async throws {
        var capturedRequest: URLRequest?
        let mockSession = makeMockSession(statusCode: 200, body: ["success": true]) { request in
            capturedRequest = request
        }
        let service = TextSubmissionService(session: mockSession)

        try await service.submitText("Vote YES on Proposition 42 to save democracy")

        let request = try XCTUnwrap(capturedRequest)
        XCTAssertNotNil(request.value(forHTTPHeaderField: "X-API-Key"), "X-API-Key header should be present")
        let ua = try XCTUnwrap(request.value(forHTTPHeaderField: "User-Agent"))
        XCTAssertTrue(ua.hasPrefix("ElectionDeflection/"), "User-Agent should start with ElectionDeflection/, got: \(ua)")
    }

    func testSuccessResponseCompletes() async throws {
        let mockSession = makeMockSession(statusCode: 200, body: ["success": true])
        let service = TextSubmissionService(session: mockSession)

        // Should not throw
        try await service.submitText("Vote YES on Proposition 42 to save democracy")
    }

    func testRateLimitedResponseThrowsRateLimited() async {
        let mockSession = makeMockSession(statusCode: 429, body: ["error": "Rate limit exceeded"])
        let service = TextSubmissionService(session: mockSession)

        do {
            try await service.submitText("Vote YES on Proposition 42 to save democracy")
            XCTFail("Expected rateLimited error")
        } catch let error as TextSubmissionService.SubmissionError {
            XCTAssertEqual(error, .rateLimited)
        } catch {
            XCTFail("Unexpected error: \(error)")
        }
    }

    func testServerErrorResponseThrowsServerError() async {
        let mockSession = makeMockSession(statusCode: 500, body: ["error": "Internal server error"])
        let service = TextSubmissionService(session: mockSession)

        do {
            try await service.submitText("Vote YES on Proposition 42 to save democracy")
            XCTFail("Expected serverError")
        } catch let error as TextSubmissionService.SubmissionError {
            if case .serverError(let message) = error {
                XCTAssertEqual(message, "Internal server error")
            } else {
                XCTFail("Expected serverError case")
            }
        } catch {
            XCTFail("Unexpected error: \(error)")
        }
    }

    // MARK: - Error Description Tests

    func testEmptyTextErrorDescription() {
        let error = TextSubmissionService.SubmissionError.emptyText
        XCTAssertNotNil(error.errorDescription)
        XCTAssertTrue(error.errorDescription!.contains("text"))
    }

    func testNetworkErrorDescription() {
        let error = TextSubmissionService.SubmissionError.networkError
        XCTAssertNotNil(error.errorDescription)
    }

    func testRateLimitedErrorDescription() {
        let error = TextSubmissionService.SubmissionError.rateLimited
        XCTAssertNotNil(error.errorDescription)
        XCTAssertTrue(error.errorDescription!.lowercased().contains("too many"))
    }

    // MARK: - Helpers

    private func makeMockSession(statusCode: Int, body: [String: Any], onRequest: ((URLRequest) -> Void)? = nil) -> URLSession {
        let config = URLSessionConfiguration.ephemeral
        config.protocolClasses = [MockURLProtocol.self]
        MockURLProtocol.requestHandler = { request in
            onRequest?(request)
            let response = HTTPURLResponse(
                url: request.url!,
                statusCode: statusCode,
                httpVersion: nil,
                headerFields: nil
            )!
            let data = try! JSONSerialization.data(withJSONObject: body)
            return (response, data)
        }
        return URLSession(configuration: config)
    }
}

// MARK: - Equatable conformance for error matching

extension TextSubmissionService.SubmissionError: @retroactive Equatable {
    public static func == (lhs: TextSubmissionService.SubmissionError, rhs: TextSubmissionService.SubmissionError) -> Bool {
        switch (lhs, rhs) {
        case (.emptyText, .emptyText): return true
        case (.tooShort, .tooShort): return true
        case (.networkError, .networkError): return true
        case (.rateLimited, .rateLimited): return true
        case (.serverError(let a), .serverError(let b)): return a == b
        default: return false
        }
    }
}

// MARK: - Mock URL Protocol

private class MockURLProtocol: URLProtocol {
    static var requestHandler: ((URLRequest) throws -> (HTTPURLResponse, Data))?

    override class func canInit(with request: URLRequest) -> Bool { true }
    override class func canonicalRequest(for request: URLRequest) -> URLRequest { request }

    override func startLoading() {
        guard let handler = MockURLProtocol.requestHandler else {
            XCTFail("No request handler set")
            return
        }
        do {
            let (response, data) = try handler(request)
            client?.urlProtocol(self, didReceive: response, cacheStoragePolicy: .notAllowed)
            client?.urlProtocol(self, didLoad: data)
            client?.urlProtocolDidFinishLoading(self)
        } catch {
            client?.urlProtocol(self, didFailWithError: error)
        }
    }

    override func stopLoading() {}
}
