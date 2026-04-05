import SpriteKit

protocol GameSceneDelegate: AnyObject {
    func gameDidComplete(stars: Int, score: Int)
    func gameDidFail()
    func scoreDidUpdate(to score: Int)
    func movesDidUpdate(to moves: Int)
}

class GameScene: SKScene {

    // MARK: - Properties

    weak var gameSceneDelegate: GameSceneDelegate?
    var gameState: GameState?
    var gameEngine: GameEngine?
    var godModeEnabled: Bool = false

    let boardLayer = SKNode()
    var hud: HUDNode!
    private var layout: BoardLayout!
    private var animationController: AnimationController!
    private var gemSprites: [[GemSprite?]] = []
    private var tileSprites: [[TileSprite?]] = []
    private var isAnimating = false

    // Touch tracking
    private var touchStartPos: GridPosition?
    private var swipeHandled = false

    // Long-press gem identification
    private var longPressTimer: Timer?
    private var longPressPosition: GridPosition?
    private var tooltipNode: SKNode?

    // Booster mode
    var activeBooster: BoosterType?

    // Idle hint system
    private var hintTimer: Timer?
    private var hintNodes: [SKNode] = []
    private static let hintIdleDelay: TimeInterval = 5.0

    // MARK: - Board Visibility

    /// Fades only the board content (gems, tiles, frame) while keeping the background visible.
    func setBoardVisible(_ visible: Bool, animated: Bool) {
        let targetAlpha: CGFloat = visible ? 1.0 : 0.0
        if animated {
            boardLayer.run(SKAction.fadeAlpha(to: targetAlpha, duration: 0.5))
        } else {
            boardLayer.alpha = targetAlpha
        }
    }

    // MARK: - Setup

    func configure(state: GameState, engine: GameEngine) {
        self.gameState = state
        self.gameEngine = engine
        state.godModeEnabled = godModeEnabled
    }

    override func didMove(to view: SKView) {
        guard let state = gameState else { return }

        backgroundColor = SKColor(red: 0.10, green: 0.06, blue: 0.03, alpha: 1.0)
        scaleMode = .resizeFill

        // Setup layout
        layout = BoardLayout(sceneSize: size,
                              numRows: state.board.numRows,
                              numColumns: state.board.numColumns)

        // Add background gradient
        setupBackground()

        // Board layer
        addChild(boardLayer)

        // Setup animation controller
        animationController = AnimationController(layout: layout)
        animationController.scene = self

        // Create HUD (minimal — just for score popups, not permanent display)
        hud = HUDNode(width: size.width)
        hud.position = CGPoint(x: size.width / 2, y: size.height - 10)
        hud.zPosition = 20
        hud.alpha = 0  // Hidden — SwiftUI overlay handles all info display
        addChild(hud)

        // Initialize board
        let _ = gameEngine?.initializeBoard(seed: UInt64(state.level.number) &* 2654435761) ?? []

        // Build sprites
        buildTileSprites()
        buildGemSprites()

        // Start idle hint timer
        resetHintTimer()
    }

    override func didChangeSize(_ oldSize: CGSize) {
        guard let state = gameState, size.width > 0, size.height > 0 else { return }
        layout = BoardLayout(sceneSize: size,
                              numRows: state.board.numRows,
                              numColumns: state.board.numColumns)
        animationController = AnimationController(layout: layout)
        animationController.scene = self
        rebuildAllSprites()

        hud?.position = CGPoint(x: size.width / 2, y: size.height - 10)
    }

    // MARK: - Background

