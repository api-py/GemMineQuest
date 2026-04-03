import SwiftUI

class SettingsViewModel: ObservableObject {
    let settings: SettingsManager
    let progressManager: ProgressManager
    @Published var showResetConfirmation = false

    init(settings: SettingsManager, progressManager: ProgressManager) {
        self.settings = settings
        self.progressManager = progressManager
    }

    func resetProgress() {
        progressManager.resetProgress()
    }
}
