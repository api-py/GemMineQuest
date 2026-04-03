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

    var body: some View {
        ZStack {
            // Dark overlay
            Color.black.opacity(0.6)
                .ignoresSafeArea()
                .onTapGesture {} // Block taps

            VStack(spacing: 24) {
                Spacer()

                if didWin {
                    // Win state
                    Text("Level Complete!")
                        .font(.system(size: 32, weight: .bold, design: .rounded))
                        .foregroundColor(Color(hex: 0xFFD700))

                    if showStars {
                        StarRatingView(stars: stars, size: 36)
                            .transition(.scale)
                    }

                    Text("\(score) points")
                        .font(.title2.weight(.semibold))
                        .foregroundColor(.white)

                } else {
                    // Lose state
                    Text("Shaft Collapsed!")
                        .font(.system(size: 28, weight: .bold, design: .rounded))
                        .foregroundColor(Color(hex: 0xFF6347))

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
                                        LinearGradient(
                                            colors: [Color(hex: 0xE8A035), Color(hex: 0xC68020)],
                                            startPoint: .top, endPoint: .bottom
                                        )
                                    )
                                    .clipShape(RoundedRectangle(cornerRadius: 14))
                            }
                        }

                        Button(action: onRetry) {
                            Label("Retry", systemImage: "arrow.counterclockwise")
                                .font(.headline)
                                .foregroundColor(.white)
                                .frame(maxWidth: 250)
                                .padding(.vertical, 16)
                                .background(Color(hex: 0x3D2B1F))
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
            withAnimation(.easeOut(duration: 0.5).delay(0.3)) {
                showStars = true
            }
            withAnimation(.easeOut(duration: 0.4).delay(0.8)) {
                showContent = true
            }
        }
    }
}
