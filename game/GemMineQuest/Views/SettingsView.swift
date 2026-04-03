import SwiftUI

struct SettingsView: View {
    @EnvironmentObject var settingsManager: SettingsManager
    @EnvironmentObject var progressManager: ProgressManager
    @State private var showResetConfirmation = false
    var onDismiss: () -> Void

    var body: some View {
        ZStack {
            Color(hex: 0x1A0F0A).ignoresSafeArea()

            VStack(spacing: 0) {
                // Header
                HStack {
                    Button(action: onDismiss) {
                        Image(systemName: "chevron.left")
                            .font(.title3.weight(.bold))
                            .foregroundColor(Color(hex: 0xCCBB99))
                            .padding(12)
                    }
                    Spacer()
                    Text("Settings")
                        .font(.title2.weight(.bold))
                        .foregroundColor(Color(hex: 0xFFD700))
                    Spacer()
                    Color.clear.frame(width: 44, height: 44)
                }
                .padding(.horizontal)

                List {
                    Section {
                        // God Mode toggle
                        HStack {
                            Image(systemName: "infinity")
                                .foregroundColor(Color(hex: 0xFFD700))
                                .frame(width: 30)
                            Toggle("God Mode", isOn: $settingsManager.godModeEnabled)
                                .tint(Color(hex: 0xE8A035))
                        }

                        if settingsManager.godModeEnabled {
                            Text("Unlimited moves - for casual play")
                                .font(.caption)
                                .foregroundColor(Color(hex: 0x8B7355))
                        }
                    } header: {
                        Text("Gameplay")
                            .foregroundColor(Color(hex: 0xE8A035))
                    }
                    .listRowBackground(Color(hex: 0x2D1B12))

                    Section {
                        HStack {
                            Image(systemName: "iphone.radiowaves.left.and.right")
                                .foregroundColor(Color(hex: 0xCCBB99))
                                .frame(width: 30)
                            Toggle("Haptic Feedback", isOn: $settingsManager.hapticsEnabled)
                                .tint(Color(hex: 0xE8A035))
                        }
                    } header: {
                        Text("Feedback")
                            .foregroundColor(Color(hex: 0xE8A035))
                    }
                    .listRowBackground(Color(hex: 0x2D1B12))

                    Section {
                        // Progress info
                        HStack {
                            Text("Highest Level")
                                .foregroundColor(.white)
                            Spacer()
                            Text("\(progressManager.progress.highestUnlocked)")
                                .foregroundColor(Color(hex: 0xCCBB99))
                        }

                        HStack {
                            Text("Levels Completed")
                                .foregroundColor(.white)
                            Spacer()
                            Text("\(progressManager.progress.levelStars.count)")
                                .foregroundColor(Color(hex: 0xCCBB99))
                        }

                        HStack {
                            Text("Total Stars")
                                .foregroundColor(.white)
                            Spacer()
                            let totalStars = progressManager.progress.levelStars.values.reduce(0, +)
                            Text("\(totalStars)")
                                .foregroundColor(Color(hex: 0xFFD700))
                        }
                    } header: {
                        Text("Progress")
                            .foregroundColor(Color(hex: 0xE8A035))
                    }
                    .listRowBackground(Color(hex: 0x2D1B12))

                    Section {
                        Button(action: { showResetConfirmation = true }) {
                            HStack {
                                Image(systemName: "exclamationmark.triangle")
                                Text("Reset All Progress")
                            }
                            .foregroundColor(.red)
                        }
                    }
                    .listRowBackground(Color(hex: 0x2D1B12))
                }
                .scrollContentBackground(.hidden)
                .listStyle(.insetGrouped)
            }
        }
        .alert("Reset Progress?", isPresented: $showResetConfirmation) {
            Button("Cancel", role: .cancel) {}
            Button("Reset", role: .destructive) {
                progressManager.resetProgress()
            }
        } message: {
            Text("This will erase all your level progress and scores. This cannot be undone.")
        }
    }
}
