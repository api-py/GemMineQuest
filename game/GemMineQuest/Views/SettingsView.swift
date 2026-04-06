import SwiftUI

struct SettingsView: View {
    @EnvironmentObject var settingsManager: SettingsManager
    @EnvironmentObject var progressManager: ProgressManager
    @EnvironmentObject var boosterInventory: BoosterInventory
    @State private var showResetConfirmation = false
    var onDismiss: () -> Void

    var body: some View {
        ZStack {
            Color(hex: 0x061206).ignoresSafeArea()

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
                    #if DEBUG
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
                    .listRowBackground(Color(hex: 0x0D1A0C))
                    #endif

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
                    .listRowBackground(Color(hex: 0x0D1A0C))

                    Section {
                        ForEach(BoosterInventory.allInGameBoosters, id: \.self) { booster in
                            BoosterSettingsRow(booster: booster, inventory: boosterInventory)
                        }
                        Text("+1 of each every 25 levels").font(.caption).foregroundColor(Color(hex: 0x8B7355))
                    } header: {
                        Text("Boosters").foregroundColor(Color(hex: 0xE8A035))
                    }
                    .listRowBackground(Color(hex: 0x0D1A0C))

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
                    .listRowBackground(Color(hex: 0x0D1A0C))

                    Section {
                        Button(action: { showResetConfirmation = true }) {
                            HStack {
                                Image(systemName: "exclamationmark.triangle")
                                Text("Reset All Progress")
                            }
                            .foregroundColor(.red)
                        }
                    }
                    .listRowBackground(Color(hex: 0x0D1A0C))
                }
                .scrollContentBackground(.hidden)
                .listStyle(.insetGrouped)
            }
        }
        .alert("Reset Progress?", isPresented: $showResetConfirmation) {
            Button("Cancel", role: .cancel) {}
            Button("Reset", role: .destructive) {
                progressManager.resetProgress()
                boosterInventory.reset()
            }
        } message: {
            Text("This will erase all your level progress and scores. This cannot be undone.")
        }
    }
}

// MARK: - Booster Settings Row

struct BoosterSettingsRow: View {
    let booster: BoosterType
    @ObservedObject var inventory: BoosterInventory

    private var icon: String {
        switch booster {
        case .pickaxe: return "hammer.fill"
        case .dynamite: return "flame.fill"
        case .gemForge: return "wand.and.stars"
        case .droneStrike: return "scope"
        case .mineCartRush: return "bolt.horizontal.fill"
        default: return "questionmark"
        }
    }

    private var label: String {
        switch booster {
        case .pickaxe: return "Pickaxe"
        case .dynamite: return "Dynamite"
        case .gemForge: return "Gem Forge"
        case .droneStrike: return "Drone Strike"
        case .mineCartRush: return "Mine Cart Rush"
        default: return booster.rawValue
        }
    }

    var body: some View {
        HStack {
            Image(systemName: icon)
                .foregroundColor(Color(hex: 0xE8A035))
                .frame(width: 24)
            Text(label).foregroundColor(.white)
            Spacer()
            HStack(spacing: 12) {
                Button {
                    inventory.decrement(booster)
                } label: {
                    Image(systemName: "minus.circle.fill")
                        .foregroundColor(inventory.count(for: booster) > 0 ? Color(hex: 0xE8A035) : Color(hex: 0x5A4530))
                }
                .disabled(inventory.count(for: booster) <= 0)
                .buttonStyle(.plain)

                Text("\(inventory.count(for: booster))")
                    .foregroundColor(Color(hex: 0xCCBB99))
                    .frame(minWidth: 20)
                    .monospacedDigit()

                Button {
                    if inventory.count(for: booster) < 5 {
                        inventory.increment(booster)
                    }
                } label: {
                    Image(systemName: "plus.circle.fill")
                        .foregroundColor(inventory.count(for: booster) >= 5 ? Color(hex: 0x5A4530) : Color(hex: 0xE8A035))
                }
                .disabled(inventory.count(for: booster) >= 5)
                .buttonStyle(.plain)

                Text("Max: 5")
                    .font(.system(size: 9, weight: .medium))
                    .foregroundColor(Color(hex: 0x8B7355))
            }
        }
    }
}
