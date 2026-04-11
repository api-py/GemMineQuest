import SwiftUI

struct SettingsView: View {
    @EnvironmentObject var settingsManager: SettingsManager
    @EnvironmentObject var progressManager: ProgressManager
    @EnvironmentObject var boosterInventory: BoosterInventory
    @EnvironmentObject var localizationManager: LocalizationManager
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
                    Text(localizationManager.t("settings.title"))
                        .font(.title2.weight(.bold))
                        .foregroundColor(Color(hex: 0xFFD700))
                    Spacer()
                    Color.clear.frame(width: 44, height: 44)
                }
                .padding(.horizontal)

                List {
                    // Language section
                    Section {
                        HStack {
                            Image(systemName: "globe")
                                .foregroundColor(Color(hex: 0xFFD700))
                                .frame(width: 30)
                            Text(localizationManager.t("settings.language"))
                                .foregroundColor(.white)
                            Spacer()
                            HStack(spacing: 8) {
                                Button {
                                    localizationManager.setLanguage(.english)
                                } label: {
                                    HStack(spacing: 4) {
                                        CartoonEnglishFlag()
                                            .frame(width: 24, height: 16)
                                            .clipShape(RoundedRectangle(cornerRadius: 3))
                                        Text("EN")
                                            .font(.system(size: 12, weight: .bold))
                                    }
                                    .foregroundColor(localizationManager.currentLanguage == .english ? Color(hex: 0xFFD700) : Color(hex: 0x8B7355))
                                    .padding(.horizontal, 8)
                                    .padding(.vertical, 6)
                                    .background(
                                        RoundedRectangle(cornerRadius: 8)
                                            .fill(localizationManager.currentLanguage == .english
                                                  ? Color(hex: 0xE8A035).opacity(0.2)
                                                  : Color.clear)
                                            .overlay(
                                                RoundedRectangle(cornerRadius: 8)
                                                    .stroke(localizationManager.currentLanguage == .english
                                                            ? Color(hex: 0xE8A035).opacity(0.5)
                                                            : Color(hex: 0x5A4530).opacity(0.3), lineWidth: 1)
                                            )
                                    )
                                }
                                .buttonStyle(.plain)

                                Button {
                                    localizationManager.setLanguage(.welsh)
                                } label: {
                                    HStack(spacing: 4) {
                                        CartoonWelshFlag()
                                            .frame(width: 24, height: 16)
                                            .clipShape(RoundedRectangle(cornerRadius: 3))
                                        Text("CY")
                                            .font(.system(size: 12, weight: .bold))
                                    }
                                    .foregroundColor(localizationManager.currentLanguage == .welsh ? Color(hex: 0xFFD700) : Color(hex: 0x8B7355))
                                    .padding(.horizontal, 8)
                                    .padding(.vertical, 6)
                                    .background(
                                        RoundedRectangle(cornerRadius: 8)
                                            .fill(localizationManager.currentLanguage == .welsh
                                                  ? Color(hex: 0xE8A035).opacity(0.2)
                                                  : Color.clear)
                                            .overlay(
                                                RoundedRectangle(cornerRadius: 8)
                                                    .stroke(localizationManager.currentLanguage == .welsh
                                                            ? Color(hex: 0xE8A035).opacity(0.5)
                                                            : Color(hex: 0x5A4530).opacity(0.3), lineWidth: 1)
                                            )
                                    )
                                }
                                .buttonStyle(.plain)
                            }
                        }
                    } header: {
                        Text(localizationManager.t("settings.language"))
                            .foregroundColor(Color(hex: 0xE8A035))
                    }
                    .listRowBackground(Color(hex: 0x0D1A0C))

                    #if DEBUG
                    Section {
                        // God Mode toggle
                        HStack {
                            Image(systemName: "infinity")
                                .foregroundColor(Color(hex: 0xFFD700))
                                .frame(width: 30)
                            Toggle(localizationManager.t("settings.godMode"), isOn: $settingsManager.godModeEnabled)
                                .tint(Color(hex: 0xE8A035))
                        }

                        if settingsManager.godModeEnabled {
                            Text(localizationManager.t("settings.godModeDesc"))
                                .font(.caption)
                                .foregroundColor(Color(hex: 0x8B7355))
                        }
                    } header: {
                        Text(localizationManager.t("settings.gameplay"))
                            .foregroundColor(Color(hex: 0xE8A035))
                    }
                    .listRowBackground(Color(hex: 0x0D1A0C))
                    #endif

                    Section {
                        HStack {
                            Image(systemName: "iphone.radiowaves.left.and.right")
                                .foregroundColor(Color(hex: 0xCCBB99))
                                .frame(width: 30)
                            Toggle(localizationManager.t("settings.hapticFeedback"), isOn: $settingsManager.hapticsEnabled)
                                .tint(Color(hex: 0xE8A035))
                        }
                    } header: {
                        Text(localizationManager.t("settings.feedback"))
                            .foregroundColor(Color(hex: 0xE8A035))
                    }
                    .listRowBackground(Color(hex: 0x0D1A0C))

                    Section {
                        ForEach(BoosterInventory.allInGameBoosters, id: \.self) { booster in
                            BoosterSettingsRow(booster: booster, inventory: boosterInventory)
                        }
                        Text(localizationManager.t("settings.boosterNote")).font(.caption).foregroundColor(Color(hex: 0x8B7355))
                    } header: {
                        Text(localizationManager.t("settings.boosters")).foregroundColor(Color(hex: 0xE8A035))
                    }
                    .listRowBackground(Color(hex: 0x0D1A0C))

                    Section {
                        // Progress info
                        HStack {
                            Text(localizationManager.t("settings.highestLevel"))
                                .foregroundColor(.white)
                            Spacer()
                            Text("\(progressManager.progress.highestUnlocked)")
                                .foregroundColor(Color(hex: 0xCCBB99))
                        }

                        HStack {
                            Text(localizationManager.t("settings.levelsCompleted"))
                                .foregroundColor(.white)
                            Spacer()
                            Text("\(progressManager.progress.levelStars.count)")
                                .foregroundColor(Color(hex: 0xCCBB99))
                        }

                        HStack {
                            Text(localizationManager.t("settings.totalStars"))
                                .foregroundColor(.white)
                            Spacer()
                            let totalStars = progressManager.progress.levelStars.values.reduce(0, +)
                            Text("\(totalStars)")
                                .foregroundColor(Color(hex: 0xFFD700))
                        }
                    } header: {
                        Text(localizationManager.t("settings.progress"))
                            .foregroundColor(Color(hex: 0xE8A035))
                    }
                    .listRowBackground(Color(hex: 0x0D1A0C))

                    Section {
                        Button(action: { showResetConfirmation = true }) {
                            HStack {
                                Image(systemName: "exclamationmark.triangle")
                                Text(localizationManager.t("settings.resetAllProgress"))
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
        .alert(localizationManager.t("settings.resetProgress"), isPresented: $showResetConfirmation) {
            Button(localizationManager.t("settings.cancel"), role: .cancel) {}
            Button(localizationManager.t("settings.reset"), role: .destructive) {
                progressManager.resetProgress()
                boosterInventory.reset()
            }
        } message: {
            Text(localizationManager.t("settings.resetMessage"))
        }
    }
}

// MARK: - Booster Settings Row

struct BoosterSettingsRow: View {
    let booster: BoosterType
    @ObservedObject var inventory: BoosterInventory
    @EnvironmentObject var localizationManager: LocalizationManager

    private var icon: String {
        booster.iconAssetName
    }

    private var label: String {
        switch booster {
        case .pickaxe: return localizationManager.t("booster.pickaxe")
        case .dynamite: return localizationManager.t("booster.dynamite")
        case .gemForge: return localizationManager.t("booster.gemForge")
        case .droneStrike: return localizationManager.t("booster.droneStrike")
        case .mineCartRush: return localizationManager.t("booster.mineCartRush")
        default: return booster.rawValue
        }
    }

    var body: some View {
        HStack {
            Image(icon)
                .resizable()
                .scaledToFit()
                .frame(width: 24, height: 24)
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

                Text(localizationManager.t("settings.max5"))
                    .font(.system(size: 9, weight: .medium))
                    .foregroundColor(Color(hex: 0x8B7355))
            }
        }
    }
}
