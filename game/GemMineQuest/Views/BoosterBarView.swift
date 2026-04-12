import SwiftUI

struct BoosterBarView: View {
    @ObservedObject var inventory: BoosterInventory
    @EnvironmentObject var localizationManager: LocalizationManager
    var onBoosterSelected: (BoosterType) -> Void
    @State private var showingHint: BoosterType?

    var body: some View {
        VStack(spacing: 6) {
            // Hint popup
            if let hint = showingHint {
                Text(hintText(for: hint))
                    .font(.system(size: 12, weight: .medium))
                    .foregroundColor(.white)
                    .padding(.horizontal, 14)
                    .padding(.vertical, 8)
                    .background(
                        RoundedRectangle(cornerRadius: 10)
                            .fill(Color.black.opacity(0.85))
                            .overlay(
                                RoundedRectangle(cornerRadius: 10)
                                    .stroke(Color(hex: 0xC9A84C).opacity(0.3), lineWidth: 1)
                            )
                    )
                    .transition(.scale.combined(with: .opacity))
            }

            HStack(spacing: 10) {
                BoosterButton(icon: BoosterType.pickaxe.iconAssetName, label: localizationManager.t("booster.pickaxeShort"), hint: localizationManager.t("booster.pickaxeHintShort"),
                              count: inventory.count(for: .pickaxe), godMode: inventory.godModeActive,
                              onTap: { onBoosterSelected(.pickaxe) },
                              onLongPress: { withAnimation { showingHint = .pickaxe }; dismissHint() })
                BoosterButton(icon: BoosterType.dynamite.iconAssetName, label: localizationManager.t("booster.dynamiteShort"), hint: localizationManager.t("booster.dynamiteHintShort"),
                              count: inventory.count(for: .dynamite), godMode: inventory.godModeActive,
                              onTap: { onBoosterSelected(.dynamite) },
                              onLongPress: { withAnimation { showingHint = .dynamite }; dismissHint() })
                BoosterButton(icon: BoosterType.gemForge.iconAssetName, label: localizationManager.t("booster.forgeShort"), hint: localizationManager.t("booster.forgeHintShort"),
                              count: inventory.count(for: .gemForge), godMode: inventory.godModeActive,
                              onTap: { onBoosterSelected(.gemForge) },
                              onLongPress: { withAnimation { showingHint = .gemForge }; dismissHint() })
                BoosterButton(icon: BoosterType.droneStrike.iconAssetName, label: localizationManager.t("booster.droneShort"), hint: localizationManager.t("booster.droneHintShort"),
                              count: inventory.count(for: .droneStrike), godMode: inventory.godModeActive,
                              onTap: { onBoosterSelected(.droneStrike) },
                              onLongPress: { withAnimation { showingHint = .droneStrike }; dismissHint() })
                BoosterButton(icon: BoosterType.mineCartRush.iconAssetName, label: localizationManager.t("booster.cartShort"), hint: localizationManager.t("booster.cartHintShort"),
                              count: inventory.count(for: .mineCartRush), godMode: inventory.godModeActive,
                              onTap: { onBoosterSelected(.mineCartRush) },
                              onLongPress: { withAnimation { showingHint = .mineCartRush }; dismissHint() })
            }
        }
        .padding(.horizontal, 14)
        .padding(.vertical, 10)
        .background(
            ZStack {
                RoundedRectangle(cornerRadius: 18)
                    .fill(
                        LinearGradient(
                            colors: [Color(hex: 0x1A2E18).opacity(0.95), Color(hex: 0x0D1A0C).opacity(0.95)],
                            startPoint: .top, endPoint: .bottom
                        )
                    )
                RoundedRectangle(cornerRadius: 18)
                    .stroke(
                        LinearGradient(
                            colors: [Color(hex: 0xC9A84C).opacity(0.4), Color(hex: 0x6B4F3A).opacity(0.2)],
                            startPoint: .top, endPoint: .bottom
                        ),
                        lineWidth: 1.5
                    )
            }
            .shadow(color: .black.opacity(0.4), radius: 8, y: 4)
        )
    }

