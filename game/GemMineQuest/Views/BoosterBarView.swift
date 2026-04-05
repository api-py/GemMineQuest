import SwiftUI

struct BoosterBarView: View {
    @ObservedObject var inventory: BoosterInventory
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
                BoosterButton(icon: "hammer.fill", label: "Pickaxe", hint: "Break 1",
                              count: inventory.count(for: .pickaxe), godMode: inventory.godModeActive,
                              onTap: { onBoosterSelected(.pickaxe) },
                              onLongPress: { withAnimation { showingHint = .pickaxe }; dismissHint() })
                BoosterButton(icon: "flame.fill", label: "Dynamite", hint: "Blast 3x3",
                              count: inventory.count(for: .dynamite), godMode: inventory.godModeActive,
                              onTap: { onBoosterSelected(.dynamite) },
                              onLongPress: { withAnimation { showingHint = .dynamite }; dismissHint() })
                BoosterButton(icon: "wand.and.stars", label: "Forge", hint: "Place specials",
                              count: inventory.count(for: .gemForge), godMode: inventory.godModeActive,
                              onTap: { onBoosterSelected(.gemForge) },
                              onLongPress: { withAnimation { showingHint = .gemForge }; dismissHint() })
                BoosterButton(icon: "arrow.left.arrow.right", label: "Swap", hint: "Free swap",
                              count: inventory.count(for: .swapCharge), godMode: inventory.godModeActive,
                              onTap: { onBoosterSelected(.swapCharge) },
                              onLongPress: { withAnimation { showingHint = .swapCharge }; dismissHint() })
                BoosterButton(icon: "scope", label: "Drone", hint: "Seek 5",
                              count: inventory.count(for: .droneStrike), godMode: inventory.godModeActive,
                              onTap: { onBoosterSelected(.droneStrike) },
                              onLongPress: { withAnimation { showingHint = .droneStrike }; dismissHint() })
                BoosterButton(icon: "bolt.horizontal.fill", label: "Cart", hint: "Row clear",
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
        case .pickaxe: return "Pickaxe — Tap any gem to destroy it instantly"
        case .dynamite: return "Dynamite — Tap to blast a 3x3 area"
        case .gemForge: return "Gem Forge — Places a Crystal Ball and Volatile gem"
        case .swapCharge: return "Swap Charge — Swap any two gems, no move cost"
        case .droneStrike: return "Drone Strike — 5 seekers target random gems"
        case .mineCartRush: return "Mine Cart Rush — Converts a row to laser gems"
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

    var body: some View {
        Button(action: onTap) {
            VStack(spacing: 2) {
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
                            .frame(width: 40, height: 40)

                        // Inner circle with icon
                        Circle()
                            .fill(
                                RadialGradient(
                                    colors: isAvailable
                                        ? [Color(hex: 0x2A4E28).opacity(0.8), Color(hex: 0x1A2E18)]
                                        : [Color(hex: 0x151F12), Color(hex: 0x0A150A)],
                                    center: .center, startRadius: 0, endRadius: 18
                                )
                            )
                            .frame(width: 36, height: 36)
                            .overlay(
                                Circle()
                                    .stroke(
                                        isAvailable
                                            ? Color(hex: 0xC9A84C).opacity(0.3)
                                            : Color.clear,
                                        lineWidth: 1
                                    )
                            )

                        Image(systemName: icon)
                            .font(.system(size: 16, weight: .semibold))
                            .foregroundStyle(
                                isAvailable
                                    ? LinearGradient(colors: [Color(hex: 0xFFD700), Color(hex: 0xE8A035)],
                                                     startPoint: .top, endPoint: .bottom)
                                    : LinearGradient(colors: [Color(hex: 0x5A4530), Color(hex: 0x3D2B1F)],
                                                     startPoint: .top, endPoint: .bottom)
                            )

                        // Shine sweep (top highlight)
                        if isAvailable {
                            Ellipse()
                                .fill(Color.white.opacity(0.12))
                                .frame(width: 22, height: 8)
                                .offset(y: -10)
                        }
                    }

                    // Count badge
                    Text(godMode ? "\u{221E}" : "\(count)")
                        .font(.system(size: 8, weight: .bold))
                        .foregroundColor(.white)
                        .frame(minWidth: 16, minHeight: 16)
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
                        .offset(x: 4, y: -4)
                }

                Text(label)
                    .font(.system(size: 8, weight: .semibold))
                    .foregroundColor(isAvailable ? Color(hex: 0xCCDDCC) : Color(hex: 0x5A4530))

                Text(hint)
                    .font(.system(size: 6))
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
