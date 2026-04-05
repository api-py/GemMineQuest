import Foundation

/// Events produced by GameEngine, consumed by AnimationController.
/// This decouples game logic from rendering.
enum GameEvent: Equatable {
    // Swap
    case swap(from: GridPosition, to: GridPosition)
    case invalidSwap(from: GridPosition, to: GridPosition)

    // Match & Remove
    case matched(positions: Set<GridPosition>, chainIndex: Int)
    case specialCreated(type: SpecialType, color: GemColor, at: GridPosition)
    case specialActivated(type: SpecialType, at: GridPosition, affected: Set<GridPosition>)

    // Blocker
    case blockerDamaged(at: GridPosition, type: BlockerType)
    case blockerDestroyed(at: GridPosition)
    case lavaSpread(from: GridPosition, to: GridPosition)
    case tntWarning(at: GridPosition, countdown: Int)
    case tntExploded(at: GridPosition)

    // Ore
    case oreCracked(at: GridPosition, remaining: Bool)
    case oreCleared(at: GridPosition)

    // Movement
    case gemsFell(moves: [(from: GridPosition, to: GridPosition)])
    case gemsAdded(gems: [(gem: Gem, at: GridPosition)])
    case treasureDropped(at: GridPosition)

    // Score & Progress
    case scoreUpdated(newScore: Int, delta: Int, at: GridPosition?)
    case objectiveProgress(text: String, current: Int, target: Int)

    // Game End
    case levelComplete(stars: Int, score: Int)
    case levelFailed

    // Mine Blast (end-level bonus)
    case mineBlastStarted
    case mineBlastConvertedMove(at: GridPosition)
    case mineBlastFinished(bonusScore: Int)

    // Booster
    case boosterUsed(type: BoosterType)

    // Board
    case boardShuffled
    case droneDeployed(from: GridPosition, to: GridPosition)

    // Encouragement popup
    case encouragement(text: String)

    // Custom equality for associated values with tuples
    static func == (lhs: GameEvent, rhs: GameEvent) -> Bool {
        switch (lhs, rhs) {
        case (.swap(let lf, let lt), .swap(let rf, let rt)):
            return lf == rf && lt == rt
        case (.invalidSwap(let lf, let lt), .invalidSwap(let rf, let rt)):
            return lf == rf && lt == rt
        case (.matched(let lp, let lc), .matched(let rp, let rc)):
            return lp == rp && lc == rc
        case (.specialCreated(let lt, let lc, let la), .specialCreated(let rt, let rc, let ra)):
            return lt == rt && lc == rc && la == ra
        case (.levelComplete(let ls, let lsc), .levelComplete(let rs, let rsc)):
            return ls == rs && lsc == rsc
        case (.levelFailed, .levelFailed):
            return true
        case (.mineBlastStarted, .mineBlastStarted):
            return true
        case (.boardShuffled, .boardShuffled):
            return true
        default:
            return false
        }
    }
}

enum BoosterType: String {
    case pickaxe
    case dynamite       // 3x3 blast radius
    case gemForge       // Places a Crystal Ball + Volatile on the board
    case swapCharge
    case droneStrike
    case mineCartRush
    case extraMoves
    case crystalBallBoost
    case powerGems
}
