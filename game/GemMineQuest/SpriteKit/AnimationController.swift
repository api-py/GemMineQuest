import SpriteKit

class AnimationController {

    weak var scene: GameScene?
    let layout: BoardLayout

    init(layout: BoardLayout) {
        self.layout = layout
    }

    /// Animate a sequence of game events. Calls completion when all done.
    func animateEvents(_ events: [GameEvent], completion: @escaping () -> Void) {
        guard scene != nil else { completion(); return }

        // Group events into sequential phases
        let phases = groupIntoPhases(events)

        animatePhases(phases, index: 0, completion: completion)
    }

    private func animatePhases(_ phases: [[GameEvent]], index: Int, completion: @escaping () -> Void) {
        guard index < phases.count else {
            completion()
            return
        }

        let phase = phases[index]
        animatePhase(phase) { [weak self] in
            self?.animatePhases(phases, index: index + 1, completion: completion)
        }
    }

    private func animatePhase(_ events: [GameEvent], completion: @escaping () -> Void) {
        guard let scene = scene else { completion(); return }

        var maxDuration: TimeInterval = 0

        for event in events {
            let duration = animateSingleEvent(event)
            maxDuration = max(maxDuration, duration)
        }

        if maxDuration > 0 {
            scene.run(SKAction.sequence([
                SKAction.wait(forDuration: maxDuration),
                SKAction.run(completion)
            ]))
        } else {
            completion()
        }
    }

    /// Animate a single event. Returns the duration of the animation.
    private func animateSingleEvent(_ event: GameEvent) -> TimeInterval {
        guard let scene = scene else { return 0 }

        switch event {
        case .swap(let from, let to):
            return animateSwap(from: from, to: to)

        case .invalidSwap(let from, let to):
            return animateInvalidSwap(from: from, to: to)

        case .matched(let positions, let chainIndex):
            return animateMatch(positions: positions, chainIndex: chainIndex)

        case .specialCreated(let type, let color, let pos):
            return animateSpecialCreation(type: type, color: color, at: pos)

        case .specialActivated(let type, let pos, let affected):
            return animateSpecialActivation(type: type, at: pos, affected: affected)

        case .gemsFell(let moves):
            return animateFalls(moves: moves)

        case .gemsAdded(let gems):
            return animateNewGems(gems: gems)

        case .scoreUpdated(_, let delta, let pos):
            if let pos = pos {
                scene.hud.showScorePopup(delta: delta, at: layout.positionFor(pos))
            }
            scene.hud.updateScore(scene.gameState?.score ?? 0)
            return 0

        case .objectiveProgress(let text, let current, let target):
            scene.hud.updateObjective("\(text): \(current)/\(target)")
            return 0

        case .blockerDamaged(let pos, _):
            if let tile = scene.tileAt(pos) {
                let board = scene.gameState?.board
                tile.updateBlocker(board?.blockerAt(pos))
                tile.run(SKAction.sequence([
                    SKAction.scale(to: 0.9, duration: 0.05),
                    SKAction.scale(to: 1.0, duration: 0.05)
                ]))
            }
            return 0.1

        case .blockerDestroyed(let pos):
            if let tile = scene.tileAt(pos) {
                tile.updateBlocker(nil)
                let effect = ParticleEffects.gemShatter(at: layout.positionFor(pos), color: ColorPalette.dustBrown)
                scene.boardLayer.addChild(effect)
            }
            return 0.3

        case .oreCleared(let pos), .oreCracked(let pos, _):
            if let tile = scene.tileAt(pos) {
                let board = scene.gameState?.board
                tile.updateOre(tileType: board?.tileAt(pos) ?? .normal)
            }
            return 0.1

        case .lavaSpread(_, let to):
            if let tile = scene.tileAt(to) {
                let board = scene.gameState?.board
                tile.updateBlocker(board?.blockerAt(to))
            }
            return 0.3

        case .boardShuffled:
            return animateShuffle()

        case .mineBlastStarted:
            return 0.3

        case .mineBlastConvertedMove(let pos):
            scene.rebuildGemSprite(at: pos)
            return 0.15

        case .mineBlastFinished(_):
            let center = CGPoint(x: layout.sceneSize.width / 2, y: layout.sceneSize.height / 2)
            let effect = ParticleEffects.mineBlastFinale(at: center)
            scene.addChild(effect)
            return 1.0

        case .levelComplete, .levelFailed:
            return 0 // Handled by GameScene via delegate

        case .droneDeployed(let from, let to):
            return animateDrone(from: from, to: to)

        case .treasureDropped(let pos):
            let effect = VisualEffects.createStarBurst(at: layout.positionFor(pos), color: ColorPalette.sparkleGold)
            scene.boardLayer.addChild(effect)
            return 0.5

        default:
            return 0
        }
    }

