import Foundation
import Security

/// Provides Keychain-based storage for sensitive data (Pro tier status).
/// Main app target ONLY — the extension cannot access Keychain (securityd XPC blocked).
struct KeychainService {

    private static let service = "com.millermedia.ElectionDeflection"
    private static let proTierKey = "proTierStatus"

    // MARK: - Pro Tier Status

    /// Saves Pro tier status to Keychain. Returns true on success.
    @discardableResult
    static func saveProTierStatus(_ isPro: Bool) -> Bool {
        let data = Data([isPro ? 1 : 0])
        let query: [String: Any] = [
            kSecClass as String: kSecClassGenericPassword,
            kSecAttrService as String: service,
            kSecAttrAccount as String: proTierKey
        ]
        let update: [String: Any] = [
            kSecValueData as String: data
        ]
        let status = SecItemUpdate(query as CFDictionary, update as CFDictionary)
        if status == errSecItemNotFound {
            var addQuery = query
            addQuery[kSecValueData as String] = data
            addQuery[kSecAttrAccessible as String] = kSecAttrAccessibleAfterFirstUnlock
            return SecItemAdd(addQuery as CFDictionary, nil) == errSecSuccess
        }
        return status == errSecSuccess
    }

    /// Loads Pro tier status from Keychain. Returns nil if not found.
    static func loadProTierStatus() -> Bool? {
        let query: [String: Any] = [
            kSecClass as String: kSecClassGenericPassword,
            kSecAttrService as String: service,
            kSecAttrAccount as String: proTierKey,
            kSecReturnData as String: true,
            kSecMatchLimit as String: kSecMatchLimitOne
        ]
        var result: AnyObject?
        let status = SecItemCopyMatching(query as CFDictionary, &result)
        guard status == errSecSuccess, let data = result as? Data, !data.isEmpty else {
            return nil
        }
        return data[0] == 1
    }

    /// Deletes Pro tier status from Keychain. Returns true on success.
    @discardableResult
    static func deleteProTierStatus() -> Bool {
        let query: [String: Any] = [
            kSecClass as String: kSecClassGenericPassword,
            kSecAttrService as String: service,
            kSecAttrAccount as String: proTierKey
        ]
        let status = SecItemDelete(query as CFDictionary)
        return status == errSecSuccess || status == errSecItemNotFound
    }
}
