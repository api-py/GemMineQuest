import SwiftUI

struct MainMenuView: View {
    @EnvironmentObject var progressManager: ProgressManager
    @EnvironmentObject var boosterInventory: BoosterInventory

    var onPlay: () -> Void
    var onSettings: () -> Void

    @State private var titleScale: CGFloat = 0.9
    @State private var titleOpacity: Double = 0
    @State private var gemRotation: Double = 0
    @State private var showShop = false

    var body: some View {
        ZStack {
            // Mine shaft background
            Color.black.ignoresSafeArea()
                .overlay(
                    Group {
                        if let _ = UIImage(named: "bg_main_menu") {
                            Image("bg_main_menu")
                                .resizable()
                                .aspectRatio(contentMode: .fill)
                                .opacity(0.7)
                        } else {
                            Image("mine_bg_1")
                                .resizable()
                                .aspectRatio(contentMode: .fill)
                                .opacity(0.45)
                        }
                    }
                    .clipped()
                )
                .clipped()

            // Ambient glow in center
            RadialGradient(
                colors: [Color(hex: 0xFFAA00).opacity(0.08), Color.clear],
                center: .center, startRadius: 50, endRadius: 300
            )
            .ignoresSafeArea()

            VStack(spacing: 0) {
                Spacer()

                // Game logo or decorative gem
                ZStack {
                    Circle()
                        .fill(RadialGradient(
                            colors: [Color(hex: 0xFFD700).opacity(0.2), Color.clear],
                            center: .center, startRadius: 5, endRadius: 80
                        ))
                        .frame(width: 160, height: 160)

                    if let _ = UIImage(named: "game_logo") {
                        Image("game_logo")
                            .resizable()
                            .aspectRatio(contentMode: .fit)
                            .frame(height: 120)
                            .shadow(color: Color(hex: 0xFFD700).opacity(0.4), radius: 12)
                            .shadow(color: .black, radius: 3)
                            .compositingGroup()
                    } else {
                        Image(systemName: "diamond.fill")
                            .font(.system(size: 44))
                            .foregroundStyle(
                                LinearGradient(
                                    colors: [Color(hex: 0xFFD700), Color(hex: 0xE8A035)],
                                    startPoint: .top, endPoint: .bottom
                                )
                            )
                            .rotationEffect(.degrees(gemRotation))
                            .shadow(color: Color(hex: 0xFFD700).opacity(0.4), radius: 8)
                    }
                }
                .padding(.bottom, 8)

                // Game title (shown when no logo asset)
                if UIImage(named: "game_logo") == nil {
                    VStack(spacing: 6) {
                        Text("GemMine")
                            .font(.system(size: 48, weight: .black, design: .rounded))
                            .foregroundStyle(
                                LinearGradient(
                                    colors: [Color(hex: 0xFFD700), Color(hex: 0xFF8C00)],
                                    startPoint: .leading, endPoint: .trailing
                                )
                            )
                            .shadow(color: Color(hex: 0xFF8C00).opacity(0.3), radius: 12)

                        Text("QUEST")
                            .font(.system(size: 32, weight: .bold, design: .rounded))
                            .foregroundColor(Color(hex: 0xE8A035))
                            .tracking(8)
                    }
                    .shadow(color: .black.opacity(0.6), radius: 10)
                }

                Text("Mine precious gems deep underground")
                    .font(.callout)
                    .foregroundColor(Color(hex: 0xFFE8C0))
                    .shadow(color: .black.opacity(0.8), radius: 4, x: 0, y: 2)
                    .scaleEffect(titleScale)
                    .opacity(titleOpacity)
                    .padding(.bottom, 50)

                // Play button
                Button(action: onPlay) {
                    HStack(spacing: 12) {
                        Image("booster_pickaxe")
                            .resizable()
                            .scaledToFit()
                            .frame(width: 28, height: 28)
                        Text(progressManager.progress.highestUnlocked > 1 ? "CONTINUE MINING" : "START MINING")
                            .font(.title3.weight(.bold))
                    }
                    .foregroundColor(.white)
                    .frame(maxWidth: 280)
                    .padding(.vertical, 18)
                    .background(
                        ZStack {
                            LinearGradient(
                                colors: [Color(hex: 0xD41818), Color(hex: 0x8B0000)],
                                startPoint: .top, endPoint: .bottom
                            )
                            VStack {
                                LinearGradient(
                                    colors: [Color.white.opacity(0.15), Color.clear],
                                    startPoint: .top, endPoint: .bottom
                                )
                                .frame(height: 20)
                                Spacer()
                            }
                        }
                    )
                    .clipShape(RoundedRectangle(cornerRadius: 16))
                    .overlay(
                        RoundedRectangle(cornerRadius: 16)
                            .stroke(Color(hex: 0xFF6666).opacity(0.3), lineWidth: 1)
                    )
                    .shadow(color: Color(hex: 0xC71414).opacity(0.5), radius: 12, y: 6)
                }
                .padding(.bottom, 16)

                // Shop button
                Button(action: { showShop = true }) {
                    HStack(spacing: 10) {
                        Image("booster_mine_cart")
                            .resizable()
                            .frame(width: 28, height: 28)
                        Text("Shop")
                            .font(.body.weight(.semibold))
                    }
                    .foregroundColor(Color(hex: 0xFFD700))
                    .frame(maxWidth: 200)
                    .padding(.vertical, 14)
                    .background(
                        LinearGradient(
                            colors: [Color(hex: 0x2A1E10), Color(hex: 0x1A1208)],
                            startPoint: .top, endPoint: .bottom
                        )
                        .overlay(
                            RoundedRectangle(cornerRadius: 12)
                                .stroke(Color(hex: 0xC9A84C).opacity(0.4), lineWidth: 1)
                        )
                    )
                    .clipShape(RoundedRectangle(cornerRadius: 12))
                }
                .padding(.bottom, 8)

                // Settings button
                Button(action: onSettings) {
                    HStack(spacing: 10) {
                        Image(systemName: "gearshape.fill")
                        Text("Settings")
                            .font(.body.weight(.semibold))
                    }
                    .foregroundColor(Color(hex: 0xCCBB99))
                    .frame(maxWidth: 200)
                    .padding(.vertical, 14)
                    .background(
                        LinearGradient(
                            colors: [Color(hex: 0x2A1E10), Color(hex: 0x1A1208)],
                            startPoint: .top, endPoint: .bottom
                        )
                        .overlay(
                            RoundedRectangle(cornerRadius: 12)
                                .stroke(Color(hex: 0xC9A84C).opacity(0.3), lineWidth: 1)
                        )
                    )
                    .clipShape(RoundedRectangle(cornerRadius: 12))
                }

                Spacer()

                // Player stats panel
                if progressManager.progress.highestUnlocked > 1 {
                    VStack(spacing: 8) {
                        HStack(spacing: 24) {
                            VStack(spacing: 2) {
                                Text("\(progressManager.progress.highestUnlocked)")
                                    .font(.system(size: 28, weight: .bold, design: .rounded))
                                    .foregroundStyle(
                                        LinearGradient(colors: [Color(hex: 0xFFD700), Color(hex: 0xE8A035)],
                                                       startPoint: .top, endPoint: .bottom)
                                    )
                                Text("LEVEL")
                                    .font(.system(size: 9, weight: .bold))
                                    .foregroundColor(Color(hex: 0x8B7355))
                                    .tracking(1)
                            }

                            let totalStars = progressManager.progress.levelStars.values.reduce(0, +)
                            VStack(spacing: 2) {
                                HStack(spacing: 3) {
                                    Text("\(totalStars)")
                                        .font(.system(size: 28, weight: .bold, design: .rounded))
                                        .foregroundColor(Color(hex: 0xFFD700))
                                    if let _ = UIImage(named: "star_filled") {
                                        Image("star_filled")
                                            .resizable()
                                            .frame(width: 18, height: 18)
                                    } else {
                                        Image(systemName: "star.fill")
                                            .font(.system(size: 14))
                                            .foregroundColor(Color(hex: 0xFFD700))
                                    }
                                }
                                Text("STARS")
                                    .font(.system(size: 9, weight: .bold))
                                    .foregroundColor(Color(hex: 0x8B7355))
                                    .tracking(1)
                            }

                            let totalScore = progressManager.progress.highScores.values.reduce(0, +)
                            VStack(spacing: 2) {
                                Text("\(totalScore)")
                                    .font(.system(size: 20, weight: .bold, design: .rounded))
                                    .foregroundColor(Color(hex: 0xE8A035))
                                    .minimumScaleFactor(0.6)
                                    .lineLimit(1)
                                Text("TOTAL SCORE")
                                    .font(.system(size: 9, weight: .bold))
                                    .foregroundColor(Color(hex: 0x8B7355))
                                    .tracking(1)
                            }
                        }
                        .padding(.horizontal, 20)
                        .padding(.vertical, 14)
                        .background(
                            RoundedRectangle(cornerRadius: 14)
                                .fill(Color(hex: 0x0D1208).opacity(0.85))
                                .overlay(
                                    RoundedRectangle(cornerRadius: 14)
                                        .stroke(
                                            LinearGradient(
                                                colors: [Color(hex: 0xC9A84C).opacity(0.3), Color(hex: 0x3D2B1F).opacity(0.2)],
                                                startPoint: .top, endPoint: .bottom
                                            ),
                                            lineWidth: 1
                                        )
                                )
                        )
                    }
                    .padding(.bottom, 10)
                }

                // Exit button
                Button(action: {
                    exit(0)
                }) {
                    HStack(spacing: 6) {
                        Image(systemName: "rectangle.portrait.and.arrow.right")
                        Text("Exit")
                            .font(.subheadline.weight(.medium))
                    }
                    .foregroundColor(Color(hex: 0xBBA88A))
                    .shadow(color: .black.opacity(0.6), radius: 2, x: 0, y: 1)
                    .padding(.horizontal, 16)
                    .padding(.vertical, 8)
                    .background(Capsule().fill(Color.white.opacity(0.08)))
                }
                .padding(.bottom, 30)
            }
        }
        .onAppear {
            withAnimation(.spring(response: 0.6, dampingFraction: 0.7).delay(0.1)) {
                titleScale = 1.0
                titleOpacity = 1.0
            }
            withAnimation(.linear(duration: 20).repeatForever(autoreverses: false)) {
                gemRotation = 360
            }
        }
        .fullScreenCover(isPresented: $showShop) {
            ShopView(onDismiss: { showShop = false })
                .environmentObject(progressManager)
                .environmentObject(boosterInventory)
        }
    }
}
