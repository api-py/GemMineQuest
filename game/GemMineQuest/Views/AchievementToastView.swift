import SwiftUI

struct AchievementToastView: View {
    let achievement: Achievement
    var onDismiss: () -> Void

    @State private var offset: CGFloat = -150
    @State private var opacity: Double = 0

    var body: some View {
        VStack {
            HStack(spacing: 12) {
                // Achievement icon
                Image(systemName: achievement.iconName)
                    .font(.title2)
                    .foregroundColor(Color(hex: 0xFFD700))
                    .frame(width: 44, height: 44)
                    .background(
                        Circle()
                            .fill(Color(hex: 0x3D2B1F))
                            .overlay(
                                Circle()
                                    .stroke(Color(hex: 0xE8A035), lineWidth: 2)
                            )
                    )

                VStack(alignment: .leading, spacing: 2) {
                    Text("ACHIEVEMENT UNLOCKED!")
                        .font(.system(size: 9, weight: .black))
                        .foregroundColor(Color(hex: 0xE8A035))

                    Text(achievement.displayName)
                        .font(.system(size: 14, weight: .bold))
                        .foregroundColor(.white)

                    HStack(spacing: 4) {
                        Image(systemName: "circle.fill")
                            .font(.system(size: 8))
                            .foregroundColor(Color(hex: 0xFFD700))
                        Text("+\(achievement.coinReward)")
                            .font(.system(size: 11, weight: .semibold))
                            .foregroundColor(Color(hex: 0xFFD700))
                    }
                }

                Spacer()
            }
            .padding(.horizontal, 16)
            .padding(.vertical, 12)
            .background(
                RoundedRectangle(cornerRadius: 14)
                    .fill(
                        LinearGradient(
                            colors: [Color(hex: 0x2D1B12).opacity(0.95), Color(hex: 0x1A0F0A).opacity(0.95)],
                            startPoint: .top,
                            endPoint: .bottom
                        )
                    )
                    .overlay(
                        RoundedRectangle(cornerRadius: 14)
                            .stroke(
                                LinearGradient(
                                    colors: [Color(hex: 0xE8A035), Color(hex: 0xC68020)],
                                    startPoint: .leading,
                                    endPoint: .trailing
                                ),
                                lineWidth: 2
                            )
                    )
                    .shadow(color: Color(hex: 0xE8A035).opacity(0.3), radius: 8)
            )
            .padding(.horizontal, 20)
            .offset(y: offset)
            .opacity(opacity)

            Spacer()
        }
        .padding(.top, 60)
        .onTapGesture { dismiss() }
        .onAppear {
            withAnimation(.spring(response: 0.5, dampingFraction: 0.7)) {
                offset = 0
                opacity = 1
            }
            // Auto-dismiss after 3 seconds
            DispatchQueue.main.asyncAfter(deadline: .now() + 3) {
                dismiss()
            }
        }
    }

    private func dismiss() {
        withAnimation(.easeIn(duration: 0.3)) {
            offset = -150
            opacity = 0
        }
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.3) {
            onDismiss()
        }
    }
}