    // MARK: - Animation Implementations

    private func animateSwap(from: GridPosition, to: GridPosition) -> TimeInterval {
        guard let scene = scene else { return 0 }
        let spriteA = scene.gemSpriteAt(from)
        let spriteB = scene.gemSpriteAt(to)

        let posA = layout.positionFor(from)
        let posB = layout.positionFor(to)

        spriteA?.run(SKAction.moveWithEase(to: posB, duration: Constants.swapDuration))
        spriteB?.run(SKAction.moveWithEase(to: posA, duration: Constants.swapDuration))

        scene.updateGemSpriteMapping(from: from, to: to)

        return Constants.swapDuration
    }

    private func animateInvalidSwap(from: GridPosition, to: GridPosition) -> TimeInterval {
        guard let scene = scene else { return 0 }
        let spriteA = scene.gemSpriteAt(from)
        let spriteB = scene.gemSpriteAt(to)

        let posA = layout.positionFor(from)
        let posB = layout.positionFor(to)
        let dur = Constants.invalidSwapDuration

        spriteA?.run(SKAction.sequence([
            SKAction.moveWithEase(to: posB, duration: dur),
            SKAction.moveWithEase(to: posA, duration: dur)
        ]))
        spriteB?.run(SKAction.sequence([
            SKAction.moveWithEase(to: posA, duration: dur),
            SKAction.moveWithEase(to: posB, duration: dur)
        ]))

        return dur * 2
    }

    private func animateMatch(positions: Set<GridPosition>, chainIndex: Int) -> TimeInterval {
        guard let scene = scene else { return 0 }

        for pos in positions {
            if let sprite = scene.gemSpriteAt(pos) {
                // Shatter effect
                let worldPos = layout.positionFor(pos)
                if let gem = scene.gameState?.board[pos] {
                    let effect = ParticleEffects.gemShatter(at: worldPos, color: gem.color.primaryColor)
                    scene.boardLayer.addChild(effect)
                }

                sprite.run(SKAction.sequence([
                    SKAction.shrinkAndFade(duration: Constants.matchRemoveDuration),
                    SKAction.removeFromParent()
                ]))
                scene.removeGemSprite(at: pos)
            }
        }

        return Constants.matchRemoveDuration
    }

    private func animateSpecialCreation(type: SpecialType, color: GemColor, at pos: GridPosition) -> TimeInterval {
        guard let scene = scene else { return 0 }

        scene.rebuildGemSprite(at: pos)

        if let sprite = scene.gemSpriteAt(pos) {
            sprite.setScale(0.0)
            sprite.run(SKAction.sequence([
                SKAction.popIn(duration: 0.3),
                SKAction.bounceIn(duration: 0.2)
            ]))
        }

        return 0.5
    }

    private func animateSpecialActivation(type: SpecialType, at pos: GridPosition,
                                           affected: Set<GridPosition>) -> TimeInterval {
        guard let scene = scene else { return 0 }
        let center = layout.positionFor(pos)

        switch type {
        case .laserHorizontal, .laserVertical:
            // Laser beam effect
            let isH = type == .laserHorizontal
            let start = CGPoint(
                x: isH ? layout.boardOrigin.x : center.x,
                y: isH ? center.y : layout.boardOrigin.y
            )
            let end = CGPoint(
                x: isH ? layout.boardOrigin.x + layout.boardSize.width : center.x,
                y: isH ? center.y : layout.boardOrigin.y + layout.boardSize.height
            )
            let beam = ParticleEffects.laserBeam(from: start, to: end,
                                                  color: scene.gameState?.board[pos]?.color.primaryColor ?? .white)
            scene.boardLayer.addChild(beam)

        case .volatile:
            let explosion = ParticleEffects.volatileExplosion(at: center)
            scene.boardLayer.addChild(explosion)

        case .crystalBall:
            let wave = ParticleEffects.crystalBallWave(at: center)
            scene.boardLayer.addChild(wave)

        default:
            break
        }

        // Remove affected gems
        for affectedPos in affected {
            if let sprite = scene.gemSpriteAt(affectedPos) {
                sprite.run(SKAction.sequence([
                    SKAction.wait(forDuration: 0.1),
                    SKAction.shrinkAndFade(duration: 0.2),
                    SKAction.removeFromParent()
                ]))
                scene.removeGemSprite(at: affectedPos)
            }
        }

        return Constants.specialActivationDuration
    }

