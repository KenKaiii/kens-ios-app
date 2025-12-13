import Foundation
import UserNotifications

/// Service for managing local and remote notifications
final class NotificationService {

    // MARK: - Singleton

    static let shared = NotificationService()

    // MARK: - Properties

    private let notificationCenter = UNUserNotificationCenter.current()

    // MARK: - Permission

    /// Request notification permissions
    func requestPermission() async -> Bool {
        do {
            let granted = try await notificationCenter.requestAuthorization(
                options: [.alert, .badge, .sound]
            )
            Log.info("Notification permission: \(granted ? "granted" : "denied")")
            return granted
        } catch {
            Log.error("Failed to request notification permission", error: error)
            return false
        }
    }

    /// Check current notification permission status
    func checkPermissionStatus() async -> UNAuthorizationStatus {
        let settings = await notificationCenter.notificationSettings()
        return settings.authorizationStatus
    }

    // MARK: - Local Notifications

    /// Schedule a local notification
    func scheduleLocalNotification(
        id: String = UUID().uuidString,
        title: String,
        body: String,
        subtitle: String? = nil,
        badge: Int? = nil,
        sound: UNNotificationSound = .default,
        trigger: UNNotificationTrigger,
        userInfo: [String: Any] = [:]
    ) async throws {
        let content = UNMutableNotificationContent()
        content.title = title
        content.body = body
        if let subtitle = subtitle {
            content.subtitle = subtitle
        }
        if let badge = badge {
            content.badge = NSNumber(value: badge)
        }
        content.sound = sound
        content.userInfo = userInfo

        let request = UNNotificationRequest(
            identifier: id,
            content: content,
            trigger: trigger
        )

        try await notificationCenter.add(request)
        Log.info("Scheduled notification: \(id)")
    }

    /// Schedule a notification for a specific date
    func scheduleNotification(
        id: String = UUID().uuidString,
        title: String,
        body: String,
        date: Date,
        repeats: Bool = false
    ) async throws {
        let components = Calendar.current.dateComponents(
            [.year, .month, .day, .hour, .minute],
            from: date
        )
        let trigger = UNCalendarNotificationTrigger(
            dateMatching: components,
            repeats: repeats
        )

        try await scheduleLocalNotification(
            id: id,
            title: title,
            body: body,
            trigger: trigger
        )
    }

    /// Schedule a notification after a time interval
    func scheduleNotification(
        id: String = UUID().uuidString,
        title: String,
        body: String,
        timeInterval: TimeInterval,
        repeats: Bool = false
    ) async throws {
        let trigger = UNTimeIntervalNotificationTrigger(
            timeInterval: timeInterval,
            repeats: repeats
        )

        try await scheduleLocalNotification(
            id: id,
            title: title,
            body: body,
            trigger: trigger
        )
    }

    // MARK: - Notification Management

    /// Cancel a specific notification
    func cancelNotification(id: String) {
        notificationCenter.removePendingNotificationRequests(withIdentifiers: [id])
        Log.info("Cancelled notification: \(id)")
    }

    /// Cancel all pending notifications
    func cancelAllNotifications() {
        notificationCenter.removeAllPendingNotificationRequests()
        Log.info("Cancelled all notifications")
    }

    /// Get all pending notification requests
    func getPendingNotifications() async -> [UNNotificationRequest] {
        await notificationCenter.pendingNotificationRequests()
    }

    // MARK: - Badge Management

    /// Clear the app badge
    func clearBadge() async {
        await MainActor.run {
            UNUserNotificationCenter.current().setBadgeCount(0)
        }
    }

    /// Set the app badge count
    func setBadgeCount(_ count: Int) async {
        await MainActor.run {
            UNUserNotificationCenter.current().setBadgeCount(count)
        }
    }
}
