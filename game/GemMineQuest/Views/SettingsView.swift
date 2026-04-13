import SwiftUI

struct SettingsView: View {
    @EnvironmentObject var settingsManager: SettingsManager
    @EnvironmentObject var progressManager: ProgressManager
    @EnvironmentObject var boosterInventory: BoosterInventory
    @EnvironmentObject var localizationManager: LocalizationManager
    @State private var showResetConfirmation = false
    var onDismiss: () -> Void
    private let s = Constants.uiScale

    var body: some View {
        ZStack {
            ColorPalette.uiBackground.ignoresSafeArea()

            VStack(spacing: 0) {
                // Header
                HStack {
                    Button(action: onDismiss) {
                        Image(systemName: "chevron.left")
                            .font(.title3.weight(.bold))
                            .foregroundColor(ColorPalette.uiCream)
                            .padding(12)
                    }
                    Spacer()
                    Text(localizationManager.t("settings.title"))
                        .font(.title2.weight(.bold))
                        .foregroundColor(ColorPalette.uiGold)
                    Spacer()
                    Color.clear.frame(width: 44, height: 44)
                }
                .padding(.horizontal)

                List {
                    // Language section
                    Section {
                        HStack {
                            Image(systemName: "globe")
                                .foregroundColor(ColorPalette.uiGold)
                                .frame(width: 30)
                            Text(localizationManager.t("settings.language"))
                                .foregroundColor(.white)
                            Spacer()
                            HStack(spacing: 8) {
                                LanguageToggleButton(language: .english, flag: AnyView(CartoonEnglishFlag()), labelKey: "settings.langEN")
                                LanguageToggleButton(language: .welsh, flag: AnyView(CartoonWelshFlag()), labelKey: "settings.langCY")
                            }
                        }
                    } header: {
                        Text(localizationManager.t("settings.language"))
                            .foregroundColor(ColorPalette.uiAmber)
                    }
                    .listRowBackground(ColorPalette.uiListRow)

                    #if DEBUG
                    Section {
                        // God Mode toggle
                        HStack {
                            Image(systemName: "infinity")
                                .foregroundColor(ColorPalette.uiGold)
                                .frame(width: 30)
                            Toggle(localizationManager.t("settings.godMode"), isOn: $settingsManager.godModeEnabled)
                                .tint(ColorPalette.uiAmber)
                        }

                        if settingsManager.godModeEnabled {
                            Text(localizationManager.t("settings.godModeDesc"))
                                .font(.caption)
                                .foregroundColor(ColorPalette.uiBrown)
                        }
                    } header: {
                        Text(localizationManager.t("settings.gameplay"))
                            .foregroundColor(ColorPalette.uiAmber)
                    }
                    .listRowBackground(ColorPalette.uiListRow)
                    #endif

                    Section {
                        HStack {
                            Image(systemName: "iphone.radiowaves.left.and.right")
                                .foregroundColor(ColorPalette.uiCream)
                                .frame(width: 30)
                            Toggle(localizationManager.t("settings.hapticFeedback"), isOn: $settingsManager.hapticsEnabled)
                                .tint(ColorPalette.uiAmber)
                        }
                    } header: {
                        Text(localizationManager.t("settings.feedback"))
                            .foregroundColor(ColorPalette.uiAmber)
                    }
                    .listRowBackground(ColorPalette.uiListRow)

                    Section {
                        ForEach(BoosterInventory.allInGameBoosters, id: \.self) { booster in
                            BoosterSettingsRow(booster: booster, inventory: boosterInventory)
                        }
                        Text(localizationManager.t("settings.boosterNote")).font(.caption).foregroundColor(ColorPalette.uiBrown)
                    } header: {
                        Text(localizationManager.t("settings.boosters")).foregroundColor(ColorPalette.uiAmber)
                    }
                    .listRowBackground(ColorPalette.uiListRow)

                    Section {
                        // Progress info
                        HStack {
                            Text(localizationManager.t("settings.highestLevel"))
                                .foregroundColor(.white)
                            Spacer()
                            Text("\(progressManager.progress.highestUnlocked)")
                                .foregroundColor(ColorPalette.uiCream)
                        }

                        HStack {
                            Text(localizationManager.t("settings.levelsCompleted"))
                                .foregroundColor(.white)
                            Spacer()
                            Text("\(progressManager.progress.levelStars.count)")
                                .foregroundColor(ColorPalette.uiCream)
                        }

                        HStack {
                            Text(localizationManager.t("settings.totalStars"))
                                .foregroundColor(.white)
                            Spacer()
                            let totalStars = progressManager.progress.levelStars.values.reduce(0, +)
                            Text("\(totalStars)")
                                .foregroundColor(ColorPalette.uiGold)
                        }
                    } header: {
                        Text(localizationManager.t("settings.progress"))
                            .foregroundColor(ColorPalette.uiAmber)
                    }
                    .listRowBackground(ColorPalette.uiListRow)

                    Section {
                        Button(action: { showResetConfirmation = true }) {
                            HStack {
                                Image(systemName: "exclamationmark.triangle")
                                Text(localizationManager.t("settings.resetAllProgress"))
                            }
                            .foregroundColor(.red)
                        }
                    }
                    .listRowBackground(ColorPalette.uiListRow)
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

// MARK: - Language Toggle Button

private struct LanguageToggleButton: View {
    let language: AppLanguage
    let flag: AnyView
    let labelKey: String
    @EnvironmentObject var localizationManager: LocalizationManager

    var body: some View {
        let isSelected = localizationManager.currentLanguage == language
        Button {
            localizationManager.setLanguage(language)
        } label: {
            HStack(spacing: 4) {
                flag
                    .frame(width: 24, height: 16)
                    .clipShape(RoundedRectangle(cornerRadius: 3))
                Text(localizationManager.t(labelKey))
                    .font(.system(size: 12, weight: .bold))
            }
            .foregroundColor(isSelected ? ColorPalette.uiGold : ColorPalette.uiBrown)
            .padding(.horizontal, 8)
            .padding(.vertical, 6)
            .background(
                RoundedRectangle(cornerRadius: 8)
                    .fill(isSelected ? ColorPalette.uiAmber.opacity(0.2) : Color.clear)
                    .overlay(
                        RoundedRectangle(cornerRadius: 8)
                            .stroke(isSelected ? ColorPalette.uiAmber.opacity(0.5) : ColorPalette.uiDarkBrown.opacity(0.3), lineWidth: 1)
                    )
            )
        }
        .buttonStyle(.plain)
    }
}

// MARK: - Booster Settings Row

struct BoosterSettingsRow: View {
    let booster: BoosterType
    @ObservedObject var inventory: BoosterInventory
    @EnvironmentObject var localizationManager: LocalizationManager
    private let s = Constants.uiScale

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
                        .foregroundColor(inventory.count(for: booster) > 0 ? ColorPalette.uiAmber : ColorPalette.uiDarkBrown)
                }
                .disabled(inventory.count(for: booster) <= 0)
                .buttonStyle(.plain)

                Text("\(inventory.count(for: booster))")
                    .foregroundColor(ColorPalette.uiCream)
                    .frame(minWidth: 20)
                    .monospacedDigit()

                Button {
                    if inventory.count(for: booster) < 5 {
                        inventory.increment(booster)
                    }
                } label: {
                    Image(systemName: "plus.circle.fill")
                        .foregroundColor(inventory.count(for: booster) >= 5 ? ColorPalette.uiDarkBrown : ColorPalette.uiAmber)
                }
                .disabled(inventory.count(for: booster) >= 5)
                .buttonStyle(.plain)

                Text(localizationManager.t("settings.max5"))
                    .font(.system(size: max(9 * s, 10), weight: .medium))
                    .foregroundColor(ColorPalette.uiBrown)
            }
        }
    }
}
