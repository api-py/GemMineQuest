import SwiftUI

class SettingsManager: ObservableObject {
    @AppStorage("godModeEnabled") var godModeEnabled: Bool = false
    @AppStorage("hapticsEnabled") var hapticsEnabled: Bool = true

    static let shared = SettingsManager()
}
