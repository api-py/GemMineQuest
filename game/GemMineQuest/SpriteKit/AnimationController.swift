import SpriteKit

@MainActor
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
            scene?.syncAllSpriteZPositions()
            completion()
            return
        }

        let phase = phases[index]
        animatePhase(phase) { [weak self] in
            guard let self else {
                // Scene deallocated mid-animation — still call completion to unblock game state
                completion()
                return
            }
            self.animatePhases(phases, index: index + 1, completion: completion)
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
                SKAction.run { [weak self] in
                    self?.scene?.syncAllSpriteZPositions()
                    completion()
                }
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

        case .levelComplete(_, _):
            // Show "Level Complete!" popup on board before game-over screen
            let center = CGPoint(x: layout.sceneSize.width / 2, y: layout.sceneSize.height / 2)
            let banner = createEncouragementBanner("Level Complete!", at: center, color: ColorPalette.sparkleGold, large: true)
            scene.addChild(banner)
            return 1.5

        case .levelFailed:
            let center = CGPoint(x: layout.sceneSize.width / 2, y: layout.sceneSize.height / 2)
            let banner = createEncouragementBanner("Out of Moves!", at: center, color: SKColor(hex: 0xFF6347), large: true)
            scene.addChild(banner)
            return 1.2

        case .droneDeployed(let from, let to):
            return animateDrone(from: from, to: to)

        case .encouragement(let text):
            let center = CGPoint(x: layout.sceneSize.width / 2,
                                  y: layout.boardOrigin.y + layout.boardSize.height / 2)
            let banner = createEncouragementBanner(text, at: center, color: ColorPalette.sparkleGold, large: false)
            scene.addChild(banner)
            return 0.3  // Brief pause so player notices

        case .treasureDropped(let pos):
            let effect = VisualEffects.createStarBurst(at: layout.positionFor(pos), color: ColorPalette.sparkleGold)
            scene.boardLayer.addChild(effect)
            return 0.5

        case .wormAppeared(let pos):
            return animateWorm(at: pos)

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

        // Raise swapping gems above others to prevent overlap
        spriteA?.zPosition = 10.0 + CGFloat(from.row) * 0.01
        spriteB?.zPosition = 10.0 + CGFloat(to.row) * 0.01

        let restingZA: CGFloat = 1.0 + CGFloat(to.row) * 0.01  // A goes to 'to' position
        let restingZB: CGFloat = 1.0 + CGFloat(from.row) * 0.01  // B goes to 'from' position
        spriteA?.run(SKAction.sequence([
            SKAction.moveWithEase(to: posB, duration: Constants.swapDuration),
            SKAction.run { spriteA?.zPosition = restingZA }
        ]))
        spriteB?.run(SKAction.sequence([
            SKAction.moveWithEase(to: posA, duration: Constants.swapDuration),
            SKAction.run { spriteB?.zPosition = restingZB }
        ]))

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

                sprite.prepareForRemoval()
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

        // Immediately hide any old sprite to prevent color flash
        if let oldSprite = scene.gemSpriteAt(pos) {
            oldSprite.alpha = 0
        }

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

        // Always remove the activating special gem's sprite too
        if let activatingSprite = scene.gemSpriteAt(pos) {
            activatingSprite.prepareForRemoval()
            activatingSprite.run(SKAction.sequence([
                SKAction.shrinkAndFade(duration: 0.2),
                SKAction.removeFromParent()
            ]))
            scene.removeGemSprite(at: pos)
        }

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
            // Charging glow at center before explosion
            let chargeGlow = SKShapeNode(circleOfRadius: layout.tileSize * 0.3)
            chargeGlow.fillColor = SKColor(red: 1, green: 0.4, blue: 0, alpha: 0.8)
            chargeGlow.strokeColor = SKColor.white.withAlphaComponent(0.6)
            chargeGlow.lineWidth = 2.0
            chargeGlow.glowWidth = 6.0
            chargeGlow.position = center
            chargeGlow.zPosition = 45
            chargeGlow.setScale(0.3)
            scene.boardLayer.addChild(chargeGlow)

            // Charge up, pause, then explode
            chargeGlow.run(SKAction.sequence([
                SKAction.scale(to: 1.5, duration: 0.25),
                SKAction.wait(forDuration: 0.15),
                SKAction.group([
                    SKAction.scale(to: 3.0, duration: 0.15),
                    SKAction.fadeOut(withDuration: 0.15)
                ]),
                SKAction.removeFromParent()
            ]))

            // Delayed explosion after charge
            let explosion = ParticleEffects.volatileExplosion(at: center)
            explosion.alpha = 0
            scene.boardLayer.addChild(explosion)
            explosion.run(SKAction.sequence([
                SKAction.wait(forDuration: 0.4),
                SKAction.fadeIn(withDuration: 0.05)
            ]))

            // Flash each affected gem's position after the charge
            for affectedPos in affected {
                let worldPos = layout.positionFor(affectedPos)
                let flash = SKShapeNode(circleOfRadius: layout.tileSize * 0.45)
                flash.fillColor = SKColor(red: 1, green: 0.5, blue: 0, alpha: 0.6)
                flash.strokeColor = .clear
                flash.position = worldPos
                flash.zPosition = 40
                flash.alpha = 0
                scene.boardLayer.addChild(flash)
                flash.run(SKAction.sequence([
                    SKAction.wait(forDuration: 0.4),
                    SKAction.fadeIn(withDuration: 0.05),
                    SKAction.wait(forDuration: 0.1),
                    SKAction.fadeOut(withDuration: 0.2),
                    SKAction.removeFromParent()
                ]))
            }

        case .crystalBall:
            let wave = ParticleEffects.crystalBallWave(at: center)
            scene.boardLayer.addChild(wave)

            // Draw laser lines from crystal ball to each affected gem
            for (i, affectedPos) in affected.enumerated() {
                let targetPoint = layout.positionFor(affectedPos)
                let delay = Double(i) * 0.02 // Stagger the lines slightly

                let line = SKShapeNode()
                let path = CGMutablePath()
                path.move(to: center)
                path.addLine(to: targetPoint)
                line.path = path
                line.strokeColor = SKColor(red: 0.8, green: 0.4, blue: 1.0, alpha: 0.9)
                line.lineWidth = 2.0
                line.glowWidth = 4.0
                line.zPosition = 35
                line.alpha = 0
                scene.boardLayer.addChild(line)

                // Flash the line in then out
                line.run(SKAction.sequence([
                    SKAction.wait(forDuration: delay),
                    SKAction.fadeIn(withDuration: 0.05),
                    // Shake effect: slight position jitter
                    SKAction.repeat(SKAction.sequence([
                        SKAction.moveBy(x: CGFloat.random(in: -1.5...1.5), y: CGFloat.random(in: -1.5...1.5), duration: 0.03),
                        SKAction.moveBy(x: CGFloat.random(in: -1.5...1.5), y: CGFloat.random(in: -1.5...1.5), duration: 0.03),
                    ]), count: 3),
                    SKAction.fadeOut(withDuration: 0.15),
                    SKAction.removeFromParent()
                ]))
            }

        default:
            break
        }

        // Remove affected gems (with delay for charge-up animations)
        let removalDelay: TimeInterval
        switch type {
        case .volatile: removalDelay = 0.5 // After charge-up + explosion
        case .crystalBall: removalDelay = 0.25
        default: removalDelay = 0.1
        }
        for affectedPos in affected {
            if let sprite = scene.gemSpriteAt(affectedPos) {
                sprite.prepareForRemoval()
                // Immediately hide the gem body to prevent lingering behind new falling gems
                sprite.run(SKAction.sequence([
                    SKAction.fadeOut(withDuration: 0.05),
                    SKAction.wait(forDuration: removalDelay),
                    SKAction.removeFromParent()
                ]))
                scene.removeGemSprite(at: affectedPos)
            }
        }

        // Add a small pause after crystal ball explosion before gems fall
        let duration = type == .crystalBall
            ? Constants.specialActivationDuration + 0.3
            : Constants.specialActivationDuration
        return duration
    }

    private func animateFalls(moves: [(from: GridPosition, to: GridPosition)]) -> TimeInterval {
        guard let scene = scene else { return 0 }
        var maxDuration: TimeInterval = 0

        for move in moves {
            if let sprite = scene.gemSpriteAt(move.from) {
                let targetPos = layout.positionFor(move.to)
                let rowDiff = abs(move.from.row - move.to.row)
                let duration = Constants.fallDurationPerRow * Double(rowDiff)

                let capturedSprite = sprite
                capturedSprite.zPosition = 10.0 + CGFloat(move.to.row) * 0.01  // Above stationary gems during fall
                capturedSprite.run(SKAction.sequence([
                    SKAction.fallWithBounce(to: targetPos, duration: duration),
                    SKAction.run { capturedSprite.zPosition = 1.0 + CGFloat(move.to.row) * 0.01 }
                ]))
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
            let rowsToFall = CGFloat(scene.gameState?.board.numRows ?? 8) - CGFloat(pos.row)
            sprite.zPosition = 10.0 + CGFloat(pos.row) * 0.01
            scene.boardLayer.addChild(sprite)
            scene.setGemSprite(sprite, at: pos)

            let targetPos = layout.positionFor(pos)
            let duration = Constants.fallDurationPerRow * Double(rowsToFall)

            let capturedSprite = sprite
            let restingZ: CGFloat = 1.0 + CGFloat(pos.row) * 0.01
            capturedSprite.run(SKAction.sequence([
                SKAction.fallWithBounce(to: targetPos, duration: duration),
                SKAction.run { capturedSprite.zPosition = restingZ }
            ]))
            maxDuration = max(maxDuration, duration + Constants.fallBounce)
        }

        return maxDuration
    }

    private func animateShuffle() -> TimeInterval {
        guard let scene = scene else { return 0 }

        // Show reshuffling banner
        let banner = MineBlastAnimation.createBannerNode(text: "Reshuffling...", size: layout.sceneSize)
        scene.addChild(banner)

        // Rebuild gems after a delay
        scene.run(SKAction.sequence([
            SKAction.wait(forDuration: 1.0),
            SKAction.run { scene.rebuildAllGemSprites() }
        ]))

        return 1.8
    }

    private func animateDrone(from: GridPosition, to: GridPosition) -> TimeInterval {
        guard let scene = scene else { return 0 }

        let startPos = layout.positionFor(from)
        let targetPos = layout.positionFor(to)

        // Create a visible drone orb that flies in an arc
        let drone = SKShapeNode(circleOfRadius: 8)
        drone.fillColor = SKColor(red: 0.0, green: 0.9, blue: 0.9, alpha: 1.0)
        drone.strokeColor = SKColor.white
        drone.lineWidth = 1.5
        drone.glowWidth = 6.0
        drone.zPosition = 40
        drone.position = startPos
        drone.setScale(0.3)
        scene.boardLayer.addChild(drone)

        // Arc path: rise up then curve down to target
        let midPoint = CGPoint(
            x: (startPos.x + targetPos.x) / 2 + CGFloat.random(in: -30...30),
            y: max(startPos.y, targetPos.y) + 50
        )
        let arcPath = CGMutablePath()
        arcPath.move(to: startPos)
        arcPath.addQuadCurve(to: targetPos, control: midPoint)

        let flyDuration: TimeInterval = 0.5
        let flyAction = SKAction.follow(arcPath, asOffset: false, orientToPath: false, duration: flyDuration)
        flyAction.timingMode = .easeInEaseOut

        // Trail effect
        let trail = SKShapeNode(circleOfRadius: 3)
        trail.fillColor = SKColor.cyan.withAlphaComponent(0.4)
        trail.strokeColor = .clear
        trail.glowWidth = 3.0
        trail.zPosition = 39

        let targetColor = scene.gameState?.board[to]?.color.primaryColor ?? .cyan

        drone.run(SKAction.sequence([
            SKAction.scale(to: 1.0, duration: 0.15),
            flyAction,
            SKAction.run { [weak scene] in
                guard let scene = scene else { return }
                // Explosion at target
                let effect = ParticleEffects.gemShatter(at: targetPos,
                    color: targetColor)
                scene.boardLayer.addChild(effect)

                if let sprite = scene.gemSpriteAt(to) {
                    sprite.prepareForRemoval()
                    sprite.run(SKAction.sequence([
                        SKAction.shrinkAndFade(duration: 0.2),
                        SKAction.removeFromParent()
                    ]))
                    scene.removeGemSprite(at: to)
                }

                // Clean up any ore/special highlight tint on the tile
                if let tileSprite = scene.tileAt(to) {
                    tileSprite.clearHighlight()
                }
            },
            SKAction.group([
                SKAction.scale(to: 2.0, duration: 0.15),
                SKAction.fadeOut(withDuration: 0.15)
            ]),
            SKAction.removeFromParent()
        ]))

        return flyDuration + 0.35
    }

    // MARK: - Encouragement Banner

    private func createEncouragementBanner(_ text: String, at position: CGPoint, color: SKColor, large: Bool) -> SKNode {
        let container = SKNode()
        container.position = position
        container.zPosition = 50

        let label = SKLabelNode(text: text)
        label.fontName = "AvenirNext-Heavy"
        label.fontSize = large ? 32 : 22
        label.fontColor = color
        label.verticalAlignmentMode = .center
        container.addChild(label)

        // Background pill
        let bg = SKShapeNode(rectOf: CGSize(width: label.frame.width + 40, height: label.frame.height + 20), cornerRadius: 12)
        bg.fillColor = SKColor.black.withAlphaComponent(0.6)
        bg.strokeColor = color.withAlphaComponent(0.5)
        bg.lineWidth = 2.0
        bg.glowWidth = 4.0
        bg.zPosition = -1
        container.addChild(bg)

        // Animate: scale in, hold, float up and fade out
        container.setScale(0.5)
        container.alpha = 0
        container.run(SKAction.sequence([
            SKAction.group([
                SKAction.scale(to: 1.1, duration: 0.2),
                SKAction.fadeIn(withDuration: 0.15)
            ]),
            SKAction.scale(to: 1.0, duration: 0.1),
            SKAction.wait(forDuration: large ? 1.0 : 0.6),
            SKAction.group([
                SKAction.moveBy(x: 0, y: 40, duration: 0.4),
                SKAction.fadeOut(withDuration: 0.4)
            ]),
            SKAction.removeFromParent()
        ]))

        return container
    }

    // MARK: - Worm Animation

    private func animateWorm(at pos: GridPosition) -> TimeInterval {
        guard let scene = scene else { return 0 }
        let worldPos = layout.positionFor(pos)

        // Create worm body (segmented green/brown)
        let wormContainer = SKNode()
        wormContainer.position = CGPoint(x: worldPos.x, y: worldPos.y - layout.tileSize * 0.6)
        wormContainer.zPosition = 42
        scene.boardLayer.addChild(wormContainer)

        let segmentCount = 5
        let segmentRadius: CGFloat = layout.tileSize * 0.06
        for i in 0..<segmentCount {
            let segment = SKShapeNode(circleOfRadius: segmentRadius * (i == 0 ? 1.3 : 1.0))
            let green = CGFloat(0.35) + CGFloat(i) * 0.08
            segment.fillColor = SKColor(red: 0.3, green: green, blue: 0.15, alpha: 1.0)
            segment.strokeColor = SKColor(red: 0.2, green: 0.25, blue: 0.1, alpha: 0.6)
            segment.lineWidth = 0.5
            segment.position = CGPoint(x: 0, y: -CGFloat(i) * segmentRadius * 1.6)
            wormContainer.addChild(segment)
        }

        // Eyes on head segment
        for dx: CGFloat in [-1, 1] {
            let eye = SKShapeNode(circleOfRadius: segmentRadius * 0.35)
            eye.fillColor = .white
            eye.strokeColor = .clear
            eye.position = CGPoint(x: dx * segmentRadius * 0.5, y: segmentRadius * 0.3)
            wormContainer.children.first?.addChild(eye)

            let pupil = SKShapeNode(circleOfRadius: segmentRadius * 0.18)
            pupil.fillColor = .black
            pupil.strokeColor = .clear
            pupil.position = CGPoint(x: 0, y: segmentRadius * 0.05)
            eye.addChild(pupil)
        }

        wormContainer.setScale(0.3)
        wormContainer.alpha = 0

        // Animation: burrow up, eat, burrow down
        let riseY = layout.tileSize * 0.6
        wormContainer.run(SKAction.sequence([
            // Rise up from below tile
            SKAction.group([
                SKAction.fadeIn(withDuration: 0.1),
                SKAction.scale(to: 1.0, duration: 0.2),
                SKAction.moveBy(x: 0, y: riseY, duration: 0.25)
            ]),
            // Chomp animation (wiggle)
            SKAction.repeat(SKAction.sequence([
                SKAction.rotate(byAngle: 0.15, duration: 0.06),
                SKAction.rotate(byAngle: -0.3, duration: 0.06),
                SKAction.rotate(byAngle: 0.15, duration: 0.06)
            ]), count: 2),
            // Pause
            SKAction.wait(forDuration: 0.1),
            // Burrow back down
            SKAction.group([
                SKAction.moveBy(x: 0, y: -riseY, duration: 0.2),
                SKAction.scale(to: 0.3, duration: 0.2),
                SKAction.fadeOut(withDuration: 0.15)
            ]),
            SKAction.removeFromParent()
        ]))

        // Remove the gem sprite at the position (worm ate it)
        if let sprite = scene.gemSpriteAt(pos) {
            sprite.prepareForRemoval()
            sprite.run(SKAction.sequence([
                SKAction.wait(forDuration: 0.35),
                SKAction.fadeOut(withDuration: 0.1),
                SKAction.removeFromParent()
            ]))
            scene.removeGemSprite(at: pos)
        }

        // Dust particles where worm appears
        let dust = ParticleEffects.gemShatter(at: worldPos, color: ColorPalette.dustBrown)
        dust.run(SKAction.sequence([
            SKAction.wait(forDuration: 0.2),
            SKAction.run { scene.boardLayer.addChild(dust) }
        ]))

        return 0.8
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

            case .specialActivated:
                currentPhase.append(event)

            case .specialCreated:
                // Keep in same phase as preceding .matched to avoid color flash
                currentPhase.append(event)

            case .gemsFell, .gemsAdded:
                currentPhase.append(event)
                phases.append(currentPhase)
                currentPhase = []

            case .boardShuffled, .wormAppeared:
                if !currentPhase.isEmpty { phases.append(currentPhase); currentPhase = [] }
                phases.append([event])

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
