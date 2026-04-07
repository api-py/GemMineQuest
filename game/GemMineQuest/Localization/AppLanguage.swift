import Foundation

enum AppLanguage: String, CaseIterable, Codable {
    case english = "en"
    case welsh = "cy"

    var displayName: String {
        switch self {
        case .english: return "English"
        case .welsh: return "Cymraeg"
        }
    }
}
