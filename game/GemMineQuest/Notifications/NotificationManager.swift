import UserNotifications

class NotificationManager {
    static let shared = NotificationManager()

    func requestPermission() {
        UNUserNotificationCenter.current().requestAuthorization(options: [.alert, .sound, .badge]) { granted, _ in
            if granted {
                self.scheduleReminders()
            }
        }
    }

    func scheduleReminders() {
        cancelPending()

        // Daily reward reminder (fires 24h from now)
        scheduleNotification(
            id: "daily_reward",
            title: "Daily Mining Bonus Ready!",
            body: "Your daily mining bonus is ready! Don't break your streak!",
            delay: 24 * 3600
        )

        // Inactive player (fires 3 days from now)
        scheduleNotification(
            id: "inactive_player",
            title: "The Mine Misses You!",
            body: "Come back and dig for gems & precious metals!",
            delay: 3 * 24 * 3600
        )

        // Free spin reminder (fires tomorrow at 9 AM)
        scheduleDailyNotification(
            id: "free_spin",
            title: "Free Spin Available!",
            body: "Free spin of the Lucky Mine Wheel is waiting!",
            hour: 9, minute: 0
        )
    }

    func cancelPending() {
        UNUserNotificationCenter.current().removeAllPendingNotificationRequests()
    }

    private func scheduleNotification(id: String, title: String, body: String, delay: TimeInterval) {
        let content = UNMutableNotificationContent()
        content.title = title
        content.body = body
        content.sound = .default

        let trigger = UNTimeIntervalNotificationTrigger(timeInterval: delay, repeats: false)
        let request = UNNotificationRequest(identifier: id, content: content, trigger: trigger)

        UNUserNotificationCenter.current().add(request)
    }

    private func scheduleDailyNotification(id: String, title: String, body: String, hour: Int, minute: Int) {
        let content = UNMutableNotificationContent()
        content.title = title
        content.body = body
        content.sound = .default

        var dateComponents = DateComponents()
        dateComponents.hour = hour
        dateComponents.minute = minute

        let trigger = UNCalendarNotificationTrigger(dateMatching: dateComponents, repeats: true)
        let request = UNNotificationRequest(identifier: id, content: content, trigger: trigger)

        UNUserNotificationCenter.current().add(request)
    }
}
