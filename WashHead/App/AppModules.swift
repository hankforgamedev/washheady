struct AppModules {
    let wash: WashFeatureModule
    let history: HistoryFeatureModule?
    let characterEditor: CharacterEditorFeatureModule?
    let settings: SettingsFeatureModule?
    let reminders: ReminderServiceModule
    let appIcons: AppIconServiceModule

    static let live = Self(
        wash: .live,
        history: .live,
        characterEditor: .live,
        settings: .live,
        reminders: .live,
        appIcons: .live
    )

    static let coreOnly = Self(
        wash: .live,
        history: nil,
        characterEditor: nil,
        settings: nil,
        reminders: .disabled,
        appIcons: .disabled
    )
}
