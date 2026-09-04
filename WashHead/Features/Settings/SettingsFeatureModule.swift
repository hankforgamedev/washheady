import SwiftUI

struct SettingsFeatureInput {
    var scheduleJSON: Binding<String>
    var sleepMinuteOfDay: Binding<Int>
    var notificationsEnabled: Binding<Bool>
    var trustUser: Binding<Bool>
    var iconSyncEnabled: Binding<Bool>
    let messinessLevel: Int
    let isUnknown: Bool
    let reminders: ReminderServiceModule
    let appIcons: AppIconServiceModule
    let onSettingsChanged: () -> Void
}

struct SettingsFeatureModule {
    let makeView: (SettingsFeatureInput) -> AnyView

    static let live = Self { input in
        AnyView(
            SettingsView(
                scheduleJSON: input.scheduleJSON,
                sleepMinuteOfDay: input.sleepMinuteOfDay,
                notificationsEnabled: input.notificationsEnabled,
                trustUser: input.trustUser,
                iconSyncEnabled: input.iconSyncEnabled,
                messinessLevel: input.messinessLevel,
                isUnknown: input.isUnknown,
                reminders: input.reminders,
                appIcons: input.appIcons,
                onSettingsChanged: input.onSettingsChanged
            )
        )
    }
}
