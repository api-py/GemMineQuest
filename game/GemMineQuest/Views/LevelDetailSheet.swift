import SwiftUI

struct LevelDetailSheet: View {
    let levelNumber: Int
    @EnvironmentObject var progressManager: ProgressManager
    var onPlay: () -> Void
    var onDismiss: () -> Void

    @State private var selectedBoosters: Set<String> = []

    private var level: Level {
        LevelGenerator.getLevel(number: levelNumber)
    }

    private var difficultyBadge: (String, Color)? {
        if levelNumber > 50 { return ("Super Hard!", Color.red) }
        if levelNumber > 20 { return ("Hard", Color.orange) }
        return nil
    }

    var body: some View {
        ZStack {
            Color(hex: 0x1A0F0A).ignoresSafeArea()

            VStack(spacing: 20) {
                // Difficulty badge
                if let (text, color) = difficultyBadge {
                    HStack(spacing: 6) {
                        if text == "Super Hard!" {
                            Image(systemName: "exclamationmark.triangle.fill")
                                .font(.caption)
                        }
                        Text(text)
                            .font(.system(size: 13, weight: .black))
                    }
                    .foregroundColor(.white)
                    .padding(.horizontal, 16)
                    .padding(.vertical, 6)
                    .background(
                        Capsule().fill(color)
                    )
                    .padding(.top, 16)
                }

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

                Divider().background(Color(hex: 0x6B4F3A))

                // Booster selection
                VStack(spacing: 10) {
                    Text("Select Boosters:")
                        .font(.subheadline.weight(.bold))
                        .foregroundColor(Color(hex: 0xE8A035))

                    HStack(spacing: 16) {
                        BoosterSlot(
                            icon: "hammer.fill",
                            name: "Pickaxe",
                            type: "pickaxe",
                            count: progressManager.progress.boosterCount(for: "pickaxe"),
                            isSelected: selectedBoosters.contains("pickaxe"),
                            onToggle: { toggleBooster("pickaxe") }
                        )
                        BoosterSlot(
                            icon: "airplane",
                            name: "Drone",
                            type: "drone",
                            count: progressManager.progress.boosterCount(for: "drone"),
                            isSelected: selectedBoosters.contains("drone"),
                            onToggle: { toggleBooster("drone") }
                        )
                        BoosterSlot(
                            icon: "tram.fill",
                            name: "Cart",
                            type: "cart",
                            count: progressManager.progress.boosterCount(for: "cart"),
                            isSelected: selectedBoosters.contains("cart"),
                            onToggle: { toggleBooster("cart") }
                        )
                    }
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
                    .shadow(color: Color(hex: 0xE8A035).opacity(0.3), radius: 6, y: 3)
                }
                .padding(.horizontal, 30)

                Button("Back", action: onDismiss)
                    .foregroundColor(Color(hex: 0x8B7355))
                    .padding(.bottom, 20)
            }
            .padding(.top, difficultyBadge == nil ? 30 : 10)
        }
    }

    private func toggleBooster(_ type: String) {
        if selectedBoosters.contains(type) {
            selectedBoosters.remove(type)
        } else if progressManager.progress.boosterCount(for: type) > 0 {
            selectedBoosters.insert(type)
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

struct BoosterSlot: View {
    let icon: String
    let name: String
    let type: String
    let count: Int
    let isSelected: Bool
    let onToggle: () -> Void

    var body: some View {
        Button(action: onToggle) {
            VStack(spacing: 4) {
                ZStack(alignment: .topTrailing) {
                    Image(systemName: icon)
                        .font(.system(size: 22))
                        .foregroundColor(isSelected ? .white : Color(hex: 0xE8A035))
                        .frame(width: 54, height: 54)
                        .background(
                            RoundedRectangle(cornerRadius: 12)
                                .fill(
                                    isSelected ?
                                        LinearGradient(colors: [Color(hex: 0xE8A035), Color(hex: 0xC68020)], startPoint: .top, endPoint: .bottom) :
                                        LinearGradient(colors: [Color(hex: 0x3D2B1F), Color(hex: 0x2D1B12)], startPoint: .top, endPoint: .bottom)
                                )
                                .overlay(
                                    RoundedRectangle(cornerRadius: 12)
                                        .stroke(isSelected ? Color(hex: 0xFFD700) : Color(hex: 0x6B4F3A), lineWidth: isSelected ? 2 : 1)
                                )
                        )

                    // Count badge
                    if count > 0 {
                        Text("\(count)")
                            .font(.system(size: 10, weight: .bold))
                            .foregroundColor(.white)
                            .frame(width: 18, height: 18)
                            .background(Circle().fill(Color.red))
                            .offset(x: 4, y: -4)
                    } else {
                        Image(systemName: "plus.circle.fill")
                            .font(.system(size: 14))
                            .foregroundColor(Color(hex: 0x6B4F3A))
                            .offset(x: 4, y: -4)
                    }
                }

                Text(name)
                    .font(.system(size: 9, weight: .medium))
                    .foregroundColor(Color(hex: 0xCCBB99))
            }
        }
        .disabled(count == 0)
        .opacity(count > 0 ? 1.0 : 0.5)
    }
}
