import XCTest
@testable import GemMineQuest

@MainActor
final class LocalizationTests: XCTestCase {

    func testAllEnglishKeysExistInWelsh() {
        let missingKeys = englishStrings.keys.filter { welshStrings[$0] == nil }
        XCTAssertTrue(missingKeys.isEmpty, "Welsh translations missing for keys: \(missingKeys.sorted().joined(separator: ", "))")
    }

    func testAllWelshKeysExistInEnglish() {
        let extraKeys = welshStrings.keys.filter { englishStrings[$0] == nil }
        XCTAssertTrue(extraKeys.isEmpty, "Welsh has extra keys not in English: \(extraKeys.sorted().joined(separator: ", "))")
    }

    func testDefaultLanguageIsEnglish() {
        let manager = LocalizationManager()
        XCTAssertEqual(manager.currentLanguage, .english)
    }

    func testLanguageSwitching() {
        let manager = LocalizationManager()
        manager.setLanguage(.welsh)
        XCTAssertEqual(manager.currentLanguage, .welsh)

        manager.setLanguage(.english)
        XCTAssertEqual(manager.currentLanguage, .english)
    }

    func testTranslationLookup() {
        let manager = LocalizationManager()

        // English
        manager.setLanguage(.english)
        XCTAssertEqual(manager.t("menu.shop"), "Shop")
        XCTAssertEqual(manager.t("menu.settings"), "Settings")

        // Welsh
        manager.setLanguage(.welsh)
        XCTAssertEqual(manager.t("menu.shop"), "Siop")
        XCTAssertEqual(manager.t("menu.settings"), "Gosodiadau")
    }

    func testFormattedTranslation() {
        let manager = LocalizationManager()

        // English formatted
        manager.setLanguage(.english)
        let enResult = manager.t("gameOver.levelComplete", 5)
        XCTAssertEqual(enResult, "Level 5 Complete!")

        // Welsh formatted
        manager.setLanguage(.welsh)
        let cyResult = manager.t("gameOver.levelComplete", 5)
        XCTAssertEqual(cyResult, "Lefel 5 Wedi'i Chwblhau!")
    }

    func testMissingKeyReturnsKey() {
        let manager = LocalizationManager()
        let result = manager.t("nonexistent.key")
        XCTAssertEqual(result, "nonexistent.key")
    }

    func testHasSelectedLanguageFlag() {
        let manager = LocalizationManager()
        // Initially false (clean state)
        // After setting language, should be true
        manager.setLanguage(.welsh)
        XCTAssertTrue(manager.hasSelectedLanguage)
    }

    func testNoEmptyTranslations() {
        let emptyEnglish = englishStrings.filter { $0.value.isEmpty }
        XCTAssertTrue(emptyEnglish.isEmpty, "English has empty translations: \(emptyEnglish.keys.sorted())")

        let emptyWelsh = welshStrings.filter { $0.value.isEmpty }
        XCTAssertTrue(emptyWelsh.isEmpty, "Welsh has empty translations: \(emptyWelsh.keys.sorted())")
    }

    func testAppLanguageEnum() {
        XCTAssertEqual(AppLanguage.english.rawValue, "en")
        XCTAssertEqual(AppLanguage.welsh.rawValue, "cy")
        XCTAssertEqual(AppLanguage.allCases.count, 2)
    }
}
