import SpriteKit
import UIKit

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

    // Booster mode
    var activeBooster: BoosterType?

    // MARK: - Setup

    func configure(state: GameState, engine: GameEngine) {
        self.gameState = state
        self.gameEngine = engine
        state.godModeEnabled = godModeEnabled
    }

    override func didMove(to view: SKView) {
        guard let state = gameState else { return }

        backgroundColor = SKColor(hex: 0x1A0F0A)
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

        // Create HUD
        hud = HUDNode(width: size.width)
        hud.position = layout.hudOrigin
        hud.zPosition = 20
        addChild(hud)

        // Initialize board
        let _ = gameEngine?.initializeBoard(seed: UInt64(state.level.number) &* 2654435761)

        // Build tile and gem sprites
        buildTileSprites()
        buildGemSprites()

        // Update HUD
        hud.updateScore(state.score)
        hud.updateMoves(state.movesRemaining, godMode: godModeEnabled)
        updateObjectiveDisplay()
    }

    override func didChangeSize(_ oldSize: CGSize) {
        guard let state = gameState, size.width > 0, size.height > 0 else { return }
        layout = BoardLayout(sceneSize: size,
                              numRows: state.board.numRows,
                              numColumns: state.board.numColumns)
        animationController = AnimationController(layout: layout)
        animationController.scene = self
        rebuildAllSprites()

        hud?.position = layout.hudOrigin
    }

    // MARK: - Background

    private func setupBackground() {
        // Gradient background (rendered texture)
        let bgSize = CGSize(width: size.width, height: size.height)
        let bgRenderer = UIGraphicsImageRenderer(size: bgSize)
        let bgImage = bgRenderer.image { ctx in
            let gc = ctx.cgContext
            let colorSpace = CGColorSpaceCreateDeviceRGB()
            let topColor = UIColor(red: 0.08, green: 0.05, blue: 0.15, alpha: 1.0)   // Dark blue-purple
            let midColor = UIColor(red: 0.12, green: 0.07, blue: 0.04, alpha: 1.0)    // Cave brown
            let botColor = UIColor(red: 0.05, green: 0.03, blue: 0.02, alpha: 1.0)    // Near black
            let colors = [topColor.cgColor, midColor.cgColor, botColor.cgColor] as CFArray
            if let gradient = CGGradient(colorsSpace: colorSpace, colors: colors, locations: [0.0, 0.5, 1.0]) {
                gc.drawLinearGradient(gradient,
                                      start: CGPoint(x: bgSize.width / 2, y: 0),
                                      end: CGPoint(x: bgSize.width / 2, y: bgSize.height),
                                      options: [])
            }
            // Subtle vignette
            let vignetteColors = [
                UIColor(white: 0.0, alpha: 0.0).cgColor,
                UIColor(white: 0.0, alpha: 0.4).cgColor
            ] as CFArray
            if let vignetteGrad = CGGradient(colorsSpace: colorSpace, colors: vignetteColors, locations: [0.0, 1.0]) {
                let center = CGPoint(x: bgSize.width / 2, y: bgSize.height / 2)
                let radius = max(bgSize.width, bgSize.height) * 0.7
                gc.drawRadialGradient(vignetteGrad,
                                      startCenter: center, startRadius: radius * 0.3,
                                      endCenter: center, endRadius: radius,
                                      options: [.drawsAfterEndLocation])
            }
        }
        let bgTex = SKTexture(image: bgImage)
        let bg = SKSpriteNode(texture: bgTex, size: bgSize)
        bg.position = CGPoint(x: size.width / 2, y: size.height / 2)
        bg.zPosition = -10
        addChild(bg)

        // Board dark background
        let boardBg = SKShapeNode(rectOf: CGSize(
            width: layout.boardSize.width + 12,
            height: layout.boardSize.height + 12
        ), cornerRadius: 8)
        boardBg.position = CGPoint(
            x: layout.boardOrigin.x + layout.boardSize.width / 2,
            y: layout.boardOrigin.y + layout.boardSize.height / 2
        )
        boardBg.fillColor = ColorPalette.boardBackground
        boardBg.strokeColor = .clear
        boardBg.zPosition = -5
        boardLayer.addChild(boardBg)

        // Golden decorative frame around board
        let frameSize = CGSize(
            width: layout.boardSize.width + 24,
            height: layout.boardSize.height + 24
        )
        let frameTex = TextureFactory.shared.boardFrameTexture(size: frameSize, frameWidth: 6)
        let frame = SKSpriteNode(texture: frameTex, size: frameSize)
        frame.position = boardBg.position
        frame.zPosition = -4
        boardLayer.addChild(frame)

        // Ambient dust particles
        addAmbientParticles()
    }

    private func addAmbientParticles() {
        let glowTex = TextureFactory.shared.softGlowTexture(size: 8)
        let emitter = SKEmitterNode()
        emitter.particleTexture = glowTex
        emitter.particleBirthRate = 3
        emitter.particleLifetime = 6
        emitter.particleLifetimeRange = 3
        emitter.emissionAngle = .pi / 2
        emitter.emissionAngleRange = .pi * 2
        emitter.particleSpeed = 8
        emitter.particleSpeedRange = 5
        emitter.particleAlpha = 0.15
        emitter.particleAlphaRange = 0.1
        emitter.particleAlphaSpeed = -0.02
        emitter.particleScale = 0.3
        emitter.particleScaleRange = 0.2
        emitter.particleColor = ColorPalette.sparkleGold
        emitter.particleColorBlendFactor = 1.0
        emitter.particleBlendMode = .add
        emitter.position = CGPoint(
            x: layout.boardOrigin.x + layout.boardSize.width / 2,
            y: layout.boardOrigin.y + layout.boardSize.height / 2
        )
        emitter.particlePositionRange = CGVector(
            dx: layout.boardSize.width,
            dy: layout.boardSize.height
        )
        emitter.zPosition = 5
        boardLayer.addChild(emitter)
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
                sprite.zPosition = 10
                boardLayer.addChild(sprite)
                gemSprites[row][col] = sprite
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
        gemSprites[pos.row][pos.column]?.removeFromParent()

        let sprite = GemSprite(gem: gem, size: layout.gemSize)
        sprite.position = layout.positionFor(pos)
        sprite.zPosition = 10
        boardLayer.addChild(sprite)
        gemSprites[pos.row][pos.column] = sprite
    }

    // MARK: - Sprite Access (for AnimationController)

    func gemSpriteAt(_ pos: GridPosition) -> GemSprite? {
        guard pos.row >= 0 && pos.row < gemSprites.count &&
              pos.column >= 0 && pos.column < gemSprites[0].count else { return nil }
        return gemSprites[pos.row][pos.column]
    }

    func tileAt(_ pos: GridPosition) -> TileSprite? {
        guard pos.row >= 0 && pos.row < tileSprites.count &&
              pos.column >= 0 && pos.column < tileSprites[0].count else { return nil }
        return tileSprites[pos.row][pos.column]
    }

    func setGemSprite(_ sprite: GemSprite, at pos: GridPosition) {
        guard pos.row >= 0 && pos.row < gemSprites.count &&
              pos.column >= 0 && pos.column < gemSprites[0].count else { return }
        gemSprites[pos.row][pos.column] = sprite
    }

    func removeGemSprite(at pos: GridPosition) {
        guard pos.row >= 0 && pos.row < gemSprites.count &&
              pos.column >= 0 && pos.column < gemSprites[0].count else { return }
        gemSprites[pos.row][pos.column] = nil
    }

    func moveGemSprite(from: GridPosition, to: GridPosition) {
        let sprite = gemSprites[from.row][from.column]
        gemSprites[from.row][from.column] = nil
        gemSprites[to.row][to.column] = sprite
    }

    func updateGemSpriteMapping(from posA: GridPosition, to posB: GridPosition) {
        let spriteA = gemSprites[posA.row][posA.column]
        let spriteB = gemSprites[posB.row][posB.column]
        gemSprites[posA.row][posA.column] = spriteB
        gemSprites[posB.row][posB.column] = spriteA
    }

    // MARK: - Touch Handling

    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        guard !isAnimating, let touch = touches.first else { return }
        let point = touch.location(in: boardLayer)

        if let booster = activeBooster {
            handleBoosterTap(at: point, booster: booster)
            return
        }

        touchStartPos = layout.gridPositionFor(point: point)
        swipeHandled = false

        if let pos = touchStartPos {
            gemSpriteAt(pos)?.setHighlighted(true)
        }
    }

    override func touchesMoved(_ touches: Set<UITouch>, with event: UIEvent?) {
        guard !isAnimating, !swipeHandled, let touch = touches.first, let startPos = touchStartPos else { return }
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
        if let pos = touchStartPos {
            gemSpriteAt(pos)?.setHighlighted(false)
        }
        touchStartPos = nil
        swipeHandled = false
    }

    override func touchesCancelled(_ touches: Set<UITouch>, with event: UIEvent?) {
        touchesEnded(touches, with: event)
    }

    // MARK: - Game Actions

    private func handleSwap(from: GridPosition, to: GridPosition) {
        guard let engine = gameEngine else { return }
        guard !isAnimating else { return }

        isAnimating = true
        let events = engine.handleSwap(from: from, to: to)

        animationController.animateEvents(events) { [weak self] in
            guard let self = self else { return }
            self.isAnimating = false

            // Update HUD
            if let state = self.gameState {
                self.hud.updateMoves(state.movesRemaining, godMode: self.godModeEnabled)
                self.hud.updateScore(state.score)
                self.updateObjectiveDisplay()

                // Check game end
                if state.isComplete {
                    self.gameSceneDelegate?.gameDidComplete(stars: state.starRating, score: state.score)
                } else if state.isFailed {
                    self.gameSceneDelegate?.gameDidFail()
                }
            }
        }
    }

    private func handleBoosterTap(at point: CGPoint, booster: BoosterType) {
        guard let engine = gameEngine, let state = gameState else { return }
        guard let pos = layout.gridPositionFor(point: point) else { return }

        activeBooster = nil
        isAnimating = true

        var events: [GameEvent] = []

        switch booster {
        case .pickaxe:
            events = engine.boosterManager.usePickaxe(at: pos, on: state.board, state: state)
        case .mineCartRush:
            events = engine.boosterManager.useMineCartRush(row: pos.row, on: state.board)
        case .droneStrike:
            events = engine.boosterManager.useDroneStrike(on: state.board, state: state)
        default:
            break
        }

        if !events.isEmpty {
            // After booster, need to drop and cascade
            let boardFiller = BoardFiller()
            let (falls, newGems) = boardFiller.dropAndFill(board: state.board, numColors: state.level.effectiveNumColors)
            if !falls.isEmpty { events.append(.gemsFell(moves: falls)) }
            if !newGems.isEmpty { events.append(.gemsAdded(gems: newGems)) }

            animationController.animateEvents(events) { [weak self] in
                self?.isAnimating = false
                self?.hud.updateScore(state.score)
                self?.hud.updateMoves(state.movesRemaining, godMode: self?.godModeEnabled ?? false)
            }
        } else {
            isAnimating = false
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
