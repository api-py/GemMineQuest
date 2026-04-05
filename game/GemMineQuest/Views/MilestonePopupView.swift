import SwiftUI

struct MilestonePopupView: View {
    let milestoneId: String
    var onClaim: () -> Void

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
            return "\(count) Stars Earned!"
        } else {
            let count = milestoneId.replacingOccurrences(of: "levels_", with: "")
            return "\(count) Levels Completed!"
        }
    }

    private var rewardText: String {
        "+200 coins & 3 gems"
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
                            colors: [Color(hex: 0xFFD700).opacity(0.25), .clear],
                            center: .center, startRadius: 10, endRadius: 80
                        ))
                        .frame(width: 160, height: 160)

                    Circle()
                        .fill(
                            LinearGradient(colors: [Color(hex: 0xFFD700), Color(hex: 0xC9A84C)],
                                           startPoint: .top, endPoint: .bottom)
                        )
                        .frame(width: 80, height: 80)
                        .shadow(color: Color(hex: 0xFFD700).opacity(0.5), radius: 12)

                    Image(systemName: icon)
                        .font(.system(size: 36, weight: .bold))
                        .foregroundColor(Color(hex: 0x3D2B1F))
                }

                // Title
                Text("MILESTONE REACHED!")
                    .font(.system(size: 14, weight: .bold))
                    .foregroundColor(Color(hex: 0xCCBB99))
                    .tracking(2)

                Text(title)
                    .font(.system(size: 26, weight: .black, design: .rounded))
                    .foregroundStyle(
                        LinearGradient(colors: [Color(hex: 0xFFD700), Color(hex: 0xE8A035)],
                                       startPoint: .top, endPoint: .bottom)
                    )
                    .shadow(color: Color(hex: 0xFFD700).opacity(0.3), radius: 6)
                    .multilineTextAlignment(.center)

                // Reward
                Text(rewardText)
                    .font(.system(size: 18, weight: .semibold))
                    .foregroundColor(.white)
                    .padding(.horizontal, 20)
                    .padding(.vertical, 8)
                    .background(
                        Capsule()
                            .fill(Color.black.opacity(0.3))
                            .overlay(Capsule().stroke(Color(hex: 0xC9A84C).opacity(0.3), lineWidth: 1))
                    )

                // Claim button
                Button(action: onClaim) {
                    Text("AWESOME!")
                        .font(.system(size: 20, weight: .black, design: .rounded))
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
