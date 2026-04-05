import SwiftUI

struct GameOverView: View {
    let didWin: Bool
    let stars: Int
    let score: Int
    let levelNumber: Int
    var onRetry: () -> Void
    var onNextLevel: () -> Void
    var onMenu: () -> Void

    @State private var showStars = false
    @State private var showContent = false
    @State private var bannerScale: CGFloat = 0.8

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

                    Text(WelshPlaceNames.name(for: levelNumber))
                        .font(.system(size: 16, weight: .medium, design: .serif))
                        .foregroundColor(Color(hex: 0xCCBB99))
                        .italic()

                    if showStars {
                        StarRatingView(stars: stars, size: 40)
                            .transition(.scale)
                            .shadow(color: Color(hex: 0xFFD700).opacity(0.4), radius: 6)
                    }

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
            withAnimation(.spring(response: 0.5, dampingFraction: 0.7).delay(0.2)) {
                bannerScale = 1.0
            }
            withAnimation(.easeOut(duration: 0.5).delay(0.4)) {
                showStars = true
            }
            withAnimation(.easeOut(duration: 0.4).delay(0.9)) {
                showContent = true
            }
        }
    }
}
