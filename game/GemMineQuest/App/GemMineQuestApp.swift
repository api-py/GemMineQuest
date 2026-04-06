import SwiftUI

@main
struct GemMineQuestApp: App {
    @StateObject private var progressManager = ProgressManager()
    @StateObject private var settingsManager = SettingsManager()
    @StateObject private var boosterInventory = BoosterInventory()

    var body: some Scene {
        WindowGroup {
            ContentView()
                .environmentObject(progressManager)
                .environmentObject(settingsManager)
                .environmentObject(boosterInventory)
                .preferredColorScheme(.dark)
        }
    }
}
