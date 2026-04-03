import SwiftUI

struct MainMenuView: View {
    @EnvironmentObject var progressManager: ProgressManager

    var onPlay: () -> Void
    var onSettings: () -> Void

    var body: some View {
        ZStack {
            // Background gradient
            LinearGradient(
                colors: [Color(hex: 0x2D1B12), Color(hex: 0x0D0705)],
                startPoint: .top,
                endPoint: .bottom
            )
            .ignoresSafeArea()

            // Floating gem decorations
            GeometryReader { geo in
                ForEach(0..<8, id: \.self) { i in
                    Circle()
                        .fill(gemDecorationColor(i))
                        .frame(width: CGFloat.random(in: 20...50), height: CGFloat.random(in: 20...50))
                        .position(
                            x: CGFloat.random(in: 0...geo.size.width),
                            y: CGFloat.random(in: 0...geo.size.height)
                        )
                        .opacity(0.15)
                        .blur(radius: 5)
                }
            }

            VStack(spacing: 0) {
                Spacer()

                // Game title
                VStack(spacing: 8) {
                    Text("GemMine")
                        .font(.system(size: 48, weight: .black, design: .rounded))
                        .foregroundStyle(
                            LinearGradient(
                                colors: [Color(hex: 0xFFD700), Color(hex: 0xFF8C00)],
                                startPoint: .leading,
                                endPoint: .trailing
                            )
                        )

                    Text("QUEST")
                        .font(.system(size: 32, weight: .bold, design: .rounded))
                        .foregroundColor(Color(hex: 0xE8A035))
                        .tracking(8)
                }
                .shadow(color: .black.opacity(0.5), radius: 10)
                .padding(.bottom, 10)

                // Subtitle
                Text("Mine precious gems deep underground")
                    .font(.subheadline)
                    .foregroundColor(Color(hex: 0xCCBB99))
                    .padding(.bottom, 60)

                // Play button
                Button(action: onPlay) {
                    HStack(spacing: 12) {
                        Image(systemName: "hammer.fill")
                            .font(.title2)
                        Text("START MINING")
                            .font(.title3.weight(.bold))
                    }
                    .foregroundColor(.white)
                    .frame(maxWidth: 280)
                    .padding(.vertical, 18)
                    .background(
                        LinearGradient(
                            colors: [Color(hex: 0xE8A035), Color(hex: 0xC68020)],
                            startPoint: .top,
                            endPoint: .bottom
                        )
                    )
                    .clipShape(RoundedRectangle(cornerRadius: 16))
                    .shadow(color: Color(hex: 0xE8A035).opacity(0.4), radius: 8, y: 4)
                }
                .padding(.bottom, 16)

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
                    .background(Color(hex: 0x3D2B1F))
                    .clipShape(RoundedRectangle(cornerRadius: 12))
                }

                Spacer()

                // Level progress
                if progressManager.progress.highestUnlocked > 1 {
                    Text("Level \(progressManager.progress.highestUnlocked) reached")
                        .font(.caption)
                        .foregroundColor(Color(hex: 0x8B7355))
                        .padding(.bottom, 30)
                } else {
                    Spacer().frame(height: 50)
                }
            }
        }
    }

    private func gemDecorationColor(_ index: Int) -> Color {
        let colors: [Color] = [
            Color(hex: 0xE0115F), Color(hex: 0xFF8C00), Color(hex: 0xFFD700),
            Color(hex: 0x50C878), Color(hex: 0x0F52BA), Color(hex: 0x9966CC),
            Color(hex: 0xFFD700), Color(hex: 0xE0115F)
        ]
        return colors[index % colors.count]
    }
}
