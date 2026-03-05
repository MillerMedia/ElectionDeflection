import Foundation

/// Centralized constants shared between the main app and the MessageFilter extension.
/// Both targets must include this file in their Compile Sources build phase.
enum SharedConstants {

    // MARK: - App Group

    static let appGroupIdentifier = "group.com.millermedia.electiondeflection"

    // MARK: - UserDefaults Keys

    static let keywordListKey = "keywordList"
    static let filterEnabledKey = "filterEnabled"
    static let proTierStatusKey = "proTierStatus"
    static let mlModelEnabledKey = "mlModelEnabled"
    static let textsBlockedCountKey = "textsBlockedCount"
    static let filterMethodKey = "filterMethod"
    static let v1PurchaserKey = "isV1Purchaser"
    static let whitelistContextsKey = "whitelistContexts"
    static let combinedTermsKey = "combinedTerms"
    static let hasCompletedOnboardingKey = "hasCompletedOnboarding"
    static let hasSeenUpgradePromptKey = "hasSeenUpgradePrompt"
    static let onboardingCompletedDateKey = "onboardingCompletedDate"
    static let hasSeenV2WelcomeKey = "hasSeenV2Welcome"

    // MARK: - Upgrade Prompt

    static let upgradePromptDelayDays = 3
    static let upgradeNotificationID = "contextual-upgrade-prompt"

    // MARK: - IAP Product IDs

    static let proAnnualProductID = "com.millermedia.ElectionDeflection.pro.annual"
    static let proLifetimeProductID = "com.millermedia.ElectionDeflection.pro.lifetime"
    static let subscriptionGroupID = "ElectionDeflectionPro"

    // MARK: - Filter Method Values

    static let filterMethodKeyword = "keyword"
    static let filterMethodML = "ml"

    // MARK: - Default Values

    static let defaultFilterEnabled = true
    static let defaultProTierStatus = false
    static let defaultMLModelEnabled = true
    static let defaultTextsBlockedCount = 0
    static let defaultFilterMethod = filterMethodKeyword
    static let defaultIsV1Purchaser = false
    static let defaultHasCompletedOnboarding = false
}
