import XCTest
@testable import ElectionDeflection

@MainActor
final class ReviewRequestManagerTests: XCTestCase {

    private var defaults: UserDefaults!
    private var manager: ReviewRequestManager!

    override func setUp() {
        super.setUp()
        defaults = UserDefaults(suiteName: "ReviewRequestManagerTests")!
        defaults.removePersistentDomain(forName: "ReviewRequestManagerTests")
        manager = ReviewRequestManager(defaults: defaults)
    }

    override func tearDown() {
        defaults.removePersistentDomain(forName: "ReviewRequestManagerTests")
        super.tearDown()
    }

    // MARK: - Launch Tracking

    func testRecordLaunchIncrementsCount() {
        XCTAssertEqual(defaults.integer(forKey: SharedConstants.appLaunchCountKey), 0)
        manager.recordLaunch()
        XCTAssertEqual(defaults.integer(forKey: SharedConstants.appLaunchCountKey), 1)
        manager.recordLaunch()
        XCTAssertEqual(defaults.integer(forKey: SharedConstants.appLaunchCountKey), 2)
    }

    func testRecordLaunchSetsFirstLaunchDateOnce() {
        XCTAssertNil(defaults.object(forKey: SharedConstants.firstLaunchDateKey))
        manager.recordLaunch()
        let firstDate = defaults.object(forKey: SharedConstants.firstLaunchDateKey) as? Date
        XCTAssertNotNil(firstDate)

        // Second launch should not overwrite
        manager.recordLaunch()
        let secondDate = defaults.object(forKey: SharedConstants.firstLaunchDateKey) as? Date
        XCTAssertEqual(firstDate, secondDate)
    }

    func testRecordResignActiveSetsLastActiveDate() {
        XCTAssertNil(defaults.object(forKey: SharedConstants.lastActiveeDateKey))
        manager.recordResignActive()
        XCTAssertNotNil(defaults.object(forKey: SharedConstants.lastActiveeDateKey) as? Date)
    }

    func testRecordPurchaseSetsPurchaseDate() {
        XCTAssertNil(defaults.object(forKey: SharedConstants.proPurchaseDateKey))
        manager.recordPurchase()
        XCTAssertNotNil(defaults.object(forKey: SharedConstants.proPurchaseDateKey) as? Date)
    }

    // MARK: - Not Eligible (Fresh Install)

    func testNotEligibleOnFreshInstall() {
        // No launches recorded — should never prompt
        let result = manager.requestReviewIfEligible()
        XCTAssertFalse(result)
    }

    func testNotEligibleWithFewLaunches() {
        // Only 3 launches, need 5 minimum
        for _ in 1...3 {
            manager.recordLaunch()
        }
        // Set first launch date to 30 days ago to pass the days check
        defaults.set(Date().addingTimeInterval(-30 * 86400), forKey: SharedConstants.firstLaunchDateKey)

        let result = manager.requestReviewIfEligible()
        XCTAssertFalse(result)
    }

    func testNotEligibleWithEnoughLaunchesButTooRecent() {
        // 10 launches but first launch was today
        for _ in 1...10 {
            manager.recordLaunch()
        }
        // firstLaunchDate is set to now by recordLaunch, so days < 7

        let result = manager.requestReviewIfEligible()
        XCTAssertFalse(result)
    }

    // MARK: - Post-Install Engagement Trigger

    func testEligiblePostInstallEngagement() {
        // 5+ launches AND 7+ days since install
        for _ in 1...6 {
            manager.recordLaunch()
        }
        defaults.set(Date().addingTimeInterval(-8 * 86400), forKey: SharedConstants.firstLaunchDateKey)

        let result = manager.requestReviewIfEligible()
        XCTAssertTrue(result)
    }

    // MARK: - Post-Purchase Trigger

    func testEligiblePostPurchaseSatisfied() {
        // 5+ launches and purchase was 4 days ago
        for _ in 1...6 {
            manager.recordLaunch()
        }
        defaults.set(Date().addingTimeInterval(-4 * 86400), forKey: SharedConstants.proPurchaseDateKey)

        let result = manager.requestReviewIfEligible()
        XCTAssertTrue(result)
    }

    func testNotEligiblePurchaseTooRecent() {
        // 5+ launches but purchase was only 1 day ago
        for _ in 1...6 {
            manager.recordLaunch()
        }
        defaults.set(Date().addingTimeInterval(-1 * 86400), forKey: SharedConstants.proPurchaseDateKey)
        // firstLaunchDate is today (not enough days for post-install either)

        let result = manager.requestReviewIfEligible()
        XCTAssertFalse(result)
    }

    // MARK: - Returning User Trigger

    func testEligibleReturningUser() {
        // 5+ launches and last active 15 days ago
        for _ in 1...6 {
            manager.recordLaunch()
        }
        defaults.set(Date().addingTimeInterval(-15 * 86400), forKey: SharedConstants.lastActiveeDateKey)

        let result = manager.requestReviewIfEligible()
        XCTAssertTrue(result)
    }

    func testNotEligibleRecentlyActive() {
        // 5+ launches but last active only 5 days ago
        for _ in 1...6 {
            manager.recordLaunch()
        }
        defaults.set(Date().addingTimeInterval(-5 * 86400), forKey: SharedConstants.lastActiveeDateKey)
        // firstLaunchDate is today, no purchase — no trigger met

        let result = manager.requestReviewIfEligible()
        XCTAssertFalse(result)
    }

    // MARK: - Cooldown

    func testCooldownPreventsRepeatRequests() {
        // First request succeeds
        for _ in 1...6 {
            manager.recordLaunch()
        }
        defaults.set(Date().addingTimeInterval(-8 * 86400), forKey: SharedConstants.firstLaunchDateKey)

        let first = manager.requestReviewIfEligible()
        XCTAssertTrue(first)

        // Immediately requesting again should be blocked by cooldown
        let second = manager.requestReviewIfEligible()
        XCTAssertFalse(second)
    }

    func testCooldownExpiresAfter120Days() {
        // Set last review request to 121 days ago
        defaults.set(Date().addingTimeInterval(-121 * 86400), forKey: SharedConstants.lastReviewRequestDateKey)

        // Set up eligibility
        for _ in 1...6 {
            manager.recordLaunch()
        }
        defaults.set(Date().addingTimeInterval(-8 * 86400), forKey: SharedConstants.firstLaunchDateKey)

        let result = manager.requestReviewIfEligible()
        XCTAssertTrue(result)
    }

    func testCooldownActiveWithin120Days() {
        // Set last review request to 60 days ago (still in cooldown)
        defaults.set(Date().addingTimeInterval(-60 * 86400), forKey: SharedConstants.lastReviewRequestDateKey)

        // Set up eligibility
        for _ in 1...6 {
            manager.recordLaunch()
        }
        defaults.set(Date().addingTimeInterval(-8 * 86400), forKey: SharedConstants.firstLaunchDateKey)

        let result = manager.requestReviewIfEligible()
        XCTAssertFalse(result)
    }
}
