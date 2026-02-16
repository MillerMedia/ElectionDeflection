import XCTest
@testable import ElectionDeflection

final class SharedDataManagerTests: XCTestCase {

    private var sut: SharedDataManager!
    private var testDefaults: UserDefaults!
    private let testSuiteName = "com.test.sharedDataManager"

    override func setUp() {
        super.setUp()
        testDefaults = UserDefaults(suiteName: testSuiteName)
        testDefaults.removePersistentDomain(forName: testSuiteName)
        sut = SharedDataManager(defaults: testDefaults)
    }

    override func tearDown() {
        testDefaults.removePersistentDomain(forName: testSuiteName)
        testDefaults = nil
        sut = nil
        super.tearDown()
    }

    // MARK: - Onboarding State Tests

    func testHasCompletedOnboardingDefaultsToFalse() {
        XCTAssertFalse(sut.hasCompletedOnboarding)
    }

    func testSetHasCompletedOnboarding() {
        sut.hasCompletedOnboarding = true
        XCTAssertTrue(sut.hasCompletedOnboarding)
    }

    func testHasCompletedOnboardingPersistsAcrossInstances() {
        sut.hasCompletedOnboarding = true
        let secondInstance = SharedDataManager(defaults: testDefaults)
        XCTAssertTrue(secondInstance.hasCompletedOnboarding)
    }

    // MARK: - Filter Enabled Tests

    func testFilterEnabledDefaultsToTrue() {
        XCTAssertTrue(sut.isFilterEnabled)
    }

    func testSetFilterEnabled() {
        sut.isFilterEnabled = false
        XCTAssertFalse(sut.isFilterEnabled)

        sut.isFilterEnabled = true
        XCTAssertTrue(sut.isFilterEnabled)
    }

    // MARK: - Pro Tier Tests

    func testProTierDefaultsToFalse() {
        XCTAssertFalse(sut.isProTier)
    }

    func testSetProTier() {
        sut.isProTier = true
        XCTAssertTrue(sut.isProTier)
    }

    // MARK: - ML Model Enabled Tests

    func testMLModelEnabledDefaultsToTrue() {
        XCTAssertTrue(sut.isMLModelEnabled)
    }

    func testSetMLModelEnabled() {
        sut.isMLModelEnabled = true
        XCTAssertTrue(sut.isMLModelEnabled)
    }

    // MARK: - Texts Blocked Count Tests

    func testTextsBlockedCountDefaultsToZero() {
        XCTAssertEqual(sut.textsBlockedCount, 0)
    }

    func testSetTextsBlockedCount() {
        sut.textsBlockedCount = 42
        XCTAssertEqual(sut.textsBlockedCount, 42)
    }

    func testIncrementTextsBlockedCount() {
        XCTAssertEqual(sut.textsBlockedCount, 0)
        sut.incrementTextsBlockedCount()
        XCTAssertEqual(sut.textsBlockedCount, 1)
        sut.incrementTextsBlockedCount()
        XCTAssertEqual(sut.textsBlockedCount, 2)
    }

    // MARK: - Filter Method Tests

    func testFilterMethodDefaultsToKeyword() {
        XCTAssertEqual(sut.filterMethod, SharedConstants.filterMethodKeyword,
                       "Default filter method should be 'keyword' (Pro tier required for ML)")
    }

    func testSetFilterMethod() {
        sut.filterMethod = SharedConstants.filterMethodML
        XCTAssertEqual(sut.filterMethod, SharedConstants.filterMethodML)
    }

    // MARK: - V1 Purchaser Tests

    func testV1PurchaserDefaultsToFalse() {
        XCTAssertFalse(sut.isV1Purchaser)
    }

    func testSetV1Purchaser() {
        sut.isV1Purchaser = true
        XCTAssertTrue(sut.isV1Purchaser)
    }

    // MARK: - Keyword List Tests

    func testKeywordListDefaultsToEmpty() {
        XCTAssertEqual(sut.keywordList, [])
    }

    func testSetKeywordList() {
        let keywords = ["trump", "election", "vote"]
        sut.keywordList = keywords
        XCTAssertEqual(sut.keywordList, keywords)
    }

    // MARK: - Data Persistence Tests

    func testDataPersistsAcrossInstances() {
        sut.isProTier = true
        sut.textsBlockedCount = 100
        sut.filterMethod = SharedConstants.filterMethodML

        let secondInstance = SharedDataManager(defaults: testDefaults)
        XCTAssertTrue(secondInstance.isProTier)
        XCTAssertEqual(secondInstance.textsBlockedCount, 100)
        XCTAssertEqual(secondInstance.filterMethod, SharedConstants.filterMethodML)
    }

