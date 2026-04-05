import SwiftUI

struct MilestonePopupView: View {
    let milestoneId: String
    var onDismiss: () -> Void

    @State private var showContent = false
    @State private var starScale: CGFloat = 0

    private var title: String {
        switch milestoneId {
        case "first_3star": return "Perfect Miner!"
        case "10_levels": return "Apprentice Miner"
        case "25_stars": return "Star Collector!"
        case "50_stars": return "Star Hoarder!"
        case "100_stars": return "Star Legend!"
        case "20_levels": return "Mine Shaft Explorer"
        case "50_levels": return "Deep Mine Master"
        default: return "Milestone!"
        }
    }

    private var subtitle: String {
        switch milestoneId {
        case "first_3star": return "You got 3 stars on a level!"
        case "10_levels": return "10 levels completed!"
        case "25_stars": return "25 total stars earned!"
        case "50_stars": return "50 total stars earned!"
        case "100_stars": return "100 total stars earned!"
        case "20_levels": return "20 levels explored!"
        case "50_levels": return "50 levels conquered!"
        default: return "Great achievement!"
        }
    }

    private var rewardText: String {
        switch milestoneId {
        case "first_3star": return "+100 Coins"
        case "10_levels": return "+300 Coins"
        case "25_stars": return "+2 Pickaxes"
        case "50_stars": return "+2 Drone Strikes"
        case "100_stars": return "+5 Gems"
        case "20_levels": return "+500 Coins"
        case "50_levels": return "+10 Gems"
        default: return "Reward!"
        }
    }

    private var iconName: String {
        switch milestoneId {
        case "first_3star": return "star.fill"
        case "10_levels", "20_levels", "50_levels": return "pickaxe"
        case "25_stars", "50_stars", "100_stars": return "star.circle.fill"
        default: return "trophy.fill"
        }
    }

    var body: some View {
        ZStack {
            Color.black.opacity(0.65)
                .ignoresSafeArea()
                .onTapGesture {}

            if showContent {
                VStack(spacing: 20) {
                    // Icon
                    Image(systemName: iconName)
                        .font(.system(size: 56))
                        .foregroundColor(Color(hex: 0xFFD700))
                        .scaleEffect(starScale)
                        .shadow(color: Color(hex: 0xFFD700).opacity(0.5), radius: 10)

                    Text(title)
                        .font(.system(size: 26, weight: .black, design: .rounded))
                        .foregroundStyle(
                            LinearGradient(
                                colors: [Color(hex: 0xFFD700), Color(hex: 0xFF8C00)],
                                startPoint: .leading,
                                endPoint: .trailing
                            )
                        )
                        .shadow(color: .black, radius: 3)

                    Text(subtitle)
                        .font(.body)
                        .foregroundColor(Color(hex: 0xCCBB99))

                    // Reward
                    HStack(spacing: 8) {
                        Image(systemName: "gift.fill")
                            .foregroundColor(Color(hex: 0xE8A035))
                        Text(rewardText)
                            .font(.headline)
                            .foregroundColor(.white)
                    }
                    .padding(.horizontal, 24)
                    .padding(.vertical, 12)
                    .background(
                        RoundedRectangle(cornerRadius: 12)
                            .fill(Color(hex: 0x3D2B1F))
                            .overlay(
                                RoundedRectangle(cornerRadius: 12)
                                    .stroke(Color(hex: 0xE8A035).opacity(0.5), lineWidth: 1)
                            )
                    )

                    Button(action: onDismiss) {
                        Text("AWESOME!")
                            .font(.headline.weight(.black))
                            .foregroundColor(.white)
                            .frame(maxWidth: 200)
                            .padding(.vertical, 14)
                            .background(
                                LinearGradient(
                                    colors: [Color(hex: 0xE8A035), Color(hex: 0xC68020)],
                                    startPoint: .top, endPoint: .bottom
                                )
                            )
                            .clipShape(RoundedRectangle(cornerRadius: 14))
                            .shadow(radius: 5)
                    }
                }
                .padding(30)
                .transition(.scale.combined(with: .opacity))
            }
        }
        .onAppear {
            withAnimation(.spring(response: 0.5, dampingFraction: 0.6).delay(0.2)) {
                showContent = true
            }
            withAnimation(.spring(response: 0.6, dampingFraction: 0.4).delay(0.4)) {
                starScale = 1.0
            }
        }
    }
}