    private func setupBackground() {
        let centerX = size.width / 2
        let centerY = size.height / 2

        // Background: try Firefly asset, fall back to procedural
        if let _ = UIImage(named: "bg_game_board") {
            let bgSprite = SKSpriteNode(imageNamed: "bg_game_board")
            bgSprite.size = size
            bgSprite.position = CGPoint(x: centerX, y: centerY)
            bgSprite.zPosition = -10
            addChild(bgSprite)
        } else {
            let bg = SKShapeNode(rectOf: size)
            bg.position = CGPoint(x: centerX, y: centerY)
            bg.fillColor = ColorPalette.background
            bg.strokeColor = .clear
            bg.zPosition = -10
            addChild(bg)

            let topGrad = SKShapeNode(rectOf: CGSize(width: size.width, height: size.height * 0.4))
            topGrad.position = CGPoint(x: centerX, y: size.height * 0.8)
            topGrad.fillColor = ColorPalette.backgroundGradientTop.withAlphaComponent(0.3)
            topGrad.strokeColor = .clear
            topGrad.zPosition = -9
            addChild(topGrad)
        }

        // Warm vignette overlay
        let vignetteSize = max(size.width, size.height) * 1.2
        let vignette = SKShapeNode(circleOfRadius: vignetteSize / 2)
        vignette.position = CGPoint(x: centerX, y: centerY)
        vignette.fillColor = .clear
        vignette.strokeColor = SKColor(red: 0.05, green: 0.03, blue: 0.01, alpha: 0.35)
        vignette.lineWidth = vignetteSize * 0.35
        vignette.zPosition = -8
        addChild(vignette)

        // Board center position
        let boardCenter = CGPoint(
            x: layout.boardOrigin.x + layout.boardSize.width / 2,
            y: layout.boardOrigin.y + layout.boardSize.height / 2
        )

        // Board glow (subtle light behind the board)
        let boardGlow = SKShapeNode(rectOf: CGSize(
            width: layout.boardSize.width + 40,
            height: layout.boardSize.height + 40
        ), cornerRadius: 16)
        boardGlow.position = boardCenter
        boardGlow.fillColor = SKColor(hex: 0x3A2A10, alpha: 0.25)
        boardGlow.strokeColor = .clear
        boardGlow.glowWidth = 22
        boardGlow.zPosition = -7
        boardLayer.addChild(boardGlow)

        // Board background
        let boardBg = SKShapeNode(rectOf: CGSize(
            width: layout.boardSize.width + 14,
            height: layout.boardSize.height + 14
        ), cornerRadius: 8)
        boardBg.position = boardCenter
        boardBg.fillColor = ColorPalette.boardBackground
        boardBg.strokeColor = .clear
        boardBg.zPosition = -5
        boardLayer.addChild(boardBg)

        // Gold outer frame
        let frameInset: CGFloat = 18
        let frameRect = CGSize(
            width: layout.boardSize.width + frameInset,
            height: layout.boardSize.height + frameInset
        )
        let frame = SKShapeNode(rectOf: frameRect, cornerRadius: 10)
        frame.fillColor = .clear
        frame.strokeColor = ColorPalette.boardFrameGold
        frame.lineWidth = 3.5
        frame.position = boardCenter
        frame.zPosition = -4
        boardLayer.addChild(frame)

        // Inner frame line (thinner, slightly inside)
        let innerFrame = SKShapeNode(rectOf: CGSize(
            width: layout.boardSize.width + 10,
            height: layout.boardSize.height + 10
        ), cornerRadius: 7)
        innerFrame.fillColor = .clear
        innerFrame.strokeColor = ColorPalette.boardFrameGoldDark.withAlphaComponent(0.5)
        innerFrame.lineWidth = 1.0
        innerFrame.position = boardCenter
        innerFrame.zPosition = -4
        boardLayer.addChild(innerFrame)

        // Corner ornaments (small diamonds at each corner)
        let halfW = frameRect.width / 2
        let halfH = frameRect.height / 2
        let corners = [
            CGPoint(x: -halfW, y: halfH),
            CGPoint(x: halfW, y: halfH),
            CGPoint(x: -halfW, y: -halfH),
            CGPoint(x: halfW, y: -halfH),
        ]
        for corner in corners {
            let ornament = createCornerOrnament(size: 8)
            ornament.position = CGPoint(x: boardCenter.x + corner.x, y: boardCenter.y + corner.y)
            ornament.zPosition = -3
            boardLayer.addChild(ornament)
        }

        // Ambient floating dust particles
        addAmbientParticles()
    }

    /// Small decorative diamond shape for board frame corners.
    private func createCornerOrnament(size s: CGFloat) -> SKNode {
        let path = CGMutablePath()
        path.move(to: CGPoint(x: 0, y: s))
        path.addLine(to: CGPoint(x: s, y: 0))
        path.addLine(to: CGPoint(x: 0, y: -s))
        path.addLine(to: CGPoint(x: -s, y: 0))
        path.closeSubpath()

        let diamond = SKShapeNode(path: path)
        diamond.fillColor = ColorPalette.boardFrameGoldLight
        diamond.strokeColor = ColorPalette.boardFrameGold
        diamond.lineWidth = 1.0
        diamond.glowWidth = 2.0
        return diamond
    }

