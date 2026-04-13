import SwiftUI

/// SwiftUI counterparts for the most-used UI hex color values.
/// Use these instead of inline `Color(hex: 0x...)` literals.
extension ColorPalette {
    // Primary accent
    static let uiGold = Color(hex: 0xFFD700)
    static let uiAmber = Color(hex: 0xE8A035)

    // Text / secondary
    static let uiCream = Color(hex: 0xCCBB99)
    static let uiBrown = Color(hex: 0x8B7355)
    static let uiDarkBrown = Color(hex: 0x5A4530)

    // Backgrounds
    static let uiListRow = Color(hex: 0x0D1A0C)
    static let uiBackground = Color(hex: 0x061206)
}
