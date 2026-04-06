import SwiftUI

class SettingsManager: ObservableObject {
    @AppStorage("godModeEnabled") var godModeEnabled: Bool = false  // TODO: Remove for production
    @AppStorage("hapticsEnabled") var hapticsEnabled: Bool = true

    static let shared = SettingsManager()
}