    /// Adds slow-floating dust/sparkle motes behind the board.
    private func addAmbientParticles() {
        let particleCount = 20
        for _ in 0..<particleCount {
            let particle = SKShapeNode(circleOfRadius: CGFloat.random(in: 0.8...2.0))
            particle.fillColor = ColorPalette.sparkleGold.withAlphaComponent(CGFloat.random(in: 0.1...0.25))
            particle.strokeColor = .clear
            particle.glowWidth = 1.5
            particle.position = CGPoint(
                x: CGFloat.random(in: 0...size.width),
                y: CGFloat.random(in: 0...size.height)
            )
            particle.zPosition = -6

            addChild(particle)

            // Slow floating drift
            let dx = CGFloat.random(in: -15...15)
            let dy = CGFloat.random(in: 10...30)
            let duration = Double.random(in: 6...12)

            let drift = SKAction.sequence([
                SKAction.moveBy(x: dx, y: dy, duration: duration),
                SKAction.fadeOut(withDuration: 1.0),
                SKAction.run { [weak self] in
                    guard let self else { return }
                    particle.position = CGPoint(
                        x: CGFloat.random(in: 0...self.size.width),
                        y: CGFloat.random(in: 0...self.size.height * 0.3)
                    )
                },
                SKAction.fadeIn(withDuration: 1.0),
            ])
            particle.run(SKAction.sequence([
                SKAction.wait(forDuration: Double.random(in: 0...5)),
                SKAction.repeatForever(drift)
            ]))
        }
    }

    // MARK: - Sprite Building

    private func buildTileSprites() {
        guard let state = gameState else { return }
        tileSprites = Array(repeating: Array(repeating: nil, count: state.board.numColumns),
                            count: state.board.numRows)

        for row in 0..<state.board.numRows {
            for col in 0..<state.board.numColumns {
                let pos = GridPosition(row: row, column: col)
                let tileType = state.board.tileAt(pos)
                guard tileType != .empty else { continue }

                let blocker = state.board.blockerAt(pos)
                let tile = TileSprite(position: pos, tileType: tileType, blocker: blocker, size: layout.tileSize)
                tile.position = layout.positionFor(pos)
                tile.zPosition = 0
                boardLayer.addChild(tile)
                tileSprites[row][col] = tile
            }
        }
    }

    func buildGemSprites() {
        guard let state = gameState else { return }
        gemSprites = Array(repeating: Array(repeating: nil, count: state.board.numColumns),
                           count: state.board.numRows)

        for row in 0..<state.board.numRows {
            for col in 0..<state.board.numColumns {
                let pos = GridPosition(row: row, column: col)
                guard let gem = state.board[pos] else { continue }

                let sprite = GemSprite(gem: gem, size: layout.gemSize)
                sprite.position = layout.positionFor(pos)
                sprite.zPosition = 1
                boardLayer.addChild(sprite)
                gemSprites[row][col] = sprite
            }
        }
    }

    /// Sync tile sprites (blockers, ore) with the board model.
    func syncTileSpritesWithBoard() {
        guard let state = gameState else { return }
        let board = state.board
        for row in 0..<board.numRows {
            for col in 0..<board.numColumns {
                let pos = GridPosition(row: row, column: col)
                guard let tile = tileAt(pos) else { continue }
                tile.updateBlocker(board.blockerAt(pos))
                tile.updateOre(tileType: board.tileAt(pos))
            }
        }
    }

    /// Full sync: rebuild every gem sprite from the board model.
    /// This is the nuclear option — guarantees visual matches model 100%.
    func syncSpritesWithBoard() {
        guard let state = gameState else { return }
        let board = state.board

        // Remove ALL existing gem sprites
        for row in 0..<gemSprites.count {
            for col in 0..<gemSprites[row].count {
                gemSprites[row][col]?.removeFromParent()
                gemSprites[row][col] = nil
            }
        }

        // Rebuild from model
        for row in 0..<board.numRows {
            for col in 0..<board.numColumns {
                let pos = GridPosition(row: row, column: col)
                guard let gem = board[pos] else { continue }

                let sprite = GemSprite(gem: gem, size: layout.gemSize)
                sprite.position = layout.positionFor(pos)
                sprite.zPosition = 1
                boardLayer.addChild(sprite)
                if row < gemSprites.count && col < gemSprites[row].count {
                    gemSprites[row][col] = sprite
                }
            }
        }
    }

