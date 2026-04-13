import SwiftUI

struct AchievementToastView: View {
    let achievement: Achievement
    @EnvironmentObject var localizationManager: LocalizationManager
    var onDismiss: () -> Void
    private let s = Constants.uiScale

    @State private var offsetY: CGFloat = -120
    @State private var opacity: Double = 0

    var body: some View {
        VStack {
            HStack(spacing: 12) {
                // Icon
                ZStack {
                    Circle()
                        .fill(
                            LinearGradient(colors: [ColorPalette.uiGold, Color(hex: 0xC9A84C)],
                                           startPoint: .top, endPoint: .bottom)
                        )
                        .frame(width: 44 * s, height: 44 * s)

                    Image(systemName: achievement.iconName)
                        .font(.system(size: 20 * s, weight: .bold))
                        .foregroundColor(Color(hex: 0x3D2B1F))
                }

                // Text
                VStack(alignment: .leading, spacing: 2) {
                    Text(localizationManager.t("achievement.unlocked"))
                        .font(.system(size: 11 * s, weight: .bold))
                        .foregroundColor(ColorPalette.uiGold)

                    Text(achievement.localizedDisplayName(localizationManager))
                        .font(.system(size: 16 * s, weight: .heavy, design: .rounded))
                        .foregroundColor(.white)

                    Text(localizationManager.t("achievement.gold", achievement.coinReward))
                        .font(.system(size: 12 * s, weight: .semibold))
                        .foregroundColor(ColorPalette.uiCream)
                }

                Spacer()
            }
            .padding(.horizontal, 16)
            .padding(.vertical, 12)
            .background(
                RoundedRectangle(cornerRadius: 16)
                    .fill(
                        LinearGradient(colors: [Color(hex: 0x2A1E10), Color(hex: 0x1A1208)],
                                       startPoint: .top, endPoint: .bottom)
                    )
                    .overlay(
                        RoundedRectangle(cornerRadius: 16)
                            .stroke(Color(hex: 0xC9A84C).opacity(0.4), lineWidth: 1.5)
                    )
                    .shadow(color: ColorPalette.uiGold.opacity(0.2), radius: 12, y: 4)
            )
            .padding(.horizontal, 20)
            .offset(y: offsetY)
            .opacity(opacity)

            Spacer()
        }
        .allowsHitTesting(false)
        .onAppear {
            withAnimation(.spring(response: 0.5, dampingFraction: 0.7)) {
                offsetY = 60
                opacity = 1
            }
            // Auto-dismiss after 3 seconds
            DispatchQueue.main.asyncAfter(deadline: .now() + 3.0) {
                withAnimation(.easeIn(duration: 0.3)) {
                    offsetY = -120
                    opacity = 0
                }
                DispatchQueue.main.asyncAfter(deadline: .now() + 0.4) {
                    onDismiss()
                }
            }
        }
    }
}
