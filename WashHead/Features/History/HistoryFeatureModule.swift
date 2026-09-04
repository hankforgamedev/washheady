import SwiftUI

struct HistoryFeatureInput {
    var historyJSON: Binding<String>
    let onRecordsChanged: () -> Void
}

struct HistoryFeatureModule {
    let makeView: (HistoryFeatureInput) -> AnyView

    static let live = Self { input in
        AnyView(
            HistoryView(
                historyJSON: input.historyJSON,
                onRecordsChanged: input.onRecordsChanged
            )
        )
    }
}
