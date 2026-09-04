import UIKit

struct AppIconState {
    let messinessLevel: Int
    let isUnknown: Bool
}

struct AppIconServiceModule {
    let isSupported: @MainActor () -> Bool
    let sync: @MainActor (AppIconState) -> Void

    static let live = Self(
        isSupported: {
            UIApplication.shared.supportsAlternateIcons
        },
        sync: { state in
            AppIconManager.sync(
                messinessLevel: state.messinessLevel,
                isUnknown: state.isUnknown
            )
        }
    )

    static let disabled = Self(
        isSupported: { false },
        sync: { _ in }
    )
}
