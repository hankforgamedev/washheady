import Foundation
import UserNotifications

enum NotificationActionHandler {
    static func handle(_ response: UNNotificationResponse, defaults: UserDefaults = .standard) {
        switch response.actionIdentifier {
        case NotificationIdentifiers.washYes:
            defaults.set(true, forKey: "pendingOpenWash")

        case NotificationIdentifiers.washNo:
            let oldJSON = defaults.string(forKey: WashHistory.storageKey) ?? "{}"
            let sleepMinute = defaults.object(forKey: "sleepMinuteOfDay") as? Int ?? 60
            let recordDate = WashHistory.effectiveRecordDate(
                for: Date(),
                sleepMinuteOfDay: sleepMinute
            )
            defaults.set(
                WashHistory.updating(oldJSON, status: .notWashed, on: recordDate),
                forKey: WashHistory.storageKey
            )
            defaults.set(WashStatus.notWashed.rawValue, forKey: "lastStatus")
            defaults.set(Date().timeIntervalSince1970, forKey: "lastStatusDate")
            NotificationManager.cancel(for: recordDate)

        default:
            defaults.set(true, forKey: "pendingShowQuestion")
        }
    }
}
