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
    }

    /// Update visual when gem becomes special
    func updateSpecial(to type: SpecialType) {
        buildVisual()
    }

    /// Highlight when selected
    func setHighlighted(_ highlighted: Bool) {
        if highlighted {
            run(SKAction.scale(to: 1.1, duration: 0.1))
        } else {
            run(SKAction.scale(to: 1.0, duration: 0.1))
        }
    }
}
