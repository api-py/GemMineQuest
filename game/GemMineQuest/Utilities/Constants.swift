import Foundation
import CoreGraphics

enum Constants {
    // MARK: - Grid
    static let defaultGridRows = 8
    static let defaultGridColumns = 8
    static let numGemColors = 6

    // MARK: - Animation Durations
    static let swapDuration: TimeInterval = 0.2
    static let invalidSwapDuration: TimeInterval = 0.15
    static let matchRemoveDuration: TimeInterval = 0.3
    static let fallDurationPerRow: TimeInterval = 0.08
    static let fallBounce: TimeInterval = 0.05
    static let specialActivationDuration: TimeInterval = 0.4
    static let mineBlastInterval: TimeInterval = 0.15
    static let droneFlightDuration: TimeInterval = 0.5
    static let scorePopupDuration: TimeInterval = 0.8

    // MARK: - Scoring
    static let baseMatchScore = 60        // Per gem in a 3-match
    static let extraGemBonus = 60         // Per additional gem beyond 3
    static let laserActivationBonus = 200
    static let volatileActivationBonus = 300
    static let crystalBallActivationBonus = 500
    static let droneActivationBonus = 150
    static let chainMultiplierBase = 1.0
    static let chainMultiplierStep = 0.25

    // MARK: - Mine Blast (Sugar Crush)
    static let mineBlastMovesToStriped = 0.8  // ~4 striped per 5 remaining moves
    static let mineBlastLaserPoints = 500
    static let mineBlastVolatilePoints = 1000
    static let mineBlastCrystalBallPoints = 5000
    static let mineBlastDronePoints = 250

    // MARK: - Board Layout
    static let maxGemSize: CGFloat = 68.0
    static let minGemSize: CGFloat = 36.0
    static let boardPadding: CGFloat = 14.0
    static let gemSpacing: CGFloat = 3.0
    static let hudHeight: CGFloat = 120.0

    // MARK: - Level Generation
    static let tutorialLevelCount = 10
    static let baseMoves = 25
    static let minMoves = 8
    static let difficultyScaleRate = 0.02  // Moves decrease per level

    // MARK: - Boosters
    static let extraMovesCount = 5
    static let droneStrikeCount = 3
}
