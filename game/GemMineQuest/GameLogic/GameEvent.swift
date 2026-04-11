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

    // Worm
    case wormAppeared(at: GridPosition)

    // Encouragement popup
    case encouragement(text: String)

    // Custom equality required because some cases use tuple associated values
    // which cannot be auto-synthesized by the compiler.
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
        case (.specialActivated(let lt, let la, let laf), .specialActivated(let rt, let ra, let raf)):
            return lt == rt && la == ra && laf == raf
        case (.blockerDamaged(let la, let lt), .blockerDamaged(let ra, let rt)):
            return la == ra && lt == rt
        case (.blockerDestroyed(let la), .blockerDestroyed(let ra)):
            return la == ra
        case (.lavaSpread(let lf, let lt), .lavaSpread(let rf, let rt)):
            return lf == rf && lt == rt
        case (.tntWarning(let la, let lc), .tntWarning(let ra, let rc)):
            return la == ra && lc == rc
        case (.tntExploded(let la), .tntExploded(let ra)):
            return la == ra
        case (.oreCracked(let la, let lr), .oreCracked(let ra, let rr)):
            return la == ra && lr == rr
        case (.oreCleared(let la), .oreCleared(let ra)):
            return la == ra
        case (.gemsFell(let lm), .gemsFell(let rm)):
            return lm.count == rm.count && zip(lm, rm).allSatisfy { $0.from == $1.from && $0.to == $1.to }
        case (.gemsAdded(let lg), .gemsAdded(let rg)):
            return lg.count == rg.count && zip(lg, rg).allSatisfy { $0.gem == $1.gem && $0.at == $1.at }
        case (.treasureDropped(let la), .treasureDropped(let ra)):
            return la == ra
        case (.scoreUpdated(let ls, let ld, let la), .scoreUpdated(let rs, let rd, let ra)):
            return ls == rs && ld == rd && la == ra
        case (.objectiveProgress(let lt, let lc, let lta), .objectiveProgress(let rt, let rc, let rta)):
            return lt == rt && lc == rc && lta == rta
        case (.levelComplete(let ls, let lsc), .levelComplete(let rs, let rsc)):
            return ls == rs && lsc == rsc
        case (.levelFailed, .levelFailed):
            return true
        case (.mineBlastStarted, .mineBlastStarted):
            return true
        case (.mineBlastConvertedMove(let la), .mineBlastConvertedMove(let ra)):
            return la == ra
        case (.mineBlastFinished(let ls), .mineBlastFinished(let rs)):
            return ls == rs
        case (.boosterUsed(let lt), .boosterUsed(let rt)):
            return lt == rt
        case (.boardShuffled, .boardShuffled):
            return true
        case (.droneDeployed(let lf, let lt), .droneDeployed(let rf, let rt)):
            return lf == rf && lt == rt
        case (.wormAppeared(let la), .wormAppeared(let ra)):
            return la == ra
        case (.encouragement(let lt), .encouragement(let rt)):
            return lt == rt
        default:
            return false
        }
    }
}

enum BoosterType: String {
    case pickaxe
    case dynamite       // 3x3 blast radius
    case gemForge       // Places a Crystal Ball + Volatile on the board
    case droneStrike
    case mineCartRush
    case extraMoves
    case crystalBallBoost
    case powerGems

    var iconAssetName: String {
        switch self {
        case .pickaxe: return "booster_pickaxe"
        case .dynamite: return "booster_dynamite"
        case .gemForge: return "booster_gem_forge"
        case .droneStrike: return "booster_drone"
        case .mineCartRush: return "booster_mine_cart"
        default: return "booster_pickaxe"
        }
    }
}
