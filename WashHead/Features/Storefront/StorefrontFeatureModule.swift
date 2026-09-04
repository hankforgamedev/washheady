import SwiftUI

struct StorefrontFeatureModule {
    let makeView: () -> AnyView

    static func live(productIDs: [String]) -> Self {
        Self {
            AnyView(StorefrontView(productIDs: productIDs))
        }
    }
}
