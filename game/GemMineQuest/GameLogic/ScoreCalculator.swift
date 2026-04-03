import Foundation

class ScoreCalculator {

    /// Calculate score for a match result with chain multiplier
    func scoreForMatch(_ match: MatchResult, chainIndex: Int) -> Int {
        let baseScore = match.count * Constants.baseMatchScore
        let extraBonus = max(0, match.count - 3) * Constants.extraGemBonus
        let multiplier = 1.0 + Double(chainIndex) * Constants.chainMultiplierStep

        return Int(Double(baseScore + extraBonus) * multiplier)
    }

    /// Calculate bonus score for special gem activation
    func scoreForSpecialActivation(_ type: SpecialType) -> Int {
        switch type {
        case .none: return 0
        case .laserHorizontal, .laserVertical: return Constants.laserActivationBonus
        case .volatile: return Constants.volatileActivationBonus
        case .crystalBall: return Constants.crystalBallActivationBonus
        case .miningDrone: return Constants.droneActivationBonus
        }
    }

    /// Calculate Mine Blast (end-level bonus) score
    func mineBlastScore(remainingMoves: Int, specialsOnBoard: [(SpecialType, GridPosition)]) -> Int {
        var total = 0

        // Points for each special still on board
        for (special, _) in specialsOnBoard {
            switch special {
            case .laserHorizontal, .laserVertical:
                total += Constants.mineBlastLaserPoints
            case .volatile:
                total += Constants.mineBlastVolatilePoints
            case .crystalBall:
                total += Constants.mineBlastCrystalBallPoints
            case .miningDrone:
                total += Constants.mineBlastDronePoints
            case .none:
                break
            }
        }

        // Points from converted moves (each becomes a laser gem)
        let convertedMoves = Int(Double(remainingMoves) * Constants.mineBlastMovesToStriped)
        total += convertedMoves * Constants.mineBlastLaserPoints

        return total
    }
}
