import SwiftUI

struct WashQuestionFeatureInput {
    let onClose: () -> Void
    let onSkip: () -> Void
    let onWash: () -> Void
}

struct WashInteractionFeatureInput {
    var isPresented: Binding<Bool>
    let messinessLevel: Int
    let appearance: CharacterAppearance
    var trustUser: Binding<Bool>
    let onAbandoned: () -> Void
    let onWashed: (_ trustedAutomatically: Bool) -> Void
}

struct WashFeatureModule {
    let makeQuestion: (WashQuestionFeatureInput) -> AnyView
    let makeInteraction: (WashInteractionFeatureInput) -> AnyView

    static let live = Self(
        makeQuestion: { input in
            AnyView(
                WashQuestionView(
                    onClose: input.onClose,
                    onSkip: input.onSkip,
                    onWash: input.onWash
                )
            )
        },
        makeInteraction: { input in
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
    )
}