    // MARK: - App Groups Container Tests

    func testSharedContainerURL() {
        // sharedContainerURL uses the real App Group identifier via FileManager;
        // in the simulator (hosted by the app target) this resolves to a valid path.
        let url = sut.sharedContainerURL
        XCTAssertNotNil(url, "sharedContainerURL should resolve to a valid path in the simulator")
    }

    // MARK: - Safe Defaults (No Data Seeded) Tests

    func testDefaultValuesWhenNoDataSeeded() {
        // Verify all properties return safe, non-crashing defaults on a fresh UserDefaults
        XCTAssertTrue(sut.isFilterEnabled, "Filter should be enabled by default")
        XCTAssertFalse(sut.isProTier, "Pro tier should be off by default")
        XCTAssertTrue(sut.isMLModelEnabled, "ML model should be enabled by default (ships with working model)")
        XCTAssertEqual(sut.textsBlockedCount, 0, "Texts blocked should be 0 by default")
        XCTAssertFalse(sut.isV1Purchaser, "V1 purchaser should be false by default")
        XCTAssertFalse(sut.hasCompletedOnboarding, "Onboarding should not be completed by default")
        XCTAssertEqual(sut.keywordList, [], "Keyword list should be empty by default")
        XCTAssertEqual(sut.whitelistContexts, [:], "Whitelist contexts should be empty by default")
        XCTAssertEqual(sut.combinedTerms, [], "Combined terms should be empty by default")
        // filterMethod has a default from SharedConstants — it should not be empty or crash
        XCTAssertFalse(sut.filterMethod.isEmpty, "Filter method should have a non-empty default")
    }

    // MARK: - Shared Constants Tests

    func testAppGroupIdentifier() {
        XCTAssertEqual(SharedConstants.appGroupIdentifier, "group.com.millermedia.electiondeflection")
    }

    func testDefaultValues() {
        XCTAssertTrue(SharedConstants.defaultFilterEnabled)
        XCTAssertFalse(SharedConstants.defaultProTierStatus)
        XCTAssertTrue(SharedConstants.defaultMLModelEnabled)
        XCTAssertEqual(SharedConstants.defaultTextsBlockedCount, 0)
        XCTAssertEqual(SharedConstants.defaultFilterMethod, SharedConstants.filterMethodKeyword)
        XCTAssertFalse(SharedConstants.defaultIsV1Purchaser)
        XCTAssertFalse(SharedConstants.defaultHasCompletedOnboarding)
    }

    // MARK: - ML Model Enabled Edge Cases (Story 3.6)

    func testMLModelEnabledCanBeSetToFalse() {
        sut.isMLModelEnabled = false
        XCTAssertFalse(sut.isMLModelEnabled, "ML model enabled should be settable to false")
    }

    func testMLModelEnabledPersistsAcrossInstances() {
        sut.isMLModelEnabled = false
        let secondInstance = SharedDataManager(defaults: testDefaults)
        XCTAssertFalse(secondInstance.isMLModelEnabled, "ML model disabled state should persist across instances")
    }

    // MARK: - Filter Method Edge Cases (Story 3.6)

    func testFilterMethodCanBeSetToKeyword() {
        sut.filterMethod = SharedConstants.filterMethodKeyword
        XCTAssertEqual(sut.filterMethod, SharedConstants.filterMethodKeyword,
                       "Filter method should be settable to 'keyword'")
    }

    func testFilterMethodKeywordPersistsAcrossInstances() {
        sut.filterMethod = SharedConstants.filterMethodKeyword
        let secondInstance = SharedDataManager(defaults: testDefaults)
        XCTAssertEqual(secondInstance.filterMethod, SharedConstants.filterMethodKeyword,
                       "Keyword filter method should persist across instances")
    }

    // MARK: - ML Model Validator Tests (Story 3.6)

    func testMLModelValidatorSuccessPath() {
        // Note: This test relies on Bundle.main resolving to the host app bundle (which contains
        // PoliticalTextClassifier.mlmodelc). This coupling is acceptable because:
        // 1. The model must be in the app bundle for the feature to work — this validates that
        // 2. The failure path is tested independently with a bundle that lacks the model
        let result = MLModelValidator.isMLModelAvailable(in: Bundle.main)
        XCTAssertTrue(result, "ML model should be loadable from the main app bundle")
    }

