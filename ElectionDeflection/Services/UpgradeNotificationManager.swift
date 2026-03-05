import UserNotifications

enum UpgradeNotificationManager {

    /// Requests notification permission and schedules the contextual upgrade notification.
    /// Called once after initial onboarding completion.
    static func scheduleUpgradeNotification() {
        let center = UNUserNotificationCenter.current()
        center.requestAuthorization(options: [.alert, .sound]) { granted, _ in
            guard granted else { return }
            let content = UNMutableNotificationContent()
            content.title = "How's your filtering going?"
            content.body = "Your keyword filter is working hard. Upgrade to Pro for AI-powered accuracy that catches what keywords miss."
            content.sound = .default

            let delaySeconds = TimeInterval(SharedConstants.upgradePromptDelayDays * 86400)
            let trigger = UNTimeIntervalNotificationTrigger(timeInterval: delaySeconds, repeats: false)
            let request = UNNotificationRequest(
                identifier: SharedConstants.upgradeNotificationID,
                content: content,
                trigger: trigger
            )

            center.add(request) { error in
                #if DEBUG
                if let error = error {
                    print("[UpgradeNotification] Failed to schedule: \(error)")
                } else {
                    print("[UpgradeNotification] Scheduled for \(SharedConstants.upgradePromptDelayDays) days from now")
                }
                #endif
            }
        }
    }

    /// Cancels the pending upgrade notification (e.g., after user upgrades or sees the modal).
    static func cancelPendingNotification() {
        UNUserNotificationCenter.current()
            .removePendingNotificationRequests(withIdentifiers: [SharedConstants.upgradeNotificationID])
    }
}
