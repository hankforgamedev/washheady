import UIKit
import UserNotifications

enum NotificationIdentifiers {
    static let category = "WASH_QUESTION"
    static let washYes = "WASH_YES"
    static let washNo = "WASH_NO"
    static let questionPrefix = "wash-question-"
    static let unknownPrefix = "wash-unknown-"
}

enum NotificationManager {
    static func registerCategories() {
        let yes = UNNotificationAction(
            identifier: NotificationIdentifiers.washYes,
            title: "要",
            options: [.foreground]
        )
        let no = UNNotificationAction(
            identifier: NotificationIdentifiers.washNo,
            title: "不要",
            options: []
        )
        let category = UNNotificationCategory(
            identifier: NotificationIdentifiers.category,
            actions: [yes, no],
            intentIdentifiers: [],
            options: []
        )
        UNUserNotificationCenter.current().setNotificationCategories([category])
    }

    static func requestAuthorization() async -> Bool {
        do {
            return try await UNUserNotificationCenter.current()
                .requestAuthorization(options: [.alert, .sound, .badge])
        } catch {
            return false
        }
    }

    static func refresh(
        scheduleJSON: String,
        sleepMinuteOfDay: Int,
        historyJSON: String,
        isEnabled: Bool,
        now: Date = Date(),
        calendar: Calendar = .current
    ) async {
        registerCategories()
        let center = UNUserNotificationCenter.current()
        let pending = await center.pendingNotificationRequests()
        let managedIDs = pending.map(\.identifier).filter {
            $0.hasPrefix(NotificationIdentifiers.questionPrefix)
                || $0.hasPrefix(NotificationIdentifiers.unknownPrefix)
        }
        center.removePendingNotificationRequests(withIdentifiers: managedIDs)

        guard isEnabled else { return }
        let settings = await center.notificationSettings()
        guard settings.authorizationStatus == .authorized
                || settings.authorizationStatus == .provisional else {
            return
        }

        let schedules = ShowerScheduleCodec.decode(scheduleJSON)
        let start = calendar.startOfDay(for: now)

        for dayOffset in 0..<14 {
            guard let day = calendar.date(byAdding: .day, value: dayOffset, to: start),
                  WashHistory.status(on: day, in: historyJSON, calendar: calendar) == nil else {
                continue
            }

            let weekday = calendar.component(.weekday, from: day)
            if let schedule = schedules.first(where: { $0.weekday == weekday && $0.isEnabled }),
               let questionDate = date(
                    on: day,
                    minuteOfDay: schedule.minuteOfDay,
                    calendar: calendar
               ), questionDate > now {
                await addQuestionNotification(on: questionDate, day: day, calendar: calendar)
            }

            let unknownMinute = (sleepMinuteOfDay - 10 + 24 * 60) % (24 * 60)
            let unknownDay = sleepMinuteOfDay < 6 * 60
                ? (calendar.date(byAdding: .day, value: 1, to: day) ?? day)
                : day
            if let unknownDate = date(on: unknownDay, minuteOfDay: unknownMinute, calendar: calendar),
               unknownDate > now {
                await addUnknownNotification(on: unknownDate, day: day, calendar: calendar)
            }
        }
    }

    static func cancel(for date: Date, calendar: Calendar = .current) {
        let key = WashHistory.dayKey(for: date, calendar: calendar)
        UNUserNotificationCenter.current().removePendingNotificationRequests(
            withIdentifiers: [
                NotificationIdentifiers.questionPrefix + key,
                NotificationIdentifiers.unknownPrefix + key
            ]
        )
    }

    private static func addQuestionNotification(
        on date: Date,
        day: Date,
        calendar: Calendar
    ) async {
        let content = UNMutableNotificationContent()
        content.title = "洗頭了沒？"
        content.body = "欸 Hank，我們今天有要洗頭嗎？"
        content.sound = .default
        content.categoryIdentifier = NotificationIdentifiers.category

        await add(
            identifier: NotificationIdentifiers.questionPrefix + WashHistory.dayKey(for: day, calendar: calendar),
            content: content,
            date: date,
            calendar: calendar
        )
    }

    private static func addUnknownNotification(
        on date: Date,
        day: Date,
        calendar: Calendar
    ) async {
        let content = UNMutableNotificationContent()
        content.title = "我不確定。"
        content.body = "快睡了，但我們今天到底有沒有洗頭？"
        content.sound = .default
        content.categoryIdentifier = NotificationIdentifiers.category

        await add(
            identifier: NotificationIdentifiers.unknownPrefix + WashHistory.dayKey(for: day, calendar: calendar),
            content: content,
            date: date,
            calendar: calendar
        )
    }

    private static func add(
        identifier: String,
        content: UNNotificationContent,
        date: Date,
        calendar: Calendar
    ) async {
        let components = calendar.dateComponents(
            [.year, .month, .day, .hour, .minute],
            from: date
        )
        let trigger = UNCalendarNotificationTrigger(dateMatching: components, repeats: false)
        let request = UNNotificationRequest(
            identifier: identifier,
            content: content,
            trigger: trigger
        )
        try? await UNUserNotificationCenter.current().add(request)
    }

    private static func date(
        on day: Date,
        minuteOfDay: Int,
        calendar: Calendar
    ) -> Date? {
        calendar.date(
            bySettingHour: minuteOfDay / 60,
            minute: minuteOfDay % 60,
            second: 0,
            of: day
        )
    }
}

@MainActor
enum AppIconManager {
    static func sync(messinessLevel: Int, isUnknown: Bool) {
        let application = UIApplication.shared
        guard application.supportsAlternateIcons else { return }

        let desiredName: String?
        if isUnknown {
            desiredName = "AppIconUnknown"
        } else if messinessLevel >= 3 {
            desiredName = "AppIconMax"
        } else if messinessLevel >= 1 {
            desiredName = "AppIconPuffy"
        } else {
            desiredName = nil
        }

        guard application.alternateIconName != desiredName else { return }
        application.setAlternateIconName(desiredName) { error in
            if let error {
                print("Unable to update app icon: \(error.localizedDescription)")
            }
        }
    }
}

final class AppDelegate: NSObject, UIApplicationDelegate, UNUserNotificationCenterDelegate {
    func application(
        _ application: UIApplication,
        didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey: Any]? = nil
    ) -> Bool {
        UNUserNotificationCenter.current().delegate = self
        NotificationManager.registerCategories()
        return true
    }

    func userNotificationCenter(
        _ center: UNUserNotificationCenter,
        willPresent notification: UNNotification,
        withCompletionHandler completionHandler: @escaping (UNNotificationPresentationOptions) -> Void
    ) {
        completionHandler([.banner, .sound])
    }

    func userNotificationCenter(
        _ center: UNUserNotificationCenter,
        didReceive response: UNNotificationResponse,
        withCompletionHandler completionHandler: @escaping () -> Void
    ) {
        let defaults = UserDefaults.standard

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

        completionHandler()
    }
}
