import SwiftUI

struct DailyRewardView: View {
    @EnvironmentObject var progressManager: ProgressManager
    var onDismiss: () -> Void

    @State private var showContent = false
    @State private var claimed = false
    @State private var claimedReward: ProgressManager.DailyReward?
    @State private var pulseScale: CGFloat = 1.0

    private var currentDay: Int {
        (progressManager.progress.dailyStreak % 7) + 1
    }

    var body: some View {
        ZStack {
            Color.black.opacity(0.7)
                .ignoresSafeArea()
                .onTapGesture {} // Block taps

            VStack(spacing: 20) {
                Spacer()

                if showContent {
                    // Title
                    Text("DAILY MINING BONUS")
                        .font(.system(size: 24, weight: .black, design: .rounded))
                        .foregroundStyle(
                            LinearGradient(
                                colors: [Color(hex: 0xFFD700), Color(hex: 0xFF8C00)],
                                startPoint: .leading,
                                endPoint: .trailing
                            )
                        )
                        .shadow(color: .black, radius: 4)
                        .transition(.scale)

                    // Streak counter
                    HStack(spacing: 6) {
                        Image(systemName: "flame.fill")
                            .foregroundColor(.orange)
                        Text("Day \(currentDay)/7")
                            .font(.headline)
                            .foregroundColor(Color(hex: 0xCCBB99))
                    }

                    // Reward calendar row
                    ScrollView(.horizontal, showsIndicators: false) {
                        HStack(spacing: 10) {
                            ForEach(1...7, id: \.self) { day in
                                DailyRewardDayView(
                                    day: day,
                                    currentDay: currentDay,
                                    isPast: day < currentDay,
                                    isCurrent: day == currentDay,
                                    claimed: claimed && day == currentDay
                                )
                            }
                        }
                        .padding(.horizontal, 16)
                    }
                    .frame(height: 120)

                    // Claimed reward display
                    if let reward = claimedReward {
                        VStack(spacing: 6) {
                            Text("YOU RECEIVED:")
                                .font(.caption.weight(.bold))
                                .foregroundColor(Color(hex: 0xCCBB99))

                            if let booster = reward.boosterType {
                                Text("\(booster.capitalized) x\(reward.boosterCount)")
                                    .font(.title3.weight(.bold))
                                    .foregroundColor(.white)
                            }
                            if reward.coinAmount > 0 {
                                HStack {
                                    Image(systemName: "circle.fill")
                                        .foregroundColor(Color(hex: 0xFFD700))
                                        .font(.caption)
                                    Text("\(reward.coinAmount) Coins")
                                        .font(.title3.weight(.bold))
                                        .foregroundColor(.white)
                                }
                            }
                            if reward.gemAmount > 0 {
                                HStack {
                                    Image(systemName: "diamond.fill")
                                        .foregroundColor(.purple)
                                        .font(.caption)
                                    Text("\(reward.gemAmount) Gems")
                                        .font(.title3.weight(.bold))
                                        .foregroundColor(.white)
                                }
                            }
                        }
                        .transition(.scale.combined(with: .opacity))
                    }

                    // Claim / Continue button
                    Button(action: {
                        if !claimed {
                            withAnimation(.spring(response: 0.4, dampingFraction: 0.6)) {
                                let reward = progressManager.claimDailyReward()
                                claimedReward = reward
                                claimed = true
                            }
                        } else {
                            onDismiss()
                        }
                    }) {
                        Text(claimed ? "CONTINUE" : "CLAIM")
                            .font(.title3.weight(.black))
                            .foregroundColor(.white)
                            .frame(maxWidth: 250)
                            .padding(.vertical, 16)
                            .background(
                                LinearGradient(
                                    colors: claimed ?
                                        [Color(hex: 0xE8A035), Color(hex: 0xC68020)] :
                                        [Color.green, Color(hex: 0x228B22)],
                                    startPoint: .top,
                                    endPoint: .bottom
                                )
                            )
                            .clipShape(RoundedRectangle(cornerRadius: 16))
                            .shadow(color: claimed ? Color(hex: 0xE8A035).opacity(0.4) : Color.green.opacity(0.4), radius: 8, y: 4)
                            .scaleEffect(pulseScale)
                    }
                }

                Spacer()
            }
        }
        .onAppear {
            withAnimation(.spring(response: 0.5, dampingFraction: 0.7).delay(0.2)) {
                showContent = true
            }
            // Pulse the claim button
            withAnimation(.easeInOut(duration: 0.8).repeatForever(autoreverses: true)) {
                pulseScale = 1.06
            }
        }
    }
}

struct DailyRewardDayView: View {
    let day: Int
    let currentDay: Int
    let isPast: Bool
    let isCurrent: Bool
    let claimed: Bool

    private var rewardIcon: String {
        switch day {
        case 1, 2: return "hammer.fill"
        case 3: return "circle.fill"
        case 4: return "airplane"
        case 5: return "circle.fill"
        case 6: return "tram.fill"
        case 7: return "diamond.fill"
        default: return "gift.fill"
        }
    }

    private var rewardText: String {
        switch day {
        case 1, 2: return "Pickaxe"
        case 3: return "500"
        case 4: return "Drone"
        case 5: return "1000"
        case 6: return "Cart x2"
        case 7: return "3 Gems"
        default: return ""
        }
    }

    var body: some View {
        VStack(spacing: 4) {
            Text("Day \(day)")
                .font(.system(size: 10, weight: .bold))
                .foregroundColor(isCurrent ? Color(hex: 0xFFD700) : Color(hex: 0x8B7355))

            ZStack {
                RoundedRectangle(cornerRadius: 10)
                    .fill(
                        isCurrent ?
                            LinearGradient(colors: [Color(hex: 0xE8A035), Color(hex: 0xC68020)], startPoint: .top, endPoint: .bottom) :
                            LinearGradient(colors: [Color(hex: 0x3D2B1F), Color(hex: 0x2D1B12)], startPoint: .top, endPoint: .bottom)
                    )
                    .frame(width: isCurrent ? 60 : 50, height: isCurrent ? 70 : 60)
                    .overlay(
                        RoundedRectangle(cornerRadius: 10)
                            .stroke(isCurrent ? Color(hex: 0xFFD700) : Color(hex: 0x6B4F3A), lineWidth: isCurrent ? 2 : 1)
                    )

                VStack(spacing: 2) {
                    if isPast || claimed {
                        Image(systemName: "checkmark.circle.fill")
                            .foregroundColor(.green)
                            .font(.title3)
                    } else {
                        Image(systemName: rewardIcon)
                            .foregroundColor(isCurrent ? .white : Color(hex: 0x8B7355))
                            .font(.system(size: isCurrent ? 20 : 16))

                        Text(rewardText)
                            .font(.system(size: 8, weight: .bold))
                            .foregroundColor(isCurrent ? .white : Color(hex: 0x8B7355))
                    }
                }
            }

            if isCurrent {
                Text("TODAY")
                    .font(.system(size: 8, weight: .black))
                    .foregroundColor(Color(hex: 0xFFD700))
            }
        }
        .opacity(isPast ? 0.5 : 1.0)
    }
}
