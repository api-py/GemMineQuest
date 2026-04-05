import SwiftUI

struct GameOverView: View {
    let didWin: Bool
    let stars: Int
    let score: Int
    let levelNumber: Int
    var onRetry: () -> Void
    var onNextLevel: () -> Void
    var onMenu: () -> Void

    // Animation phases
    @State private var showTitle = false
    @State private var showStars = false
    @State private var starAnimations: [Bool] = [false, false, false]
    @State private var showChest = false
    @State private var chestOpen = false
    @State private var showRewards = false
    @State private var showActions = false

    // Lose state
    @State private var showExtraMovesOffer = true

    // Computed rewards
    private var coinsEarned: Int { 50 + score / 100 }
    private var perfectBonus: Int { stars == 3 ? 100 : 0 }
    private var totalCoins: Int { coinsEarned + perfectBonus }

    var body: some View {
        ZStack {
            Color.black.opacity(0.65)
                .ignoresSafeArea()
                .onTapGesture {}

            if didWin {
                winContent
            } else {
                loseContent
            }
        }
        .onAppear {
            if didWin {
                animateWinSequence()
            } else {
                animateLoseSequence()
            }
        }
    }

    // MARK: - Win Content (4 phases)

    private var winContent: some View {
        VStack(spacing: 20) {
            Spacer()

            // Phase 1: Victory title
            if showTitle {
                Text("LEVEL COMPLETE!")
                    .font(.system(size: 30, weight: .black, design: .rounded))
                    .foregroundStyle(
                        LinearGradient(
                            colors: [Color(hex: 0xFFD700), Color(hex: 0xFF8C00)],
                            startPoint: .leading,
                            endPoint: .trailing
                        )
                    )
                    .shadow(color: .black, radius: 4)
                    .transition(.scale)
            }

            // Phase 1b: Stars (animated one at a time)
            if showStars {
                HStack(spacing: 8) {
                    ForEach(0..<3, id: \.self) { i in
                        Image(systemName: i < stars ? "star.fill" : "star")
                            .font(.system(size: 36))
                            .foregroundColor(i < stars ? Color(hex: 0xFFD700) : Color.gray.opacity(0.4))
                            .scaleEffect(starAnimations[i] ? 1.0 : 0.0)
                            .shadow(color: i < stars ? Color(hex: 0xFFD700).opacity(0.5) : .clear, radius: 6)
                    }
                }
            }

            // Score
            if showTitle {
                Text("\(score) points")
                    .font(.title3.weight(.semibold))
                    .foregroundColor(.white)
            }

            // Phase 2: Treasure chest
            if showChest {
                ZStack {
                    // Light rays from chest
                    if chestOpen {
                        ForEach(0..<8, id: \.self) { i in
                            Rectangle()
                                .fill(
                                    LinearGradient(
                                        colors: [Color(hex: 0xFFD700).opacity(0.4), Color.clear],
                                        startPoint: .bottom,
                                        endPoint: .top
                                    )
                                )
                                .frame(width: 6, height: 80)
                                .rotationEffect(.degrees(Double(i) * 45))
                                .opacity(0.5)
                        }
                        .transition(.opacity)
                    }

                    // Chest body
                    VStack(spacing: 0) {
                        // Lid
                        RoundedRectangle(cornerRadius: 6)
                            .fill(
                                LinearGradient(
                                    colors: [Color(hex: 0x8B4513), Color(hex: 0x5C3317)],
                                    startPoint: .top, endPoint: .bottom
                                )
                            )
                            .frame(width: 70, height: 25)
                            .overlay(
                                RoundedRectangle(cornerRadius: 6)
                                    .stroke(Color(hex: 0xDAA520), lineWidth: 2)
                            )
                            .rotationEffect(.degrees(chestOpen ? -30 : 0), anchor: .bottom)
                            .offset(y: chestOpen ? -10 : 0)

                        // Body
                        RoundedRectangle(cornerRadius: 4)
                            .fill(
                                LinearGradient(
                                    colors: [Color(hex: 0x6B3A20), Color(hex: 0x4A2512)],
                                    startPoint: .top, endPoint: .bottom
                                )
                            )
                            .frame(width: 70, height: 40)
                            .overlay(
                                RoundedRectangle(cornerRadius: 4)
                                    .stroke(Color(hex: 0xDAA520), lineWidth: 2)
                            )
                            .overlay(
                                // Lock/clasp
                                Circle()
                                    .fill(Color(hex: 0xDAA520))
                                    .frame(width: 12, height: 12)
                                    .offset(y: -18)
                            )
                    }
                }
                .transition(.scale)
            }

            // Phase 3: Reward summary
            if showRewards {
                VStack(spacing: 8) {
                    rewardRow(icon: "circle.fill", iconColor: Color(hex: 0xFFD700),
                              text: "Score Bonus", value: "+\(coinsEarned) coins", delay: 0)

                    if perfectBonus > 0 {
                        rewardRow(icon: "star.fill", iconColor: Color(hex: 0xFFD700),
                                  text: "Perfect Mine!", value: "+\(perfectBonus) coins", delay: 0.2)
                    }

                    Divider().background(Color(hex: 0x6B4F3A)).padding(.horizontal, 40)

                    HStack {
                        Text("Total:")
                            .font(.headline)
                            .foregroundColor(Color(hex: 0xCCBB99))
                        Spacer()
                        Text("+\(totalCoins) coins")
                            .font(.headline.weight(.bold))
                            .foregroundColor(Color(hex: 0xFFD700))
                    }
                    .padding(.horizontal, 40)
                }
                .transition(.move(edge: .trailing).combined(with: .opacity))
            }

            // Phase 4: Action buttons
            if showActions {
                VStack(spacing: 14) {
                    Button(action: onNextLevel) {
                        Label("CONTINUE", systemImage: "arrow.right")
                            .font(.headline.weight(.bold))
                            .foregroundColor(.white)
                            .frame(maxWidth: 250)
                            .padding(.vertical, 16)
                            .background(
                                LinearGradient(
                                    colors: [Color.green, Color(hex: 0x228B22)],
                                    startPoint: .top, endPoint: .bottom
                                )
                            )
                            .clipShape(RoundedRectangle(cornerRadius: 14))
                            .shadow(color: Color.green.opacity(0.3), radius: 6)
                    }

                    Button(action: onRetry) {
                        Text("Retry for better score")
                            .font(.subheadline.weight(.semibold))
                            .foregroundColor(Color(hex: 0xCCBB99))
                    }

                    Button(action: onMenu) {
                        Text("Back to Map")
                            .font(.caption)
                            .foregroundColor(Color(hex: 0x8B7355))
                    }
                }
                .transition(.move(edge: .bottom).combined(with: .opacity))
            }

            Spacer().frame(height: 40)
        }
    }

