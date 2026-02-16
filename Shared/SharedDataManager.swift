import Foundation

/// Centralized read/write access to the App Group shared storage.
/// Used by both the main app and the MessageFilter extension.
/// All storage is local — no networking is performed.
///
/// NOTE: ILMessageFilterExtension has an extremely restrictive sandbox that blocks
/// ALL write operations (UserDefaults, file I/O, Keychain, Darwin notifications).
/// Properties written by the extension (e.g. textsBlockedCount) will only persist
/// in-memory for the extension's process lifetime. Only the main app can persist data.
final class SharedDataManager {

    static let shared = SharedDataManager()

    private let defaults: UserDefaults?
    private let fileManager: FileManager
    private let queue = DispatchQueue(label: "com.millermedia.electiondeflection.sharedDataManager", qos: .utility)

    init(defaults: UserDefaults? = UserDefaults(suiteName: SharedConstants.appGroupIdentifier),
         fileManager: FileManager = .default) {
        self.defaults = defaults
        self.fileManager = fileManager
    }

    // MARK: - Container URL

    var sharedContainerURL: URL? {
        fileManager.containerURL(forSecurityApplicationGroupIdentifier: SharedConstants.appGroupIdentifier)
    }

    // MARK: - Onboarding State
    // NOTE: Setter writes are blocked by the ILMessageFilterExtension sandbox.
    // This property can only be written from the main app.

    var hasCompletedOnboarding: Bool {
        get { defaults?.bool(forKey: SharedConstants.hasCompletedOnboardingKey) ?? SharedConstants.defaultHasCompletedOnboarding }
        set { defaults?.set(newValue, forKey: SharedConstants.hasCompletedOnboardingKey) }
    }

    // MARK: - Filter Enabled

    var isFilterEnabled: Bool {
        get { defaults?.object(forKey: SharedConstants.filterEnabledKey) as? Bool ?? SharedConstants.defaultFilterEnabled }
        set { defaults?.set(newValue, forKey: SharedConstants.filterEnabledKey) }
    }

    // MARK: - Pro Tier Status

    var isProTier: Bool {
        get { defaults?.bool(forKey: SharedConstants.proTierStatusKey) ?? SharedConstants.defaultProTierStatus }
        set { defaults?.set(newValue, forKey: SharedConstants.proTierStatusKey) }
    }

    // MARK: - ML Model Enabled

    var isMLModelEnabled: Bool {
        get { defaults?.object(forKey: SharedConstants.mlModelEnabledKey) as? Bool ?? SharedConstants.defaultMLModelEnabled }
        set { defaults?.set(newValue, forKey: SharedConstants.mlModelEnabledKey) }
    }

    // MARK: - Texts Blocked Count
    // NOTE: The extension calls incrementTextsBlockedCount() but the write is blocked
    // by the ILMessageFilterExtension sandbox. This counter can only be updated from
    // the main app. See extension-sandbox.md in project memory for details.

    var textsBlockedCount: Int {
        get { defaults?.integer(forKey: SharedConstants.textsBlockedCountKey) ?? SharedConstants.defaultTextsBlockedCount }
        set { defaults?.set(newValue, forKey: SharedConstants.textsBlockedCountKey) }
    }

    // NOTE: Uses queue.sync intentionally to ensure the count is updated atomically
    // before returning. In the extension, the write is silently blocked by the sandbox
    // anyway, so the sync overhead is negligible.
    func incrementTextsBlockedCount() {
        queue.sync {
            let current = defaults?.integer(forKey: SharedConstants.textsBlockedCountKey) ?? 0
            defaults?.set(current + 1, forKey: SharedConstants.textsBlockedCountKey)
        }
    }

    // MARK: - Filter Method

    var filterMethod: String {
        get { defaults?.string(forKey: SharedConstants.filterMethodKey) ?? SharedConstants.defaultFilterMethod }
        set { defaults?.set(newValue, forKey: SharedConstants.filterMethodKey) }
    }

    // MARK: - V1 Purchaser

    var isV1Purchaser: Bool {
        get { defaults?.bool(forKey: SharedConstants.v1PurchaserKey) ?? SharedConstants.defaultIsV1Purchaser }
        set { defaults?.set(newValue, forKey: SharedConstants.v1PurchaserKey) }
    }

    // MARK: - Onboarding Completed Date (main app only)

    var onboardingCompletedDate: Date? {
        get { defaults?.object(forKey: SharedConstants.onboardingCompletedDateKey) as? Date }
        set { defaults?.set(newValue, forKey: SharedConstants.onboardingCompletedDateKey) }
    }

    // MARK: - Upgrade Prompt Seen (main app only)

    var hasSeenUpgradePrompt: Bool {
        get { defaults?.bool(forKey: SharedConstants.hasSeenUpgradePromptKey) ?? false }
        set { defaults?.set(newValue, forKey: SharedConstants.hasSeenUpgradePromptKey) }
    }

    // MARK: - Keyword List

    var keywordList: [String] {
        get { defaults?.stringArray(forKey: SharedConstants.keywordListKey) ?? [] }
        set { defaults?.set(newValue, forKey: SharedConstants.keywordListKey) }
    }

    // MARK: - Whitelist Contexts

    var whitelistContexts: [String: [String]] {
        get { defaults?.dictionary(forKey: SharedConstants.whitelistContextsKey) as? [String: [String]] ?? [:] }
        set { defaults?.set(newValue, forKey: SharedConstants.whitelistContextsKey) }
    }

    // MARK: - Combined Terms

    var combinedTerms: [[String]] {
        get { (defaults?.array(forKey: SharedConstants.combinedTermsKey) as? [[String]]) ?? [] }
        set { defaults?.set(newValue, forKey: SharedConstants.combinedTermsKey) }
    }

    // MARK: - Seed Default Filter Data

    func seedDefaultFilterDataIfNeeded() {
        guard keywordList.isEmpty else { return }
        keywordList = DefaultFilterData.keywords
        whitelistContexts = DefaultFilterData.whitelistContexts
        combinedTerms = DefaultFilterData.combinedTerms
    }
}
