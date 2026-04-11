import SwiftUI

@main
struct GemMineQuestApp: App {
    @StateObject private var progressManager = ProgressManager()
    @StateObject private var settingsManager = SettingsManager()
    @StateObject private var boosterInventory = BoosterInventory()
    @StateObject private var localizationManager = LocalizationManager()

    var body: some Scene {
        WindowGroup {
            ContentView()
                .environmentObject(progressManager)
                .environmentObject(settingsManager)
                .environmentObject(boosterInventory)
                .environmentObject(localizationManager)
                .preferredColorScheme(.dark)
        }
    }
}
