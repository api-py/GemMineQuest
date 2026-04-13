import SwiftUI

struct MilestonePopupView: View {
    let milestoneId: String
    @EnvironmentObject var localizationManager: LocalizationManager
    var onDismiss: () -> Void
    private let s = Constants.uiScale

    @State private var scale: CGFloat = 0.8
    @State private var opacity: Double = 0

    private var icon: String {
        if milestoneId.hasPrefix("stars_") {
            return "star.fill"
        } else {
            return "flag.fill"
        }
    }

    private var title: String {
        if milestoneId.hasPrefix("stars_") {
            let count = milestoneId.replacingOccurrences(of: "stars_", with: "")
            return localizationManager.t("milestone.starsEarned", count)
        } else {
            let count = milestoneId.replacingOccurrences(of: "levels_", with: "")
            return localizationManager.t("milestone.levelsCompleted", count)
        }
    }

    private var rewardText: String {
        localizationManager.t("milestone.reward")
    }

    var body: some View {
        ZStack {
            // Dark overlay
            Color.black.opacity(0.75)
                .ignoresSafeArea()
                .onTapGesture {}

            VStack(spacing: 20) {
                // Icon with glow
                ZStack {
                    Circle()
                        .fill(RadialGradient(
                            colors: [ColorPalette.uiGold.opacity(0.25), .clear],
                            center: .center, startRadius: 10, endRadius: 80
                        ))
                        .frame(width: 160 * s, height: 160 * s)

                    Circle()
                        .fill(
                            LinearGradient(colors: [ColorPalette.uiGold, Color(hex: 0xC9A84C)],
                                           startPoint: .top, endPoint: .bottom)
                        )
                        .frame(width: 80 * s, height: 80 * s)
                        .shadow(color: ColorPalette.uiGold.opacity(0.5), radius: 12)

                    Image(systemName: icon)
                        .font(.system(size: 36 * s, weight: .bold))
                        .foregroundColor(Color(hex: 0x3D2B1F))
                }

                // Title
                Text(localizationManager.t("milestone.reached"))
                    .font(.system(size: 14 * s, weight: .bold))
                    .foregroundColor(ColorPalette.uiCream)
                    .tracking(2)

                Text(title)
                    .font(.system(size: 26 * s, weight: .black, design: .rounded))
                    .foregroundStyle(
                        LinearGradient(colors: [ColorPalette.uiGold, ColorPalette.uiAmber],
                                       startPoint: .top, endPoint: .bottom)
                    )
                    .shadow(color: ColorPalette.uiGold.opacity(0.3), radius: 6)
                    .multilineTextAlignment(.center)

                // Reward
                Text(rewardText)
                    .font(.system(size: 18 * s, weight: .semibold))
                    .foregroundColor(.white)
                    .padding(.horizontal, 20)
                    .padding(.vertical, 8)
                    .background(
                        Capsule()
                            .fill(Color.black.opacity(0.3))
                            .overlay(Capsule().stroke(Color(hex: 0xC9A84C).opacity(0.3), lineWidth: 1))
                    )

                // Claim button
                Button(action: onDismiss) {
                    Text(localizationManager.t("milestone.awesome"))
                        .font(.system(size: 20 * s, weight: .black, design: .rounded))
                        .foregroundColor(.white)
                        .frame(maxWidth: 220)
                        .padding(.vertical, 16)
                        .background(
                            LinearGradient(
                                colors: [Color(hex: 0xD41818), Color(hex: 0x8B0000)],
                                startPoint: .top, endPoint: .bottom
                            )
                        )
                        .clipShape(RoundedRectangle(cornerRadius: 14))
                        .shadow(color: Color(hex: 0xC71414).opacity(0.5), radius: 8, y: 4)
                }
            }
            .padding(32)
            .background(
                RoundedRectangle(cornerRadius: 24)
                    .fill(
                        LinearGradient(colors: [Color(hex: 0x2A1E10), Color(hex: 0x1A0E05)],
                                       startPoint: .top, endPoint: .bottom)
                    )
                    .overlay(
                        RoundedRectangle(cornerRadius: 24)
                            .stroke(Color(hex: 0xC9A84C).opacity(0.3), lineWidth: 1.5)
                    )
                    .shadow(color: Color.black.opacity(0.5), radius: 20)
            )
            .padding(.horizontal, 32)
            .scaleEffect(scale)
            .opacity(opacity)
        }
        .onAppear {
            withAnimation(.spring(response: 0.5, dampingFraction: 0.7)) {
                scale = 1.0
                opacity = 1.0
            }
        }
    }
}