    private func rewardRow(icon: String, iconColor: Color, text: String, value: String, delay: Double) -> some View {
        HStack {
            Image(systemName: icon)
                .foregroundColor(iconColor)
                .font(.caption)
            Text(text)
                .foregroundColor(Color(hex: 0xCCBB99))
            Spacer()
            Text(value)
                .font(.subheadline.weight(.bold))
                .foregroundColor(.white)
        }
        .padding(.horizontal, 40)
    }

    // MARK: - Lose Content

    private var loseContent: some View {
        VStack(spacing: 24) {
            Spacer()

            if showTitle {
                Text("Shaft Collapsed!")
                    .font(.system(size: 28, weight: .bold, design: .rounded))
                    .foregroundColor(Color(hex: 0xFF6347))
                    .transition(.scale)

                Text("Out of moves")
                    .font(.body)
                    .foregroundColor(Color(hex: 0xCCBB99))
            }

            // Extra moves offer
            if showExtraMovesOffer && showActions {
                VStack(spacing: 14) {
                    Text("Need more moves?")
                        .font(.headline)
                        .foregroundColor(.white)

                    Button(action: {
                        // Placeholder: grant +5 moves for free (would be ad-based)
                        showExtraMovesOffer = false
                    }) {
                        HStack {
                            Image(systemName: "play.rectangle.fill")
                            Text("Watch Ad for +5 Moves")
                                .font(.subheadline.weight(.bold))
                        }
                        .foregroundColor(.white)
                        .frame(maxWidth: 250)
                        .padding(.vertical, 14)
                        .background(
                            LinearGradient(
                                colors: [Color.green, Color(hex: 0x228B22)],
                                startPoint: .top, endPoint: .bottom
                            )
                        )
                        .clipShape(RoundedRectangle(cornerRadius: 12))
                    }
                }
                .padding(20)
                .background(
                    RoundedRectangle(cornerRadius: 16)
                        .fill(Color(hex: 0x2D1B12).opacity(0.9))
                        .overlay(
                            RoundedRectangle(cornerRadius: 16)
                                .stroke(Color(hex: 0x6B4F3A), lineWidth: 1)
                        )
                )
                .padding(.horizontal, 30)
                .transition(.scale.combined(with: .opacity))
            }

            Spacer()

            if showActions {
                VStack(spacing: 14) {
                    Button(action: onRetry) {
                        Label("Retry", systemImage: "arrow.counterclockwise")
                            .font(.headline)
                            .foregroundColor(.white)
                            .frame(maxWidth: 250)
                            .padding(.vertical, 16)
                            .background(
                                LinearGradient(
                                    colors: [Color(hex: 0xE8A035), Color(hex: 0xC68020)],
                                    startPoint: .top, endPoint: .bottom
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

    // MARK: - Animation Sequences

    private func animateWinSequence() {
        // Phase 1: Title + stars (0-1.5s)
        withAnimation(.spring(response: 0.5, dampingFraction: 0.7).delay(0.2)) {
            showTitle = true
        }
        withAnimation(.easeOut(duration: 0.3).delay(0.5)) {
            showStars = true
        }
        for i in 0..<3 {
            withAnimation(.spring(response: 0.4, dampingFraction: 0.5).delay(0.7 + Double(i) * 0.3)) {
                starAnimations[i] = true
            }
        }

        // Phase 2: Treasure chest (1.5-2.5s)
        withAnimation(.spring(response: 0.5, dampingFraction: 0.6).delay(1.8)) {
            showChest = true
        }
        withAnimation(.spring(response: 0.6, dampingFraction: 0.5).delay(2.2)) {
            chestOpen = true
        }

        // Phase 3: Rewards (2.5-3.5s)
        withAnimation(.easeOut(duration: 0.4).delay(2.8)) {
            showRewards = true
        }

        // Phase 4: Actions (3.5s+)
        withAnimation(.easeOut(duration: 0.4).delay(3.5)) {
            showActions = true
        }
    }

    private func animateLoseSequence() {
        withAnimation(.spring(response: 0.5, dampingFraction: 0.7).delay(0.2)) {
            showTitle = true
        }
        withAnimation(.easeOut(duration: 0.4).delay(0.8)) {
            showActions = true
        }
    }
}