    func testMLModelValidatorFailurePathMissingModel() {
        // Use the test bundle which does NOT contain PoliticalTextClassifier.mlmodelc
        let testBundle = Bundle(for: SharedDataManagerTests.self)
        let result = MLModelValidator.isMLModelAvailable(in: testBundle)
        XCTAssertFalse(result, "ML model should not be found in test bundle")
    }

    func testMLModelValidatorSyncSetsMLEnabledForProTier() {
        // Pro tier + model available → ML enabled
        sut.isProTier = true
        MLModelValidator.validateAndSync(using: sut, in: Bundle.main)
        XCTAssertTrue(sut.isMLModelEnabled, "isMLModelEnabled should be true when Pro tier and model loads")
        XCTAssertEqual(sut.filterMethod, SharedConstants.filterMethodML,
                       "filterMethod should be 'ml' when Pro tier and model loads")
    }

    func testMLModelValidatorSyncSetsKeywordForFreeTier() {
        // Free tier + model available → keyword only (Pro tier gates ML)
        sut.isProTier = false
        MLModelValidator.validateAndSync(using: sut, in: Bundle.main)
        XCTAssertFalse(sut.isMLModelEnabled, "isMLModelEnabled should be false for Free tier even if model loads")
        XCTAssertEqual(sut.filterMethod, SharedConstants.filterMethodKeyword,
                       "filterMethod should be 'keyword' for Free tier users")
    }

    func testMLModelValidatorSyncSetsKeywordFallback() {
        // Pro tier + model unavailable → keyword fallback
        sut.isProTier = true
        let testBundle = Bundle(for: SharedDataManagerTests.self)
        MLModelValidator.validateAndSync(using: sut, in: testBundle)
        XCTAssertFalse(sut.isMLModelEnabled, "isMLModelEnabled should be false when model fails to load")
        XCTAssertEqual(sut.filterMethod, SharedConstants.filterMethodKeyword,
                       "filterMethod should be 'keyword' when model fails to load")
    }

    func testMLModelValidatorSyncFreeTierModelUnavailable() {
        // Free tier + model unavailable → keyword (double reason)
        sut.isProTier = false
        let testBundle = Bundle(for: SharedDataManagerTests.self)
        MLModelValidator.validateAndSync(using: sut, in: testBundle)
        XCTAssertFalse(sut.isMLModelEnabled, "isMLModelEnabled should be false for Free tier without model")
        XCTAssertEqual(sut.filterMethod, SharedConstants.filterMethodKeyword,
                       "filterMethod should be 'keyword' for Free tier without model")
    }

    // MARK: - Upgrade Prompt Tests (Story 4.5)

    func testOnboardingCompletedDateDefaultsToNil() {
        XCTAssertNil(sut.onboardingCompletedDate)
    }

    func testOnboardingCompletedDateRoundTrip() {
        let date = Date()
        sut.onboardingCompletedDate = date
        // Compare with 1-second tolerance (UserDefaults loses sub-second precision)
        XCTAssertNotNil(sut.onboardingCompletedDate)
        XCTAssertEqual(sut.onboardingCompletedDate!.timeIntervalSince1970, date.timeIntervalSince1970, accuracy: 1.0)
    }

    func testOnboardingCompletedDatePersists() {
        let date = Date()
        sut.onboardingCompletedDate = date
        let secondInstance = SharedDataManager(defaults: testDefaults)
        XCTAssertNotNil(secondInstance.onboardingCompletedDate)
    }

    func testHasSeenUpgradePromptDefaultsToFalse() {
        XCTAssertFalse(sut.hasSeenUpgradePrompt)
    }

    func testHasSeenUpgradePromptPersists() {
        sut.hasSeenUpgradePrompt = true
        let secondInstance = SharedDataManager(defaults: testDefaults)
        XCTAssertTrue(secondInstance.hasSeenUpgradePrompt)
    }

    func testUpgradePromptNotShownBeforeDelay() {
        // Free tier, onboarding completed today, not seen
        sut.isProTier = false
        sut.hasSeenUpgradePrompt = false
        sut.onboardingCompletedDate = Date() // today
        let daysSince = Calendar.current.dateComponents([.day], from: sut.onboardingCompletedDate!, to: Date()).day ?? 0
        let shouldShow = !sut.isProTier
            && daysSince >= SharedConstants.upgradePromptDelayDays
            && !sut.hasSeenUpgradePrompt
        XCTAssertFalse(shouldShow, "Prompt should not show before delay period")
    }

