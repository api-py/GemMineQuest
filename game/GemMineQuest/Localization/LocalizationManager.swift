import SwiftUI

class LocalizationManager: ObservableObject {
    @AppStorage("selectedLanguage") private var storedLanguage: String = AppLanguage.english.rawValue
    @AppStorage("hasSelectedLanguage") var hasSelectedLanguage: Bool = false

    @Published var currentLanguage: AppLanguage = .english

    static let shared = LocalizationManager()

    init() {
        currentLanguage = AppLanguage(rawValue: storedLanguage) ?? .english
    }

    func setLanguage(_ language: AppLanguage) {
        currentLanguage = language
        storedLanguage = language.rawValue
        hasSelectedLanguage = true
    }

    private var strings: [String: String] {
        switch currentLanguage {
        case .english: return englishStrings
        case .welsh: return welshStrings
        }
    }

    /// Look up a translation by key
    func t(_ key: String) -> String {
        strings[key] ?? key
    }

    /// Look up a translation with format arguments
    func t(_ key: String, _ args: CVarArg...) -> String {
        let format = strings[key] ?? key
        return String(format: format, arguments: args)
    }
}
