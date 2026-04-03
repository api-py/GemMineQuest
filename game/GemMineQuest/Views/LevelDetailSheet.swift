import SwiftUI

struct LevelDetailSheet: View {
    let levelNumber: Int
    @EnvironmentObject var progressManager: ProgressManager
    var onPlay: () -> Void
    var onDismiss: () -> Void

    private var level: Level {
        LevelGenerator.getLevel(number: levelNumber)
    }

    var body: some View {
        ZStack {
            Color(hex: 0x1A0F0A).ignoresSafeArea()

            VStack(spacing: 24) {
                // Level number
                Text("Level \(levelNumber)")
                    .font(.system(size: 32, weight: .bold, design: .rounded))
                    .foregroundColor(Color(hex: 0xFFD700))

                // Best score
                if progressManager.progress.highScore(for: levelNumber) > 0 {
                    VStack(spacing: 4) {
                        StarRatingView(stars: progressManager.progress.stars(for: levelNumber), size: 24)
                        Text("Best: \(progressManager.progress.highScore(for: levelNumber))")
                            .font(.caption)
                            .foregroundColor(Color(hex: 0xCCBB99))
                    }
                }

                Divider().background(Color(hex: 0x6B4F3A))

                // Objectives
                VStack(spacing: 12) {
                    Text("Objectives")
                        .font(.headline)
                        .foregroundColor(Color(hex: 0xE8A035))

                    ForEach(level.objectives.indices, id: \.self) { i in
                        HStack {
                            Image(systemName: objectiveIcon(level.objectives[i]))
                                .foregroundColor(Color(hex: 0xFFD700))
                            Text(level.objectives[i].displayText)
                                .foregroundColor(.white)
                            Spacer()
                        }
                        .padding(.horizontal)
                    }
                }

                // Move limit
                HStack {
                    Image(systemName: "figure.walk")
                        .foregroundColor(Color(hex: 0xCCBB99))
                    Text("\(level.maxMoves) moves")
                        .foregroundColor(Color(hex: 0xCCBB99))
                }

                Spacer()

                // Play button
                Button(action: onPlay) {
                    HStack {
                        Image(systemName: "hammer.fill")
                        Text("START DIG")
                            .font(.title3.weight(.bold))
                    }
                    .foregroundColor(.white)
                    .frame(maxWidth: .infinity)
                    .padding(.vertical, 18)
                    .background(
                        LinearGradient(
                            colors: [Color(hex: 0xE8A035), Color(hex: 0xC68020)],
                            startPoint: .top, endPoint: .bottom
                        )
                    )
                    .clipShape(RoundedRectangle(cornerRadius: 16))
                }
                .padding(.horizontal, 30)

                Button("Back", action: onDismiss)
                    .foregroundColor(Color(hex: 0x8B7355))
                    .padding(.bottom, 20)
            }
            .padding(.top, 30)
        }
    }

    private func objectiveIcon(_ objective: LevelObjective) -> String {
        switch objective {
        case .reachScore: return "target"
        case .clearAllOre: return "pickaxe"
        case .dropTreasures: return "shippingbox.fill"
        case .collectGems: return "diamond.fill"
        case .collectSpecials: return "sparkles"
        }
    }
}
