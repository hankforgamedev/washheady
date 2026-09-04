import SwiftUI

struct CharacterEditorFeatureInput {
    var skinTone: Binding<Int>
    var hairTone: Binding<Int>
    var hairStyle: Binding<Int>
    var faceShape: Binding<Int>
    var eyeScale: Binding<Double>
    var eyeYOffset: Binding<Double>
    var mouthStyle: Binding<Int>
}

struct CharacterEditorFeatureModule {
    let makeView: (CharacterEditorFeatureInput) -> AnyView

    static let live = Self { input in
        AnyView(
            CharacterEditorView(
                skinTone: input.skinTone,
                hairTone: input.hairTone,
                hairStyle: input.hairStyle,
                faceShape: input.faceShape,
                eyeScale: input.eyeScale,
                eyeYOffset: input.eyeYOffset,
                mouthStyle: input.mouthStyle
            )
        )
    }
}
