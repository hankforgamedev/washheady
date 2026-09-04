struct AppModules {
    let wash: WashFeatureModule
    let history: HistoryFeatureModule?
    let characterEditor: CharacterEditorFeatureModule?
    let settings: SettingsFeatureModule?
    let storefront: StorefrontFeatureModule?
    let reminders: ReminderServiceModule
    let appIcons: AppIconServiceModule

    static let live = Self(
        wash: .live,
        history: .live,
        characterEditor: .live,
        settings: .live,
        storefront: nil,
        reminders: .live,
        appIcons: .live
    )

    static let coreOnly = Self(
        wash: .live,
        history: nil,
        characterEditor: nil,
        settings: nil,
        storefront: nil,
        reminders: .disabled,
        appIcons: .disabled
    )
}
