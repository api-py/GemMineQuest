import SwiftUI

class SettingsManager: ObservableObject {
    #if DEBUG
    @AppStorage("godModeEnabled") var godModeEnabled: Bool = false
    #else
    let godModeEnabled: Bool = false
    #endif
    @AppStorage("hapticsEnabled") var hapticsEnabled: Bool = true

    static let shared = SettingsManager()
}
