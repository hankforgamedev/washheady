import Foundation

enum WashStatus: String, Codable, CaseIterable {
    case none
    case washed
    case notWashed = "not_washed"
    case unknown
}
