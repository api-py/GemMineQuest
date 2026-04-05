import Foundation
import UserNotifications

class NotificationManager {
    static let shared = NotificationManager()

    private init() {}

    func requestPermission() {
        UNUserNotificationCenter.current().requestAuthorization(options: [.alert, .badge, .sound]) { granted, error in
            if let error = error {
                print("[NotificationManager] Permission error: \(error.localizedDescription)")
            }
            if granted {
                self.scheduleDailyRewardReminder()
                self.scheduleInactivePlayerReminder()
                self.scheduleFreeSpinReminder()
            }
        }
    }

    // MARK: - Daily Reward Reminder

    func scheduleDailyRewardReminder() {
        let identifier = "dailyRewardReminder"
        UNUserNotificationCenter.current().removePendingNotificationRequests(withIdentifiers: [identifier])

        let content = UNMutableNotificationContent()
        content.title = "Daily Mining Bonus Ready!"
        content.body = "Your daily reward is waiting. Come back to claim free coins and boosters!"
        content.sound = .default

        // Trigger at 9 AM daily
        var dateComponents = DateComponents()
        dateComponents.hour = 9
        dateComponents.minute = 0
        let trigger = UNCalendarNotificationTrigger(dateMatching: dateComponents, repeats: true)

        let request = UNNotificationRequest(identifier: identifier, content: content, trigger: trigger)
        UNUserNotificationCenter.current().add(request) { error in
            if let error = error {
                print("[NotificationManager] Daily reward scheduling error: \(error.localizedDescription)")
            }
        }
    }

    // MARK: - Inactive Player Reminder

    func scheduleInactivePlayerReminder() {
        let identifier = "inactivePlayerReminder"
        UNUserNotificationCenter.current().removePendingNotificationRequests(withIdentifiers: [identifier])

        let content = UNMutableNotificationContent()
        content.title = "The mine misses you!"
        content.body = "Gems are piling up! Come back and dig for treasure."
        content.sound = .default

        // Trigger after 3 days of inactivity
        let trigger = UNTimeIntervalNotificationTrigger(timeInterval: 3 * 24 * 3600, repeats: false)

        let request = UNNotificationRequest(identifier: identifier, content: content, trigger: trigger)
        UNUserNotificationCenter.current().add(request) { error in
            if let error = error {
                print("[NotificationManager] Inactive reminder scheduling error: \(error.localizedDescription)")
            }
        }
    }

    // MARK: - Free Spin Reminder

    func scheduleFreeSpinReminder() {
        let identifier = "freeSpinReminder"
        UNUserNotificationCenter.current().removePendingNotificationRequests(withIdentifiers: [identifier])

        let content = UNMutableNotificationContent()
        content.title = "Free Spin Available!"
        content.body = "Your daily free spin is ready. Try your luck at the Lucky Mine Wheel!"
        content.sound = .default

        // Trigger at 10 AM daily
        var dateComponents = DateComponents()
        dateComponents.hour = 10
        dateComponents.minute = 0
        let trigger = UNCalendarNotificationTrigger(dateMatching: dateComponents, repeats: true)

        let request = UNNotificationRequest(identifier: identifier, content: content, trigger: trigger)
        UNUserNotificationCenter.current().add(request) { error in
            if let error = error {
                print("[NotificationManager] Free spin scheduling error: \(error.localizedDescription)")
            }
        }
    }

    /// Call when the app becomes active to reset the inactivity timer
    func resetInactivityTimer() {
        scheduleInactivePlayerReminder()
    }
}
