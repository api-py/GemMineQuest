import SwiftUI

@main
struct GemMineQuestApp: App {
    @StateObject private var progressManager = ProgressManager()
    @StateObject private var settingsManager = SettingsManager()

    var body: some Scene {
        WindowGroup {
            ContentView()
                .environmentObject(progressManager)
                .environmentObject(settingsManager)
                .preferredColorScheme(.dark)
        }
    }
}
