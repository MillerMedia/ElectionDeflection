import UIKit

enum AppIconManager {
    static let proIconName = "AppIcon-Pro"

    static var isProIconActive: Bool {
        UIApplication.shared.alternateIconName == proIconName
    }

    static func setIcon(pro: Bool, completion: @escaping (Bool) -> Void) {
        guard UIApplication.shared.supportsAlternateIcons else {
            completion(false)
            return
        }
        let name = pro ? proIconName : nil
        UIApplication.shared.setAlternateIconName(name) { error in
            if let error = error {
                #if DEBUG
                print("[AppIconManager] Failed to set icon to \(name ?? "default"): \(error)")
                #endif
                completion(false)
            } else {
                #if DEBUG
                print("[AppIconManager] Icon changed to \(name ?? "default")")
                #endif
                completion(true)
            }
        }
    }
}
