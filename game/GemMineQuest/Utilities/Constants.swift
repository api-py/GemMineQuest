import Foundation
import CoreGraphics
import UIKit

enum Constants {
    // MARK: - iPad Adaptive Scaling
    /// Scale factor: 1.0 on iPhone, 1.5 on iPad
    static let isIPad = UIDevice.current.userInterfaceIdiom == .pad
    static let uiScale: CGFloat = isIPad ? 2.0 : 1.0
    // MARK: - Grid
    static let defaultGridRows = 11
    static let defaultGridColumns = 9
    static let numGemColors = 6

    // MARK: - Animation Durations (slowed for visibility)
    static let swapDuration: TimeInterval = 0.25
    static let invalidSwapDuration: TimeInterval = 0.18
    static let matchRemoveDuration: TimeInterval = 0.4
    static let fallDurationPerRow: TimeInterval = 0.09   // Fast but visible
    static let fallBounce: TimeInterval = 0.06
    static let specialActivationDuration: TimeInterval = 0.55
    static let mineBlastInterval: TimeInterval = 0.18
    static let droneFlightDuration: TimeInterval = 0.6
    static let scorePopupDuration: TimeInterval = 1.0

    // MARK: - Scoring
    static let baseMatchScore = 60
    static let extraGemBonus = 60
    static let laserActivationBonus = 200
    static let volatileActivationBonus = 300
    static let crystalBallActivationBonus = 500
    static let droneActivationBonus = 150
    static let chainMultiplierBase = 1.0
    static let chainMultiplierStep = 0.25

    // MARK: - Mine Blast
    static let mineBlastMovesToStriped = 0.8
    static let mineBlastLaserPoints = 500
    static let mineBlastVolatilePoints = 1000
    static let mineBlastCrystalBallPoints = 5000
    static let mineBlastDronePoints = 250

    // MARK: - Board Layout
    static let maxGemSize: CGFloat = isIPad ? 96.0 : 64.0
    static let minGemSize: CGFloat = isIPad ? 48.0 : 36.0
    static let boardPadding: CGFloat = isIPad ? 10.0 : 6.0
    static let gemSpacing: CGFloat = isIPad ? 1.5 : 1.0
    static let hudHeight: CGFloat = isIPad ? 160.0 : 120.0

    // MARK: - Level Generation
    static let tutorialLevelCount = 10
    static let baseMoves = 20
    static let minMoves = 12
    static let difficultyScaleRate = 0.03

    // MARK: - Boosters
    static let extraMovesCount = 5
    static let droneStrikeCount = 5

    // MARK: - Game Engine
    static let maxCascadeRounds = 50
    static let maxChainActivationRounds = 10
    static let defaultDroneCount = 3
}
