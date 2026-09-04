import SwiftUI

// MARK: - Feature inputs

struct WashInteractionFeatureInput {
    var isPresented: Binding<Bool>
    let messinessLevel: Int
    let appearance: CharacterAppearance
    var trustUser: Binding<Bool>
    let onAbandoned: () -> Void
    let onWashed: (_ trustedAutomatically: Bool) -> Void
}

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

// MARK: - Replaceable feature modules

struct WashInteractionFeatureModule {
    let makeView: (WashInteractionFeatureInput) -> AnyView

    static let live = Self { input in
        AnyView(
            WashInteractionView(
                isPresented: input.isPresented,
                messinessLevel: input.messinessLevel,
                appearance: input.appearance,
                trustUser: input.trustUser,
                onAbandoned: input.onAbandoned,
                onWashed: input.onWashed
            )
        )
    }
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

// MARK: - Composition root

struct AppModules {
    let washInteraction: WashInteractionFeatureModule
    let history: HistoryFeatureModule?
    let characterEditor: CharacterEditorFeatureModule?
    let settings: SettingsFeatureModule?
    let reminders: ReminderServiceModule
    let appIcons: AppIconServiceModule

    static let live = Self(
        washInteraction: .live,
        history: .live,
        characterEditor: .live,
        settings: .live,
        reminders: .live,
        appIcons: .live
    )

    static let coreOnly = Self(
        washInteraction: .live,
        history: nil,
        characterEditor: nil,
        settings: nil,
        reminders: .disabled,
        appIcons: .disabled
    )
}
