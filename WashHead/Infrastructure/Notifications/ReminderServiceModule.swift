import Foundation

struct ReminderRefreshInput {
    let scheduleJSON: String
    let sleepMinuteOfDay: Int
    let historyJSON: String
    let isEnabled: Bool
}

struct ReminderServiceModule {
    let requestAuthorization: () async -> Bool
    let refresh: (ReminderRefreshInput) async -> Void
    let cancel: (Date) -> Void

    static let live = Self(
        requestAuthorization: {
            await NotificationManager.requestAuthorization()
        },
        refresh: { input in
            await NotificationManager.refresh(
                scheduleJSON: input.scheduleJSON,
                sleepMinuteOfDay: input.sleepMinuteOfDay,
                historyJSON: input.historyJSON,
                isEnabled: input.isEnabled
            )
        },
        cancel: { date in
            NotificationManager.cancel(for: date)
        }
    )

    static let disabled = Self(
        requestAuthorization: { false },
        refresh: { _ in },
        cancel: { _ in }
    )
}
