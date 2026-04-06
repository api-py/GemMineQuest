import SwiftUI

struct GameOverView: View {
    let didWin: Bool
    let stars: Int
    let score: Int
    let levelNumber: Int
    let playerCoins: Int
    var onRetry: () -> Void
    var onNextLevel: () -> Void
    var onMenu: () -> Void
    var onBuyMoves: ((Int, Int) -> Void)? = nil

    // 4-phase win animation states
    @State private var showTitle = false
    @State private var showStars = false
    @State private var showTreasureChest = false
    @State private var showRewardSummary = false
    @State private var showContent = false
    @State private var bannerScale: CGFloat = 0.8
    @State private var chestScale: CGFloat = 0.5
    @State private var chestBounce = false

    // Lose state
    @State private var showMoreMovesOffer = false

    private var coinReward: Int { stars * 25 }

    var body: some View {
        ZStack {
            // Dark overlay / victory background
            if didWin, let _ = UIImage(named: "bg_victory_overlay") {
                Image("bg_victory_overlay")
                    .resizable()
                    .ignoresSafeArea()
                    .opacity(0.85)
                    .onTapGesture {}
            } else {
                Color.black.opacity(0.65)
                    .ignoresSafeArea()
                    .onTapGesture {}
            }

            VStack(spacing: 20) {
                Spacer()

                if didWin {
                    // Phase 1: Title
                    if showTitle {
                        // Win icon
                        if let _ = UIImage(named: "character_miner_king") {
                            Image("character_miner_king")
                                .resizable()
                                .aspectRatio(contentMode: .fit)
                                .frame(width: 100, height: 100)
                                .clipShape(Circle())
                                .overlay(Circle().stroke(Color(hex: 0xFFD700), lineWidth: 3))
                                .shadow(color: Color(hex: 0xFFD700).opacity(0.4), radius: 12)
                        } else {
                            Circle()
                                .fill(RadialGradient(
                                    colors: [Color(hex: 0xFFD700).opacity(0.12), Color.clear],
                                    center: .center, startRadius: 10, endRadius: 100
                                ))
                                .frame(width: 200, height: 200)
                                .overlay(
                                    Image(systemName: "diamond.fill")
                                        .font(.system(size: 32))
                                        .foregroundColor(Color(hex: 0xFFD700).opacity(0.5))
                                )
                        }

                        Text("Level \(levelNumber) Complete!")
                            .font(.system(size: 30, weight: .bold, design: .rounded))
                            .foregroundStyle(
                                LinearGradient(colors: [Color(hex: 0xFFD700), Color(hex: 0xE8A035)],
                                               startPoint: .top, endPoint: .bottom)
                            )
                            .shadow(color: Color(hex: 0xFFD700).opacity(0.3), radius: 8)
                            .scaleEffect(bannerScale)
                            .transition(.scale.combined(with: .opacity))

                        Text(WelshPlaceNames.name(for: levelNumber))
                            .font(.system(size: 16, weight: .medium, design: .serif))
                            .foregroundColor(Color(hex: 0xCCBB99))
                            .italic()
                    }

                    // Phase 2: Stars
                    if showStars {
                        StarRatingView(stars: stars, size: 40)
                            .transition(.scale)
                            .shadow(color: Color(hex: 0xFFD700).opacity(0.4), radius: 6)
                    }

                    // Phase 3: Treasure Chest
                    if showTreasureChest {
                        ZStack {
                            Circle()
                                .fill(RadialGradient(
                                    colors: [Color(hex: 0xFFD700).opacity(0.15), .clear],
                                    center: .center, startRadius: 5, endRadius: 60
                                ))
                                .frame(width: 120, height: 120)

                            Image(systemName: "shippingbox.fill")
                                .font(.system(size: 48))
                                .foregroundStyle(
                                    LinearGradient(colors: [Color(hex: 0xFFD700), Color(hex: 0xC9A84C)],
                                                   startPoint: .top, endPoint: .bottom)
                                )
                                .shadow(color: Color(hex: 0xFFD700).opacity(0.4), radius: 8)
                        }
                        .scaleEffect(chestScale)
                        .offset(y: chestBounce ? -5 : 5)
                        .transition(.scale.combined(with: .opacity))
                    }

                    // Phase 4: Reward Summary
                    if showRewardSummary {
                        VStack(spacing: 8) {
                            Text("\(score) points")
                                .font(.system(size: 22, weight: .bold, design: .rounded))
                                .foregroundColor(.white)
                                .padding(.horizontal, 20)
                                .padding(.vertical, 6)
                                .background(
                                    Capsule()
                                        .fill(Color.black.opacity(0.3))
                                        .overlay(
                                            Capsule()
                                                .stroke(Color(hex: 0xC9A84C).opacity(0.25), lineWidth: 0.5)
                                        )
                                )

                            HStack(spacing: 16) {
                                Label("+\(coinReward) gold", systemImage: "dollarsign.circle.fill")
                                    .font(.system(size: 16, weight: .bold))
                                    .foregroundColor(Color(hex: 0xFFD700))
                            }
                        }
                        .transition(.move(edge: .bottom).combined(with: .opacity))
                    }

                } else {
                    // Lose state
                    Image(systemName: "exclamationmark.triangle.fill")
                        .font(.system(size: 40))
                        .foregroundColor(Color(hex: 0xFF6347).opacity(0.6))
                        .padding(.bottom, 4)

                    Text("Shaft Collapsed!")
                        .font(.system(size: 28, weight: .bold, design: .rounded))
                        .foregroundColor(Color(hex: 0xFF6347))
                        .shadow(color: Color(hex: 0xFF6347).opacity(0.3), radius: 6)

                    Text("Out of moves")
                        .font(.body)
                        .foregroundColor(Color(hex: 0xCCBB99))

                    // "Need more moves?" purchase options
                    if showMoreMovesOffer {
                        VStack(spacing: 10) {
                            Text("Need more moves?")
                                .font(.system(size: 18, weight: .bold, design: .rounded))
                                .foregroundColor(.white)

                            Text("\(playerCoins) gold available")
                                .font(.system(size: 12, weight: .medium))
                                .foregroundColor(Color(hex: 0x8B7355))

                            ForEach([(1, 25), (5, 100), (15, 200)], id: \.0) { moves, cost in
                                Button {
                                    onBuyMoves?(moves, cost)
                                } label: {
                                    HStack(spacing: 8) {
                                        Image(systemName: "plus.circle.fill")
                                            .foregroundColor(Color(hex: 0xFFD700))
                                        Text("+\(moves) move\(moves > 1 ? "s" : "")")
                                            .font(.system(size: 14, weight: .bold))
                                            .foregroundColor(.white)
                                        Spacer()
                                        HStack(spacing: 3) {
                                            Image(systemName: "dollarsign.circle.fill")
                                                .font(.system(size: 12))
                                            Text("\(cost)")
                                                .font(.system(size: 14, weight: .bold))
                                        }
                                        .foregroundColor(playerCoins >= cost
                                            ? Color(hex: 0xFFD700)
                                            : Color(hex: 0x5A4530))
                                    }
                                    .padding(.horizontal, 16)
                                    .padding(.vertical, 10)
                                    .background(
                                        RoundedRectangle(cornerRadius: 12)
                                            .fill(Color(hex: 0x2A1E10))
                                            .overlay(
                                                RoundedRectangle(cornerRadius: 12)
                                                    .stroke(
                                                        playerCoins >= cost
                                                            ? Color(hex: 0xC9A84C).opacity(0.4)
                                                            : Color(hex: 0x3A2A1A).opacity(0.3),
                                                        lineWidth: 1
                                                    )
                                            )
                                    )
                                }
                                .disabled(playerCoins < cost)
                            }
                        }
                        .frame(maxWidth: 260)
                        .transition(.scale.combined(with: .opacity))
                        .padding(.top, 8)
                    }
                }

                Spacer()

                if showContent {
                    VStack(spacing: 14) {
                        if didWin {
                            Button(action: onNextLevel) {
                                Label("Next Level", systemImage: "arrow.right")
                                    .font(.headline)
                                    .foregroundColor(.white)
                                    .frame(maxWidth: 250)
                                    .padding(.vertical, 16)
                                    .background(
                                        ZStack {
                                            LinearGradient(
                                                colors: [Color(hex: 0xD41818), Color(hex: 0x8B0000)],
                                                startPoint: .top, endPoint: .bottom
                                            )
                                            VStack {
                                                LinearGradient(
                                                    colors: [Color.white.opacity(0.12), Color.clear],
                                                    startPoint: .top, endPoint: .bottom
                                                )
                                                .frame(height: 18)
                                                Spacer()
                                            }
                                        }
                                    )
                                    .clipShape(RoundedRectangle(cornerRadius: 14))
                                    .overlay(
                                        RoundedRectangle(cornerRadius: 14)
                                            .stroke(Color(hex: 0xFF6666).opacity(0.25), lineWidth: 0.5)
                                    )
                                    .shadow(color: Color(hex: 0xC71414).opacity(0.4), radius: 8, y: 4)
                            }
                        }

                        Button(action: onRetry) {
                            Label("Retry", systemImage: "arrow.counterclockwise")
                                .font(.headline)
                                .foregroundColor(.white)
                                .frame(maxWidth: 250)
                                .padding(.vertical, 16)
                                .background(
                                    Color(hex: 0x1A2E18)
                                        .overlay(
                                            RoundedRectangle(cornerRadius: 14)
                                                .stroke(Color(hex: 0x3A5A38).opacity(0.3), lineWidth: 0.5)
                                        )
                                )
                                .clipShape(RoundedRectangle(cornerRadius: 14))
                        }

                        Button(action: onMenu) {
                            Text("Back to Map")
                                .font(.subheadline)
                                .foregroundColor(Color(hex: 0x8B7355))
                        }
                        .padding(.top, 8)
                    }
                    .transition(.move(edge: .bottom).combined(with: .opacity))
                }

                Spacer().frame(height: 40)
            }
        }
        .onAppear {
            if didWin {
                // Phase 1: Title (0.2s)
                withAnimation(.spring(response: 0.5, dampingFraction: 0.7).delay(0.2)) {
                    showTitle = true
                    bannerScale = 1.0
                }
                // Phase 2: Stars (0.6s)
                withAnimation(.easeOut(duration: 0.5).delay(0.6)) {
                    showStars = true
                }
                // Phase 3: Treasure chest (1.0s)
                withAnimation(.spring(response: 0.4, dampingFraction: 0.6).delay(1.0)) {
                    showTreasureChest = true
                    chestScale = 1.0
                }
                withAnimation(.easeInOut(duration: 0.8).repeatForever(autoreverses: true).delay(1.2)) {
                    chestBounce = true
                }
                // Phase 4: Reward summary (1.5s)
                withAnimation(.easeOut(duration: 0.4).delay(1.5)) {
                    showRewardSummary = true
                }
                // Buttons (2.0s)
                withAnimation(.easeOut(duration: 0.4).delay(2.0)) {
                    showContent = true
                }
            } else {
                // Lose state: show more moves offer
                withAnimation(.easeOut(duration: 0.4).delay(0.8)) {
                    showMoreMovesOffer = true
                }
                withAnimation(.easeOut(duration: 0.4).delay(0.9)) {
                    showContent = true
                }
            }
        }
    }
}