    private func rebuildAllSprites() {
        boardLayer.removeAllChildren()
        setupBackground()
        buildTileSprites()
        buildGemSprites()
    }

    func rebuildAllGemSprites() {
        guard gameState != nil else { return }
        // Remove old gem sprites
        for row in 0..<gemSprites.count {
            for col in 0..<gemSprites[row].count {
                gemSprites[row][col]?.removeFromParent()
            }
        }
        buildGemSprites()
    }

    func rebuildGemSprite(at pos: GridPosition) {
        guard let state = gameState, let gem = state.board[pos] else { return }
        guard pos.row >= 0 && pos.row < gemSprites.count,
              !gemSprites.isEmpty,
              pos.column >= 0 && pos.column < gemSprites[pos.row].count else { return }
        gemSprites[pos.row][pos.column]?.removeFromParent()

        let sprite = GemSprite(gem: gem, size: layout.gemSize)
        sprite.position = layout.positionFor(pos)
        sprite.zPosition = 10
        boardLayer.addChild(sprite)
        gemSprites[pos.row][pos.column] = sprite
    }

    // MARK: - Sprite Access (for AnimationController)

    func gemSpriteAt(_ pos: GridPosition) -> GemSprite? {
        guard pos.row >= 0 && pos.row < gemSprites.count,
              !gemSprites.isEmpty,
              pos.column >= 0 && pos.column < gemSprites[pos.row].count else { return nil }
        return gemSprites[pos.row][pos.column]
    }

    func tileAt(_ pos: GridPosition) -> TileSprite? {
        guard pos.row >= 0 && pos.row < tileSprites.count,
              !tileSprites.isEmpty,
              pos.column >= 0 && pos.column < tileSprites[pos.row].count else { return nil }
        return tileSprites[pos.row][pos.column]
    }

    func setGemSprite(_ sprite: GemSprite, at pos: GridPosition) {
        guard pos.row >= 0 && pos.row < gemSprites.count,
              !gemSprites.isEmpty,
              pos.column >= 0 && pos.column < gemSprites[pos.row].count else { return }
        gemSprites[pos.row][pos.column] = sprite
    }

    func removeGemSprite(at pos: GridPosition) {
        guard pos.row >= 0 && pos.row < gemSprites.count,
              !gemSprites.isEmpty,
              pos.column >= 0 && pos.column < gemSprites[pos.row].count else { return }
        gemSprites[pos.row][pos.column] = nil
    }

    func moveGemSprite(from: GridPosition, to: GridPosition) {
        guard from.row >= 0 && from.row < gemSprites.count,
              to.row >= 0 && to.row < gemSprites.count,
              !gemSprites.isEmpty,
              from.column >= 0 && from.column < gemSprites[from.row].count,
              to.column >= 0 && to.column < gemSprites[to.row].count else { return }
        let sprite = gemSprites[from.row][from.column]
        gemSprites[from.row][from.column] = nil
        gemSprites[to.row][to.column] = sprite
    }

    func updateGemSpriteMapping(from posA: GridPosition, to posB: GridPosition) {
        guard posA.row >= 0 && posA.row < gemSprites.count,
              posB.row >= 0 && posB.row < gemSprites.count,
              !gemSprites.isEmpty,
              posA.column >= 0 && posA.column < gemSprites[posA.row].count,
              posB.column >= 0 && posB.column < gemSprites[posB.row].count else { return }
        let spriteA = gemSprites[posA.row][posA.column]
        let spriteB = gemSprites[posB.row][posB.column]
        gemSprites[posA.row][posA.column] = spriteB
        gemSprites[posB.row][posB.column] = spriteA
    }

    // MARK: - Touch Handling

    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        guard !isAnimating, let touch = touches.first else { return }
        stopHintPulseOnGems()
        resetHintTimer()