    private func animateFalls(moves: [(from: GridPosition, to: GridPosition)]) -> TimeInterval {
        guard let scene = scene else { return 0 }
        var maxDuration: TimeInterval = 0

        for move in moves {
            if let sprite = scene.gemSpriteAt(move.from) {
                let targetPos = layout.positionFor(move.to)
                let rowDiff = abs(move.from.row - move.to.row)
                let duration = Constants.fallDurationPerRow * Double(rowDiff)

                sprite.run(SKAction.fallWithBounce(to: targetPos, duration: duration))
                scene.moveGemSprite(from: move.from, to: move.to)
                maxDuration = max(maxDuration, duration + Constants.fallBounce)
            }
        }

        return maxDuration
    }

    private func animateNewGems(gems: [(gem: Gem, at: GridPosition)]) -> TimeInterval {
        guard let scene = scene else { return 0 }
        var maxDuration: TimeInterval = 0

        for (gem, pos) in gems {
            let sprite = GemSprite(gem: gem, size: layout.gemSize)
            sprite.position = layout.entryPositionFor(column: pos.column)
            sprite.zPosition = 10
            scene.boardLayer.addChild(sprite)
            scene.setGemSprite(sprite, at: pos)

            let targetPos = layout.positionFor(pos)
            let rowsToFall = CGFloat(scene.gameState?.board.numRows ?? 8) - CGFloat(pos.row)
            let duration = Constants.fallDurationPerRow * Double(rowsToFall)

            sprite.run(SKAction.fallWithBounce(to: targetPos, duration: duration))
            maxDuration = max(maxDuration, duration + Constants.fallBounce)
        }

        return maxDuration
    }

    private func animateShuffle() -> TimeInterval {
        guard let scene = scene else { return 0 }
        scene.rebuildAllGemSprites()
        return 0.5
    }

    private func animateDrone(from: GridPosition, to: GridPosition) -> TimeInterval {
        guard let scene = scene else { return 0 }

        let drone = DroneSprite(size: layout.gemSize)
        scene.boardLayer.addChild(drone)

        let startPos = layout.positionFor(from)
        let targetPos = layout.positionFor(to)

        drone.flyToTarget(from: startPos, to: targetPos) { [weak scene] in
            if let sprite = scene?.gemSpriteAt(to) {
                let effect = ParticleEffects.gemShatter(at: targetPos,
                    color: scene?.gameState?.board[to]?.color.primaryColor ?? .white)
                scene?.boardLayer.addChild(effect)

                sprite.run(SKAction.sequence([
                    SKAction.shrinkAndFade(duration: 0.2),
                    SKAction.removeFromParent()
                ]))
                scene?.removeGemSprite(at: to)
            }
        }

        return Constants.droneFlightDuration
    }

    // MARK: - Phase Grouping

    private func groupIntoPhases(_ events: [GameEvent]) -> [[GameEvent]] {
        var phases: [[GameEvent]] = []
        var currentPhase: [GameEvent] = []

        for event in events {
            switch event {
            case .swap, .invalidSwap:
                if !currentPhase.isEmpty { phases.append(currentPhase); currentPhase = [] }
                phases.append([event])

            case .matched:
                if !currentPhase.isEmpty { phases.append(currentPhase); currentPhase = [] }
                currentPhase.append(event)

            case .gemsFell, .gemsAdded:
                currentPhase.append(event)
                phases.append(currentPhase)
                currentPhase = []

            case .specialActivated:
                currentPhase.append(event)

            case .levelComplete, .levelFailed:
                if !currentPhase.isEmpty { phases.append(currentPhase); currentPhase = [] }
                phases.append([event])

            default:
                currentPhase.append(event)
            }
        }

        if !currentPhase.isEmpty { phases.append(currentPhase) }
        return phases
    }
}
