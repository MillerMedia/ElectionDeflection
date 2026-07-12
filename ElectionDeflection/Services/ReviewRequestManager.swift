import Foundation
import StoreKit
import os.log

/// Manages in-app review request timing to prompt satisfied users at optimal moments.
/// Uses UserDefaults to track launch count, dates, and cooldowns. Apple's system
/// rate-limits actual prompts to 3 per 365-day period regardless of our requests.
@MainActor
final class ReviewRequestManager {

    static let shared = ReviewRequestManager()

    private let defaults: UserDefaults
    private let logger = Logger(subsystem: "com.millermedia.ElectionDeflection", category: "ReviewRequest")
    private let calendar = Calendar.current

    init(defaults: UserDefaults = .standard) {
        self.defaults = defaults
    }

    // MARK: - Launch Tracking

    /// Call on every app launch (scene becomes active) to track engagement.
    func recordLaunch() {
        let count = defaults.integer(forKey: SharedConstants.appLaunchCountKey) + 1
        defaults.set(count, forKey: SharedConstants.appLaunchCountKey)

        if defaults.object(forKey: SharedConstants.firstLaunchDateKey) == nil {
            defaults.set(Date(), forKey: SharedConstants.firstLaunchDateKey)
        }
    }

    /// Call when scene resigns active to track last-active date for re-engagement detection.
    func recordResignActive() {
        defaults.set(Date(), forKey: SharedConstants.lastActiveeDateKey)
    }

    /// Call on successful Pro tier purchase to start the post-purchase satisfaction timer.
    func recordPurchase() {
        defaults.set(Date(), forKey: SharedConstants.proPurchaseDateKey)
    }

    // MARK: - Eligibility Check

    /// Evaluates whether to request a review. Returns true if a request was made.
    /// Call from MainAppView when the scene becomes active and no modal is presented.
    func requestReviewIfEligible() -> Bool {
        guard !isOnCooldown() else { return false }
        guard hasMinimumLaunches() else { return false }

        if isPostInstallEngaged() || isPostPurchaseSatisfied() || isReturningUser() {
            requestReview()
            return true
        }
        return false
    }

    // MARK: - Trigger Conditions

    /// Post-install engagement: 5+ launches AND 7+ days since first launch.
    private func isPostInstallEngaged() -> Bool {
        guard let firstLaunch = defaults.object(forKey: SharedConstants.firstLaunchDateKey) as? Date else {
            return false
        }
        let daysSinceInstall = calendar.dateComponents([.day], from: firstLaunch, to: Date()).day ?? 0
        return daysSinceInstall >= SharedConstants.reviewRequestMinDaysSinceInstall
    }

    /// Post-upgrade satisfaction: 3+ days after Pro purchase.
    private func isPostPurchaseSatisfied() -> Bool {
        guard let purchaseDate = defaults.object(forKey: SharedConstants.proPurchaseDateKey) as? Date else {
            return false
        }
        let daysSincePurchase = calendar.dateComponents([.day], from: purchaseDate, to: Date()).day ?? 0
        return daysSincePurchase >= SharedConstants.reviewRequestMinDaysSincePurchase
    }

    /// Returning user: 14+ days since last active session.
    private func isReturningUser() -> Bool {
        guard let lastActive = defaults.object(forKey: SharedConstants.lastActiveeDateKey) as? Date else {
            return false
        }
        let daysSinceActive = calendar.dateComponents([.day], from: lastActive, to: Date()).day ?? 0
        return daysSinceActive >= SharedConstants.reviewRequestInactivityDays
    }

    // MARK: - Guards

    /// Minimum launches before any review prompt (avoids prompting brand-new users).
    private func hasMinimumLaunches() -> Bool {
        defaults.integer(forKey: SharedConstants.appLaunchCountKey) >= SharedConstants.reviewRequestMinLaunches
    }

    /// Cooldown: at least 120 days between our requests (Apple also enforces its own limit).
    private func isOnCooldown() -> Bool {
        guard let lastRequest = defaults.object(forKey: SharedConstants.lastReviewRequestDateKey) as? Date else {
            return false
        }
        let daysSinceRequest = calendar.dateComponents([.day], from: lastRequest, to: Date()).day ?? 0
        return daysSinceRequest < SharedConstants.reviewRequestCooldownDays
    }

    // MARK: - Request

    private func requestReview() {
        defaults.set(Date(), forKey: SharedConstants.lastReviewRequestDateKey)
        logger.info("Requesting App Store review")

        // Use the UIKit API for broad compatibility. The SwiftUI RequestReviewAction
        // requires passing the environment, which is awkward from a service class.
        if let windowScene = UIApplication.shared.connectedScenes
            .compactMap({ $0 as? UIWindowScene })
            .first(where: { $0.activationState == .foregroundActive }) {
            SKStoreReviewController.requestReview(in: windowScene)
        }
    }
}