        let point = touch.location(in: boardLayer)

        if let booster = activeBooster {
            handleBoosterTap(at: point, booster: booster)
            return
        }

        let gridPos = layout.gridPositionFor(point: point)
        touchStartPos = gridPos
        swipeHandled = false

        if let pos = gridPos {
            // Show blocker hint if tapping a blocker
            if let blocker = gameState?.board.blockerAt(pos) {
                showBlockerHint(blocker, at: pos)
                touchStartPos = nil
                return
            }
            // Show ore vein hint if tapping an ore tile (don't cancel touch — allow swiping)
            if let tileType = gameState?.board.tileAt(pos),
               tileType == .oreVein || tileType == .doubleOre {
                let text = tileType == .doubleOre
                    ? "Thick Ore \u{2014} Match here twice to mine it"
                    : "Ore Vein \u{2014} Match gems here to mine it"
                showHintTooltip(text, at: pos)
            }
            // Show special gem hint if tapping a special gem
            if let gem = gameState?.board[pos], gem.special != .none {
                showSpecialGemHint(gem.special, at: pos)
            }
            gemSpriteAt(pos)?.setHighlighted(true)

            // Start long-press timer for gem identification
            longPressTimer?.invalidate()
            longPressPosition = pos
            longPressTimer = Timer.scheduledTimer(withTimeInterval: 0.5, repeats: false) { [weak self] _ in
                DispatchQueue.main.async {
                    self?.showGemTooltip(at: pos)
                }
            }
        }
    }

    override func touchesMoved(_ touches: Set<UITouch>, with event: UIEvent?) {
        guard !isAnimating, !swipeHandled, let touch = touches.first, let startPos = touchStartPos else { return }
        longPressTimer?.invalidate()
        longPressTimer = nil
        let point = touch.location(in: boardLayer)
        let startPoint = layout.positionFor(startPos)
        let delta = point - startPoint

        let threshold: CGFloat = layout.tileSize * 0.35

        if delta.length() > threshold {
            // Determine swipe direction
            let targetPos: GridPosition
            if abs(delta.x) > abs(delta.y) {
                targetPos = GridPosition(row: startPos.row, column: startPos.column + (delta.x > 0 ? 1 : -1))
            } else {
                targetPos = GridPosition(row: startPos.row + (delta.y > 0 ? 1 : -1), column: startPos.column)
            }

            swipeHandled = true
            gemSpriteAt(startPos)?.setHighlighted(false)
            handleSwap(from: startPos, to: targetPos)
        }
    }

    override func touchesEnded(_ touches: Set<UITouch>, with event: UIEvent?) {
        longPressTimer?.invalidate()
        longPressTimer = nil
        dismissGemTooltip()
        if let pos = touchStartPos {
            gemSpriteAt(pos)?.setHighlighted(false)
        }
        touchStartPos = nil
        swipeHandled = false
    }

    override func touchesCancelled(_ touches: Set<UITouch>, with event: UIEvent?) {
        touchesEnded(touches, with: event)
    }

    // MARK: - Hints & Tooltips

    private func showHintTooltip(_ text: String, at pos: GridPosition) {
        boardLayer.childNode(withName: "hintTooltip")?.removeFromParent()

        let worldPos = layout.positionFor(pos)

        let label = SKLabelNode(text: text)
        label.fontName = "AvenirNext-DemiBold"
        label.fontSize = 11
        label.fontColor = .white
        label.verticalAlignmentMode = .center
        label.horizontalAlignmentMode = .center

        let padding: CGFloat = 12
        let bgWidth = label.frame.width + padding * 2
        let bgHeight: CGFloat = 26

        let container = SKNode()
        container.name = "hintTooltip"
        container.zPosition = 80
        container.position = CGPoint(x: worldPos.x, y: worldPos.y + layout.tileSize * 0.7)

        let bg = SKShapeNode(rectOf: CGSize(width: bgWidth, height: bgHeight), cornerRadius: bgHeight / 2)
        bg.fillColor = SKColor(white: 0.0, alpha: 0.85)
        bg.strokeColor = .clear
        container.addChild(bg)
        container.addChild(label)

        // Clamp to board bounds
        let minX = layout.boardOrigin.x + bgWidth / 2
        let maxX = layout.boardOrigin.x + layout.boardSize.width - bgWidth / 2
        container.position.x = min(max(container.position.x, minX), maxX)

        boardLayer.addChild(container)

        container.setScale(0.0)
        container.alpha = 0
        container.run(SKAction.sequence([
            SKAction.group([
                SKAction.scale(to: 1.0, duration: 0.15),
                SKAction.fadeIn(withDuration: 0.15)
            ]),
            SKAction.wait(forDuration: 2.0),
            SKAction.fadeOut(withDuration: 0.3),
            SKAction.removeFromParent()
        ]))
    }

    private func showBlockerHint(_ blocker: BlockerType, at pos: GridPosition) {
        let text: String
        switch blocker {
        case .granite(let layers):
            text = "Granite (\(layers) layer\(layers > 1 ? "s" : "")) - Match next to it to crack"
        case .boulder:
            text = "Boulder - Match next to it to remove"
        case .cage:
            text = "Caged Gem - Match the gem inside to free it"
        case .lava:
            text = "Lava - Spreads each turn! Match next to it"
        case .tnt(let countdown):
            text = "TNT (\(countdown) moves) - Clear before it explodes!"
        case .amber:
            text = "Amber - Match next to it to break free"
        }
        showHintTooltip(text, at: pos)
    }

    private func showSpecialGemHint(_ special: SpecialType, at pos: GridPosition) {
        let text: String
        switch special {
        case .laserHorizontal:
            text = "Laser Gem - Clears the entire row"
        case .laserVertical:
            text = "Laser Gem - Clears the entire column"
        case .volatile:
            text = "Volatile Gem - Explodes a 3x3 area"
        case .crystalBall:
            text = "Crystal Ball - Swap to remove all of one color"
        case .miningDrone:
            text = "Mining Drone - Deploys 3 seekers to clear targets"
        case .none:
            return
        }
        showHintTooltip(text, at: pos)
    }

    // MARK: - Long-Press Gem Tooltip

    private func showGemTooltip(at position: GridPosition) {
        dismissGemTooltip()
        guard let gem = gameState?.board[position] else { return }

        let container = SKNode()
        container.zPosition = 200
        container.name = "gemTooltip"

        var text = gem.color.displayName
        if gem.special != .none {
            text += " (\(gem.special.displayName))"
        }

        let bg = SKShapeNode(rectOf: CGSize(width: 120, height: 30), cornerRadius: 8)
        bg.fillColor = SKColor(white: 0.0, alpha: 0.85)
        bg.strokeColor = SKColor(hex: 0xC9A84C, alpha: 0.5)
        bg.lineWidth = 1
        container.addChild(bg)

        let label = SKLabelNode(text: text)
        label.fontName = "AvenirNext-Bold"
        label.fontSize = 12
        label.fontColor = .white
        label.verticalAlignmentMode = .center
        container.addChild(label)

        // Position above the gem
        let gemPos = layout.positionFor(position)
        container.position = CGPoint(x: gemPos.x, y: gemPos.y + layout.tileSize * 0.7)

        boardLayer.addChild(container)
        tooltipNode = container

        // Auto-dismiss after 2s
        container.run(SKAction.sequence([
            SKAction.wait(forDuration: 2.0),
            SKAction.fadeOut(withDuration: 0.3),
            SKAction.removeFromParent()
        ]))
    }

    private func dismissGemTooltip() {
        tooltipNode?.removeFromParent()
        tooltipNode = nil
    }

    // MARK: - Idle Hint System

    func resetHintTimer() {
        hintTimer?.invalidate()
        clearHintHighlights()
        guard let state = gameState, !state.isComplete, !state.isFailed, !isAnimating else { return }
        hintTimer = Timer.scheduledTimer(withTimeInterval: Self.hintIdleDelay, repeats: false) { [weak self] _ in
            DispatchQueue.main.async {
                self?.showBestMoveHint()
            }
        }
    }

    private func clearHintHighlights() {
        for node in hintNodes {
            node.removeAllActions()
            node.removeFromParent()
        }
        hintNodes.removeAll()
    }

    private func showBestMoveHint() {
        guard let engine = gameEngine, !isAnimating else { return }
        guard let (posA, posB) = engine.matchDetector.findBestMove(on: engine.board) else { return }

        // Pulse both gems
        for pos in [posA, posB] {
            if let sprite = gemSpriteAt(pos) {
                let glow = SKShapeNode(circleOfRadius: layout.gemSize * 0.55)
                glow.fillColor = .clear
                glow.strokeColor = SKColor.white.withAlphaComponent(0.6)
                glow.lineWidth = 2.5
                glow.glowWidth = 8.0
                glow.position = sprite.position
                glow.zPosition = 15
                boardLayer.addChild(glow)
                hintNodes.append(glow)

                let pulse = SKAction.repeatForever(SKAction.sequence([
                    SKAction.scale(to: 1.15, duration: 0.4),
                    SKAction.scale(to: 0.9, duration: 0.4),
                ]))
                pulse.timingMode = .easeInEaseOut
                glow.run(pulse)

                // Also pulse the gem itself gently
                sprite.run(SKAction.repeatForever(SKAction.sequence([
                    SKAction.scale(to: 1.1, duration: 0.4),
                    SKAction.scale(to: 1.0, duration: 0.4),
                ])), withKey: "hintPulse")
                hintNodes.append(sprite) // Track for cleanup (will just remove action)
            }
        }
    }

    private func stopHintPulseOnGems() {
        for node in hintNodes {
            if node is GemSprite {
                node.removeAction(forKey: "hintPulse")
                node.run(SKAction.scale(to: 1.0, duration: 0.1))
            } else {
                node.removeAllActions()
                node.removeFromParent()
            }
        }
        hintNodes.removeAll()
    }

    // MARK: - Game Actions

    private func handleSwap(from: GridPosition, to: GridPosition) {
        guard let engine = gameEngine else { return }
        guard !isAnimating else { return }

        isAnimating = true
        let events = engine.handleSwap(from: from, to: to)

        animationController.animateEvents(events) { [weak self] in
            guard let self else { return }

            // CRITICAL: sync sprites with the final board model state
            // The engine resolves everything instantly; animations may miss edge cases
            self.syncSpritesWithBoard()
            self.syncTileSpritesWithBoard()
            self.isAnimating = false
            self.resetHintTimer()

            // Update SwiftUI overlay via delegate
            if let state = self.gameState {
                self.gameSceneDelegate?.scoreDidUpdate(to: state.score)
                self.gameSceneDelegate?.movesDidUpdate(to: state.movesRemaining)

                if state.isComplete {
                    self.gameSceneDelegate?.gameDidComplete(stars: state.starRating, score: state.score)
                } else if state.isFailed {
                    self.gameSceneDelegate?.gameDidFail()
                }
            }
        }
    }

    /// Auto-activate Drone Strike (no board tap needed)
    /// Auto-activate Gem Forge (place Crystal Ball + Volatile)
    func activateGemForge() {
        guard let engine = gameEngine, !isAnimating else { return }
        isAnimating = true
        let events = engine.boosterManager.useGemForge(on: engine.board)
        finishBoosterActivation(events: events)
    }

    func activateDroneStrike() {
        guard let engine = gameEngine, let state = gameState, !isAnimating else { return }
        isAnimating = true
        let events = engine.boosterManager.useDroneStrike(on: state.board, state: state)
        finishBoosterActivation(events: events)
    }

    /// Auto-activate Mine Cart Rush on a random populated row
    func activateMineCartRush() {
        guard let engine = gameEngine, let state = gameState, !isAnimating else { return }
        isAnimating = true
        // Pick the row with the most gems
        var bestRow = state.board.numRows / 2
        var bestCount = 0
        for row in 0..<state.board.numRows {
            var count = 0
            for col in 0..<state.board.numColumns {
                if state.board[row, col] != nil { count += 1 }
            }
            if count > bestCount { bestCount = count; bestRow = row }
        }
        let events = engine.boosterManager.useMineCartRush(row: bestRow, on: state.board)
        finishBoosterActivation(events: events)
    }

    private func handleBoosterTap(at point: CGPoint, booster: BoosterType) {
        guard let engine = gameEngine, let state = gameState else { return }
        guard let pos = layout.gridPositionFor(point: point) else {
            activeBooster = nil
            return
        }

        activeBooster = nil
        isAnimating = true

        var events: [GameEvent] = []

        switch booster {
        case .pickaxe:
            events = engine.boosterManager.usePickaxe(at: pos, on: state.board, state: state)
        case .dynamite:
            // Show dynamite icon, glow, pause, then explode
            let worldPos = layout.positionFor(pos)
            let dynamiteIcon = SKLabelNode(text: "\u{1F9E8}") // dynamite emoji
            dynamiteIcon.fontSize = layout.tileSize * 0.7
            dynamiteIcon.position = worldPos
            dynamiteIcon.zPosition = 50
            dynamiteIcon.setScale(0.0)
            boardLayer.addChild(dynamiteIcon)

            // Glow circle
            let glow = SKShapeNode(circleOfRadius: layout.tileSize * 0.5)
            glow.fillColor = SKColor(red: 1.0, green: 0.3, blue: 0.0, alpha: 0.4)
            glow.strokeColor = .clear
            glow.glowWidth = 8
            glow.position = worldPos
            glow.zPosition = 49
            glow.alpha = 0
            boardLayer.addChild(glow)

            dynamiteIcon.run(SKAction.sequence([
                SKAction.scale(to: 1.2, duration: 0.2),
                SKAction.scale(to: 1.0, duration: 0.1),
            ]))
            glow.run(SKAction.sequence([
                SKAction.fadeIn(withDuration: 0.2),
                SKAction.repeatForever(SKAction.sequence([
                    SKAction.fadeAlpha(to: 0.6, duration: 0.15),
                    SKAction.fadeAlpha(to: 0.3, duration: 0.15),
                ]))
            ]))

            // Delay then explode
            run(SKAction.sequence([
                SKAction.wait(forDuration: 0.6),
                SKAction.run { [weak self] in
                    dynamiteIcon.removeFromParent()
                    glow.removeFromParent()
                    events = engine.boosterManager.useDynamite(at: pos, on: state.board, state: state)
                    self?.finishBoosterActivation(events: events)
                }
            ]))
            return

        case .swapCharge:
            // TODO: swap charge needs two taps
            break
        default:
            break
        }

        finishBoosterActivation(events: events)
    }

    private func finishBoosterActivation(events: [GameEvent]) {
        guard let engine = gameEngine, let state = gameState else { isAnimating = false; return }
        var allEvents = events

        if !allEvents.isEmpty {
            let (falls, newGems) = engine.boardFiller.dropAndFill(board: state.board, numColors: state.level.effectiveNumColors)
            if !falls.isEmpty { allEvents.append(.gemsFell(moves: falls)) }
            if !newGems.isEmpty { allEvents.append(.gemsAdded(gems: newGems)) }

            let cascadeEvents = engine.processCascade()
            allEvents.append(contentsOf: cascadeEvents)

            animationController.animateEvents(allEvents) { [weak self] in
                guard let self else { return }
                self.syncSpritesWithBoard()
                self.syncTileSpritesWithBoard()
                self.isAnimating = false
                self.resetHintTimer()

                self.gameSceneDelegate?.scoreDidUpdate(to: state.score)
                self.gameSceneDelegate?.movesDidUpdate(to: state.movesRemaining)

                if state.isComplete {
                    self.gameSceneDelegate?.gameDidComplete(stars: state.starRating, score: state.score)
                } else if state.isFailed {
                    self.gameSceneDelegate?.gameDidFail()
                }
            }
        } else {
            isAnimating = false
            resetHintTimer()
        }
    }

    // MARK: - Objective Display

    private func updateObjectiveDisplay() {
        guard let state = gameState else { return }
        let texts = state.level.objectives.map { obj -> String in
            switch obj {
            case .reachScore(let target):
                return "Score: \(state.score)/\(target)"
            case .clearAllOre:
                return "Ore: \(state.oreCleared)/\(state.totalOre)"
            case .dropTreasures(let count):
                return "Treasure: \(state.treasuresDropped)/\(count)"
            case .collectGems(let color, let count):
                return "\(color.displayName): \(state.gemsCollected[color] ?? 0)/\(count)"
            case .collectSpecials(let type, let count):
                return "\(type.displayName): \(state.specialsCollected[type] ?? 0)/\(count)"
            }
        }
        hud.updateObjective(texts.joined(separator: "\n"))
    }
}
