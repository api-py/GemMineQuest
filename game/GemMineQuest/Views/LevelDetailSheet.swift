import SwiftUI
import MapKit

struct LevelDetailSheet: View {
    let levelNumber: Int
    @EnvironmentObject var progressManager: ProgressManager
    @EnvironmentObject var boosterInventory: BoosterInventory
    @EnvironmentObject var localizationManager: LocalizationManager
    var onPlay: () -> Void
    var onDismiss: () -> Void

    private var level: Level {
        LevelGenerator.getLevel(number: levelNumber)
    }

    private var isShuffleLevel: Bool {
        levelNumber >= 5 && (levelNumber % 10 == 5)
    }

    private var difficultyBadge: (text: String, color: UInt32)? {
        if levelNumber >= 50 {
            return (localizationManager.t("levelDetail.superHard"), 0xFF4444)
        } else if levelNumber >= 25 {
            return (localizationManager.t("levelDetail.hard"), 0xFF6347)
        }
        return nil
    }

    var body: some View {
        VStack(spacing: 0) {
            ZStack {
                Color.black.ignoresSafeArea()
                    .overlay(
                        Image("mine_bg_3")
                            .resizable()
                            .aspectRatio(contentMode: .fill)
                            .opacity(0.4)
                            .clipped()
                    )
                    .clipped()

                ScrollView {
                    VStack(spacing: 16) {
                        // Back button row
                        HStack {
                            Button(action: onDismiss) {
                                Image(systemName: "chevron.left")
                                    .font(.system(size: 18, weight: .bold))
                                    .foregroundColor(Color(hex: 0xCCBB99))
                                    .padding(10)
                                    .background(Circle().fill(Color.black.opacity(0.4)))
                            }
                            Spacer()
                        }
                        .padding(.horizontal)

                        // Level number and Welsh name
                        Text(localizationManager.t("levelDetail.level", levelNumber))
                            .font(.system(size: 32, weight: .bold, design: .rounded))
                            .foregroundColor(Color(hex: 0xFFD700))

                        HStack(spacing: 8) {
                            Text(WelshPlaceNames.name(for: levelNumber))
                                .font(.system(size: 18, weight: .medium, design: .serif))
                                .foregroundColor(Color(hex: 0xCCBB99))
                                .italic()

                            if let badge = difficultyBadge {
                                Text(badge.text)
                                    .font(.system(size: 11, weight: .bold))
                                    .foregroundColor(.white)
                                    .padding(.horizontal, 8)
                                    .padding(.vertical, 3)
                                    .background(
                                        Capsule()
                                            .fill(Color(hex: badge.color))
                                    )
                            }
                        }

                        // Welsh town map
                        let welshPlace = WelshPlaceNames.place(for: levelNumber)
                        let mapRegion = MKCoordinateRegion(
                            center: welshPlace.coordinate,
                            span: MKCoordinateSpan(latitudeDelta: 0.1, longitudeDelta: 0.1)
                        )
                        Map(initialPosition: .region(mapRegion)) {
                            Marker(welshPlace.name, coordinate: welshPlace.coordinate)
                                .tint(.red)
                        }
                        .mapStyle(.hybrid(elevation: .realistic))
                        .frame(height: 250 * Constants.uiScale)
                        .clipShape(RoundedRectangle(cornerRadius: 12))
                        .padding(.horizontal)
                        .allowsHitTesting(false)

                        // Zone badge and Welsh lore tip
                        let currentZone = MiningZone.zone(for: levelNumber)
                        VStack(spacing: 8) {
                            // Zone name badge
                            HStack(spacing: 6) {
                                if let img = UIImage(named: currentZone.iconName) {
                                    Image(uiImage: img)
                                        .resizable()
                                        .scaledToFit()
                                        .frame(width: 20, height: 20)
                                } else {
                                    Image(systemName: currentZone.fallbackSystemImage)
                                        .font(.system(size: 12))
                                        .foregroundColor(currentZone.accentColor)
                                }
                                Text(localizationManager.t(currentZone.displayNameKey))
                                    .font(.system(size: max(14, 12 * Constants.uiScale), weight: .bold, design: .rounded))
                                    .foregroundColor(currentZone.accentColor)
                            }
                            .padding(.horizontal, 12)
                            .padding(.vertical, 6)
                            .background(
                                Capsule()
                                    .fill(currentZone.accentColor.opacity(0.15))
                                    .overlay(
                                        Capsule()
                                            .stroke(currentZone.accentColor.opacity(0.3), lineWidth: 0.5)
                                    )
                            )

                            // Lore tip
                            let loreTip = WelshLoreTips.tip(for: levelNumber)
                            if !loreTip.isEmpty {
                                Text(loreTip)
                                    .font(.system(size: max(14, 12 * Constants.uiScale), weight: .regular, design: .serif))
                                    .italic()
                                    .foregroundColor(Color(hex: 0xCCBB99).opacity(0.8))
                                    .multilineTextAlignment(.center)
                                    .padding(.horizontal, 24)
                                    .padding(.vertical, 8)
                            }
                        }
                        .padding(.vertical, 4)

                        // Best score
                        if progressManager.progress.highScore(for: levelNumber) > 0 {
                            VStack(spacing: 4) {
                                StarRatingView(stars: progressManager.progress.stars(for: levelNumber), size: 24)
                                Text(localizationManager.t("levelDetail.best", progressManager.progress.highScore(for: levelNumber)))
                                    .font(.caption)
                                    .foregroundColor(Color(hex: 0xCCBB99))
                            }
                        }

                        Divider().background(Color(hex: 0x6B4F3A))

                        // Objectives
                        VStack(spacing: 12) {
                            Text(localizationManager.t("levelDetail.objectives"))
                                .font(.headline)
                                .foregroundColor(Color(hex: 0xE8A035))

                            ForEach(level.objectives.indices, id: \.self) { i in
                                VStack(alignment: .leading, spacing: 2) {
                                    HStack {
                                        Image(systemName: objectiveIcon(level.objectives[i]))
                                            .foregroundColor(Color(hex: 0xFFD700))
                                        Text(level.objectives[i].localizedDisplayText(localizationManager))
                                            .foregroundColor(.white)
                                        Spacer()
                                    }
                                    Text(level.objectives[i].localizedDescriptionText(localizationManager))
                                        .font(.caption)
                                        .foregroundColor(Color(hex: 0x8B7355))
                                        .padding(.leading, 28)
                                }
                                .padding(.horizontal)
                            }
                        }

                        // Move limit
                        HStack {
                            Image(systemName: "figure.walk")
                                .foregroundColor(Color(hex: 0xCCBB99))
                            Text(localizationManager.t("levelDetail.moves", level.maxMoves))
                                .foregroundColor(Color(hex: 0xCCBB99))
                        }

                        // Shuffle warning
                        if isShuffleLevel {
                            HStack(spacing: 6) {
                                Image(systemName: "arrow.triangle.2.circlepath")
                                    .foregroundColor(Color(hex: 0xFF6347))
                                Text(localizationManager.t("levelDetail.shuffleWarning"))
                                    .font(.system(size: 13, weight: .semibold))
                                    .foregroundColor(Color(hex: 0xFF6347))
                            }
                            .padding(.vertical, 6)
                            .padding(.horizontal, 12)
                            .background(
                                RoundedRectangle(cornerRadius: 8)
                                    .fill(Color(hex: 0xFF6347).opacity(0.15))
                            )
                        }

                    }
                    .padding(.top, 16)
                    .padding(.bottom, 16)
                }
            }

            // Play button - fixed at bottom, outside ScrollView
            Button(action: onPlay) {
                HStack {
                    Image(BoosterType.pickaxe.iconAssetName)
                        .resizable()
                        .scaledToFit()
                        .frame(width: 24, height: 24)
                    Text(progressManager.progress.stars(for: levelNumber) > 0
                         ? localizationManager.t("levelDetail.digAgain")
                         : localizationManager.t("levelDetail.startDig"))
                        .font(.title3.weight(.bold))
                }
                .foregroundColor(.white)
                .frame(maxWidth: .infinity)
                .padding(.vertical, 20)
                .background(
                    LinearGradient(
                        colors: [Color(hex: 0xD41818), Color(hex: 0x8B0000)],
                        startPoint: .top, endPoint: .bottom
                    )
                )
                .clipShape(RoundedRectangle(cornerRadius: 16))
                .shadow(color: Color(hex: 0xC71414).opacity(0.5), radius: 8, y: 4)
            }
            .padding(.horizontal, 24)
            .padding(.bottom, 40)
            .background(Color.black)
        }
    }

    private func objectiveIcon(_ objective: LevelObjective) -> String {
        switch objective {
        case .reachScore: return "target"
        case .clearAllOre: return "hammer.fill"
        case .dropTreasures: return "shippingbox.fill"
        case .collectGems: return "diamond.fill"
        case .collectSpecials: return "sparkles"
        }
    }

}