    private func dismissHint() {
        DispatchQueue.main.asyncAfter(deadline: .now() + 2.5) {
            withAnimation { showingHint = nil }
        }
    }

    private func hintText(for type: BoosterType) -> String {
        switch type {
        case .pickaxe: return localizationManager.t("booster.pickaxeHint")
        case .dynamite: return localizationManager.t("booster.dynamiteHint")
        case .gemForge: return localizationManager.t("booster.gemForgeHint")
        case .droneStrike: return localizationManager.t("booster.droneStrikeHint")
        case .mineCartRush: return localizationManager.t("booster.mineCartRushHint")
        default: return ""
        }
    }
}

struct BoosterButton: View {
    let icon: String
    let label: String
    let hint: String
    let count: Int
    let godMode: Bool
    let onTap: () -> Void
    let onLongPress: () -> Void

    private var isAvailable: Bool { count > 0 || godMode }
    private let s = Constants.uiScale  // iPad: 1.5, iPhone: 1.0

    var body: some View {
        Button(action: onTap) {
            VStack(spacing: 2 * s) {
                ZStack(alignment: .topTrailing) {
                    ZStack {
                        // Outer ring
                        Circle()
                            .fill(
                                LinearGradient(
                                    colors: isAvailable
                                        ? [Color(hex: 0x2A4E28), Color(hex: 0x1A2E18)]
                                        : [Color(hex: 0x151F12), Color(hex: 0x0A150A)],
                                    startPoint: .top, endPoint: .bottom
                                )
                            )
                            .frame(width: 40 * s, height: 40 * s)

                        // Inner circle with icon
                        Circle()
                            .fill(
                                RadialGradient(
                                    colors: isAvailable
                                        ? [Color(hex: 0x2A4E28).opacity(0.8), Color(hex: 0x1A2E18)]
                                        : [Color(hex: 0x151F12), Color(hex: 0x0A150A)],
                                    center: .center, startRadius: 0, endRadius: 18 * s
                                )
                            )
                            .frame(width: 36 * s, height: 36 * s)
                            .overlay(
                                Circle()
                                    .stroke(
                                        isAvailable
                                            ? Color(hex: 0xC9A84C).opacity(0.3)
                                            : Color.clear,
                                        lineWidth: 1
                                    )
                            )

                        Image(icon)
                            .resizable()
                            .scaledToFit()
                            .frame(width: 24 * s, height: 24 * s)
                            .opacity(isAvailable ? 1.0 : 0.4)

                        // Shine sweep (top highlight)
                        if isAvailable {
                            Ellipse()
                                .fill(Color.white.opacity(0.12))
                                .frame(width: 22 * s, height: 8 * s)
                                .offset(y: -10 * s)
                        }
                    }

                    // Count badge
                    Text(godMode ? "\u{221E}" : "\(count)")
                        .font(.system(size: 8 * s, weight: .bold))
                        .foregroundColor(.white)
                        .frame(minWidth: 16 * s, minHeight: 16 * s)
                        .background(
                            Circle()
                                .fill(
                                    godMode ? Color(hex: 0xC71414)
                                    : (count > 0 ? Color(hex: 0xE8A035) : Color.gray.opacity(0.4))
                                )
                                .overlay(
                                    Circle()
                                        .stroke(Color.black.opacity(0.3), lineWidth: 0.5)
                                )
                        )
                        .offset(x: 4 * s, y: -4 * s)
                }

                Text(label)
                    .font(.system(size: 8 * s, weight: .semibold))
                    .foregroundColor(isAvailable ? Color(hex: 0xCCDDCC) : Color(hex: 0x5A4530))

                Text(hint)
                    .font(.system(size: 6 * s))
                    .foregroundColor(Color(hex: 0x8B7355))
            }
        }
        .disabled(!isAvailable)
        .simultaneousGesture(
            LongPressGesture(minimumDuration: 0.5)
                .onEnded { _ in onLongPress() }
        )
    }
}
