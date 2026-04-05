import SpriteKit

class GemSprite: SKNode {

    let gem: Gem
    private var bodyNode: SKNode?
    private var specialOverlay: SKNode?
    private let gemSize: CGFloat

    var gridPosition: GridPosition {
        GridPosition(row: gem.row, column: gem.column)
    }

    init(gem: Gem, size: CGFloat) {
        self.gem = gem
        self.gemSize = size
        super.init()
        self.name = "gem_\(gem.id.uuidString)"
        buildVisual()
    }

    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) not supported")
    }

    private func buildVisual() {
        // Remove old children
        removeAllChildren()

        switch gem.special {
        case .crystalBall:
            bodyNode = GemRenderer.createCrystalBallNode(size: gemSize)
        case .miningDrone:
            bodyNode = GemRenderer.createDroneNode(size: gemSize)
        default:
            bodyNode = GemRenderer.createGemNode(color: gem.color, size: gemSize)
        }

        if let body = bodyNode {
            addChild(body)
        }

        // Add special overlay
        switch gem.special {
        case .laserHorizontal, .laserVertical:
            specialOverlay = GemRenderer.createLaserOverlay(
                direction: gem.special, size: gemSize, color: gem.color
            )
            if let overlay = specialOverlay {
                overlay.zPosition = 1
                addChild(overlay)
            }
        case .volatile:
            specialOverlay = GemRenderer.createVolatileOverlay(size: gemSize, color: gem.color)
            if let overlay = specialOverlay {
                overlay.zPosition = 1
                addChild(overlay)
            }
        default:
            break
        }

        // Idle breathing animation (subtle)
        let breathe = SKAction.sequence([
            SKAction.scale(to: 1.03, duration: 1.2),
            SKAction.scale(to: 1.0, duration: 1.2)
        ])
        bodyNode?.run(SKAction.repeatForever(breathe), withKey: "breathe")
    }

    /// Update visual when gem becomes special
    func updateSpecial(to type: SpecialType) {
        buildVisual()
    }

    /// Highlight when selected
    func setHighlighted(_ highlighted: Bool) {
        if highlighted {
            let overshoot = SKAction.scale(to: 1.18, duration: 0.08)
            overshoot.timingMode = .easeOut
            let settle = SKAction.scale(to: 1.12, duration: 0.06)
            settle.timingMode = .easeInEaseOut
            run(SKAction.sequence([overshoot, settle]), withKey: "highlight")
        } else {
            run(SKAction.scale(to: 1.0, duration: 0.1), withKey: "highlight")
        }
    }
}
