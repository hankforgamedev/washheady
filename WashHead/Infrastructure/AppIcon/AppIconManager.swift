import UIKit

@MainActor
enum AppIconManager {
    static func sync(messinessLevel: Int, isUnknown: Bool) {
        let application = UIApplication.shared
        guard application.supportsAlternateIcons else { return }

        let desiredName: String?
        if isUnknown {
            desiredName = "AppIconUnknown"
        } else if messinessLevel >= 3 {
            desiredName = "AppIconMax"
        } else if messinessLevel >= 1 {
            desiredName = "AppIconPuffy"
        } else {
            desiredName = nil
        }

        guard application.alternateIconName != desiredName else { return }
        application.setAlternateIconName(desiredName) { error in
            if let error {
                print("Unable to update app icon: \(error.localizedDescription)")
            }
        }
    }
}
