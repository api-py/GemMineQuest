import SwiftUI

struct DailyRewardView: View {
    @EnvironmentObject var progressManager: ProgressManager
    @EnvironmentObject var boosterInventory: BoosterInventory
    var onDismiss: () -> Void

    @State private var claimedReward: ProgressManager.DailyReward?
    @State private var showClaimed = false

    private let dayRewards: [(coins: Int, gem: Int, booster: String?)] = [
        (50, 0, nil),
        (75, 0, "pickaxe"),
        (100, 1, nil),
        (100, 0, "dynamite"),
        (150, 2, nil),
        (200, 0, "droneStrike"),
        (300, 5, "gemForge")
    ]

    var body: some View {
        ZStack {
            // Dark overlay
            Color.black.opacity(0.85)
                .ignoresSafeArea()
                .onTapGesture {}

            VStack(spacing: 20) {
                Spacer()

                // Title
                Text("DAILY MINING BONUS")
                    .font(.system(size: 28, weight: .black, design: .rounded))
                    .foregroundStyle(
                        LinearGradient(colors: [Color(hex: 0xFFD700), Color(hex: 0xE8A035)],
                                       startPoint: .top, endPoint: .bottom)
                    )
                    .shadow(color: Color(hex: 0xFFD700).opacity(0.4), radius: 8)

                // Streak counter
                Text("Day \(progressManager.progress.dailyStreak)/7")
                    .font(.system(size: 16, weight: .semibold))
                    .foregroundColor(Color(hex: 0xCCBB99))

                // 7-day reward row
                ScrollView(.horizontal, showsIndicators: false) {
                    HStack(spacing: 8) {
                        ForEach(0..<7, id: \.self) { index in
                            let day = index + 1
                            let isCurrent = day == (progressManager.progress.dailyStreak == 0 ? 1 : progressManager.progress.dailyStreak)
                            let isPast = day < progressManager.progress.dailyStreak

                            VStack(spacing: 4) {
                                Text("Day \(day)")
                                    .font(.system(size: 10, weight: .bold))
                                    .foregroundColor(isCurrent ? Color(hex: 0xFFD700) : .white)

                                ZStack {
                                    RoundedRectangle(cornerRadius: 10)
                                        .fill(isCurrent
                                              ? LinearGradient(colors: [Color(hex: 0xD41818), Color(hex: 0x8B0000)],
                                                               startPoint: .top, endPoint: .bottom)
                                              : LinearGradient(colors: [Color(hex: 0x2A2218), Color(hex: 0x1A1208)],
                                                               startPoint: .top, endPoint: .bottom))
                                        .frame(width: 52, height: 64)

                                    RoundedRectangle(cornerRadius: 10)
                                        .stroke(isCurrent ? Color(hex: 0xFFD700) : Color(hex: 0x4A3520), lineWidth: 2)
                                        .frame(width: 52, height: 64)

                                    VStack(spacing: 2) {
                                        Image(systemName: dayRewardIcon(day))
                                            .font(.system(size: 18))
                                            .foregroundColor(isPast ? Color(hex: 0x6B5A40) : Color(hex: 0xFFD700))

                                        Text("\(dayRewards[index].coins)")
                                            .font(.system(size: 10, weight: .bold))
                                            .foregroundColor(isPast ? Color(hex: 0x6B5A40) : .white)
                                    }

                                    if isPast {
                                        Image(systemName: "checkmark.circle.fill")
                                            .font(.system(size: 16))
                                            .foregroundColor(Color(hex: 0x4CAF50))
                                            .offset(x: 18, y: -24)
                                    }
                                }
                            }
                        }
                    }
                    .padding(.horizontal, 16)
                }

                // Claim / Claimed state
                if showClaimed, let reward = claimedReward {
                    VStack(spacing: 8) {
                        Text("Claimed!")
                            .font(.system(size: 22, weight: .bold, design: .rounded))
                            .foregroundColor(Color(hex: 0x4CAF50))

                        HStack(spacing: 16) {
                            if reward.coinAmount > 0 {
                                Label("+\(reward.coinAmount)", systemImage: "star.circle.fill")
                                    .foregroundColor(Color(hex: 0xFFD700))
                            }
                            if reward.gemAmount > 0 {
                                Label("+\(reward.gemAmount)", systemImage: "diamond.fill")
                                    .foregroundColor(Color(hex: 0x00BFFF))
                            }
                            if let booster = reward.boosterType {
                                Label("+1", systemImage: boosterIcon(booster))
                                    .foregroundColor(Color(hex: 0xFF6347))
                            }
                        }
                        .font(.system(size: 16, weight: .semibold))
                    }
                    .transition(.scale.combined(with: .opacity))
                } else {
                    Button(action: claimReward) {
                        Text("CLAIM")
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

                // Close button
                Button(action: onDismiss) {
                    Text(showClaimed ? "Continue" : "Skip")
                        .font(.subheadline)
                        .foregroundColor(Color(hex: 0x8B7355))
                }
                .padding(.top, 8)

                Spacer()
            }
        }
    }

    private func claimReward() {
        let reward = progressManager.claimDailyReward()
        if let boosterType = reward.boosterType {
            boosterInventory.increment(boosterType)
        }
        withAnimation(.spring(response: 0.4, dampingFraction: 0.7)) {
            claimedReward = reward
            showClaimed = true
        }
    }

    private func dayRewardIcon(_ day: Int) -> String {
        switch day {
        case 1: return "star.circle"
        case 2: return "hammer.fill"
        case 3: return "diamond.fill"
        case 4: return "flame.fill"
        case 5: return "diamond.fill"
        case 6: return "bolt.fill"
        case 7: return "gift.fill"
        default: return "star.circle"
        }
    }

    private func boosterIcon(_ type: BoosterType) -> String {
        switch type {
        case .pickaxe: return "hammer.fill"
        case .dynamite: return "flame.fill"
        case .droneStrike: return "bolt.fill"
        case .gemForge: return "wand.and.stars"
        default: return "star.fill"
        }
    }
}