    func testUpgradePromptShownAfterDelay() {
        // Free tier, onboarding completed 4 days ago, not seen
        sut.isProTier = false
        sut.hasSeenUpgradePrompt = false
        sut.onboardingCompletedDate = Calendar.current.date(byAdding: .day, value: -4, to: Date())
        let daysSince = Calendar.current.dateComponents([.day], from: sut.onboardingCompletedDate!, to: Date()).day ?? 0
        let shouldShow = !sut.isProTier
            && daysSince >= SharedConstants.upgradePromptDelayDays
            && !sut.hasSeenUpgradePrompt
        XCTAssertTrue(shouldShow, "Prompt should show after delay period for Free tier")
    }

    func testUpgradePromptNotShownWhenAlreadySeen() {
        sut.isProTier = false
        sut.hasSeenUpgradePrompt = true
        sut.onboardingCompletedDate = Calendar.current.date(byAdding: .day, value: -4, to: Date())
        let daysSince = Calendar.current.dateComponents([.day], from: sut.onboardingCompletedDate!, to: Date()).day ?? 0
        let shouldShow = !sut.isProTier
            && daysSince >= SharedConstants.upgradePromptDelayDays
            && !sut.hasSeenUpgradePrompt
        XCTAssertFalse(shouldShow, "Prompt should not show when already seen")
    }

    func testUpgradePromptNotShownForProTier() {
        sut.isProTier = true
        sut.hasSeenUpgradePrompt = false
        sut.onboardingCompletedDate = Calendar.current.date(byAdding: .day, value: -4, to: Date())
        let daysSince = Calendar.current.dateComponents([.day], from: sut.onboardingCompletedDate!, to: Date()).day ?? 0
        let shouldShow = !sut.isProTier
            && daysSince >= SharedConstants.upgradePromptDelayDays
            && !sut.hasSeenUpgradePrompt
        XCTAssertFalse(shouldShow, "Prompt should not show for Pro tier users")
    }

    func testUpgradePromptNotShownWithoutOnboardingDate() {
        sut.isProTier = false
        sut.hasSeenUpgradePrompt = false
        // onboardingCompletedDate is nil
        let shouldShow = sut.onboardingCompletedDate != nil
            && !sut.isProTier
            && !sut.hasSeenUpgradePrompt
        XCTAssertFalse(shouldShow, "Prompt should not show without onboarding date")
    }

    func testUpgradePromptDelayDays() {
        XCTAssertEqual(SharedConstants.upgradePromptDelayDays, 3,
                       "Upgrade prompt delay should be 3 days")
    }

    // MARK: - Zero Network Guardrail Tests (Story 1.7)

    func testNoNetworkingCodeInSourceFiles() {
        // Guardrail: If any developer adds networking code, this test fails.
        // Validates FR9 (zero network dependency) and NFR-SEC1 (zero network requests).
        let projectRoot = URL(fileURLWithPath: #filePath)
            .deletingLastPathComponent()  // ElectionDeflectionTests/
            .deletingLastPathComponent()  // project root

        let directoriesToScan = [
            projectRoot.appendingPathComponent("Shared"),
            projectRoot.appendingPathComponent("ElectionDeflectionFilter"),
            projectRoot.appendingPathComponent("ElectionDeflection")
        ]

        let forbiddenPatterns = [
            "URLSession",
            "URLRequest",
            "URLComponents",
            "HTTPURLResponse",
            "import Network\n",
            "import Network ",
            "import CFNetwork",
            "ILNetworkResponse"
        ]

        let fileManager = FileManager.default
        var violations: [String] = []

        for directory in directoriesToScan {
            guard let enumerator = fileManager.enumerator(at: directory, includingPropertiesForKeys: nil) else {
                continue
            }

            while let fileURL = enumerator.nextObject() as? URL {
                guard fileURL.pathExtension == "swift" else { continue }

                guard let contents = try? String(contentsOf: fileURL, encoding: .utf8) else { continue }

                for pattern in forbiddenPatterns {
                    if contents.contains(pattern) {
                        let relativePath = fileURL.path.replacingOccurrences(of: projectRoot.path + "/", with: "")
                        violations.append("\(relativePath) contains '\(pattern.trimmingCharacters(in: .whitespacesAndNewlines))'")
                    }
                }
            }
        }

        XCTAssertTrue(violations.isEmpty,
            "Zero-network policy violated (FR9, NFR-SEC1). Found networking code:\n" +
            violations.joined(separator: "\n"))
    }
}
