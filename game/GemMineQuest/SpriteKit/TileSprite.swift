import SpriteKit
import UIKit

class TileSprite: SKNode {

    let gridPosition: GridPosition
    let tileSize: CGFloat
    let isLightTile: Bool
    private var backgroundNode: SKNode?
    private var overlayNode: SKNode?

    init(position: GridPosition, tileType: TileType, blocker: BlockerType?, size: CGFloat) {
        self.gridPosition = position
        self.tileSize = size
        self.isLightTile = (position.row + position.column) % 2 == 0
        super.init()
        self.name = "tile_\(position.row)_\(position.column)"
        buildVisual(tileType: tileType, blocker: blocker)
    }

    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) not supported")
    }

    private func buildVisual(tileType: TileType, blocker: BlockerType?) {
        removeAllChildren()

        guard tileType != .empty else { return }

        // Texture-based tile with CoreGraphics bevel and gradient
        let isLight = (gridPosition.row + gridPosition.column) % 2 == 0
        let tileTex = TextureFactory.shared.tileTexture(size: tileSize, isLight: isLight)
        let bg = SKSpriteNode(texture: tileTex, size: CGSize(width: tileSize, height: tileSize))
        backgroundNode = bg
        addChild(bg)

        // Ore vein overlay
        if tileType == .oreVein || tileType == .doubleOre {
            // Full gold override — prevents blue tile bleed-through
            if let sprite = backgroundNode as? SKSpriteNode {
                sprite.color = SKColor(red: 0.82, green: 0.65, blue: 0.20, alpha: 1.0)
                sprite.colorBlendFactor = 1.0
            }

            let overlay = createOreOverlay(double: tileType == .doubleOre)
            overlay.zPosition = -0.5
            overlayNode = overlay
            addChild(overlay)
        }

        // Mine cart overlay
        if tileType == .mineCart {
            let cart = createMineCartOverlay()
            cart.zPosition = -0.5
            addChild(cart)
        }

        // Blocker overlay
        if let blocker = blocker {
            let blockerNode = createBlockerOverlay(blocker)
            switch blocker {
            case .lava:
                blockerNode.zPosition = 0.5  // Between tile (0) and gem (1.0+)
            default:
                blockerNode.zPosition = 2    // Above gem for cage, granite, etc.
            }
            addChild(blockerNode)
        }
    }

    func updateOre(tileType: TileType) {
        overlayNode?.removeFromParent()
        overlayNode = nil

        if tileType == .oreVein || tileType == .doubleOre {
            // Full gold override — prevents blue tile bleed-through
            if let sprite = backgroundNode as? SKSpriteNode {
                sprite.color = SKColor(red: 0.82, green: 0.65, blue: 0.20, alpha: 1.0)
                sprite.colorBlendFactor = 1.0
            }

            let overlay = createOreOverlay(double: tileType == .doubleOre)
            overlay.zPosition = -0.5
            overlayNode = overlay
            addChild(overlay)
        } else {
            // Restore normal tile (no tint)
            if let sprite = backgroundNode as? SKSpriteNode {
                sprite.colorBlendFactor = 0.0
            }
        }
    }

    func clearHighlight() {
        if let sprite = backgroundNode as? SKSpriteNode {
            sprite.colorBlendFactor = 0.0
            sprite.color = .white
        }
    }

    func updateBlocker(_ blocker: BlockerType?) {
        children.filter { ($0.name ?? "").hasPrefix("blocker") }.forEach { $0.removeFromParent() }

        if let blocker = blocker {
            let node = createBlockerOverlay(blocker)
            node.name = "blocker"
            node.zPosition = 2
            addChild(node)
        }
    }

    // MARK: - Overlays

    private func createOreOverlay(double: Bool) -> SKNode {
        let container = SKNode()
        let rect = CGSize(width: tileSize - 2, height: tileSize - 2)

        // Bright gold fill - very visible
        let ore = SKShapeNode(rectOf: rect, cornerRadius: 4)
        ore.fillColor = double
            ? SKColor(red: 0.85, green: 0.65, blue: 0.10, alpha: 0.70)
            : SKColor(red: 0.75, green: 0.55, blue: 0.10, alpha: 0.60)
        ore.strokeColor = SKColor(hex: 0xFFD700)
        ore.lineWidth = double ? 3.5 : 3.0
        ore.glowWidth = double ? 4.0 : 2.5
        container.addChild(ore)

        // Thin gold border stroke
        let border = SKShapeNode(rectOf: rect, cornerRadius: 4)
        border.fillColor = .clear
        border.strokeColor = SKColor(hex: 0xFFD700)
        border.lineWidth = 1.5
        container.addChild(border)

        // Gold sparkle flecks - bigger and brighter
        let numFlecks = double ? 6 : 4
        for i in 0..<numFlecks {
            let fleck = SKShapeNode(circleOfRadius: tileSize * 0.04)
            fleck.fillColor = SKColor(hex: 0xFFD700, alpha: 0.9)
            fleck.strokeColor = .clear
            fleck.glowWidth = 2.5
            let angle = CGFloat(i) / CGFloat(numFlecks) * .pi * 2 + 0.5
            let dist = tileSize * CGFloat.random(in: 0.12...0.30)
            fleck.position = CGPoint(x: cos(angle) * dist, y: sin(angle) * dist)
            container.addChild(fleck)
        }

        // Corner gold nuggets for extra visibility
        let nuggetPositions: [CGPoint] = [
            CGPoint(x: -tileSize * 0.28, y: tileSize * 0.28),
            CGPoint(x: tileSize * 0.28, y: -tileSize * 0.28),
        ]
        for pos in nuggetPositions {
            let nugget = SKShapeNode(circleOfRadius: tileSize * 0.06)
            nugget.fillColor = SKColor(hex: 0xFFD700)
            nugget.strokeColor = SKColor(hex: 0xDAA520)
            nugget.lineWidth = 1.0
            nugget.glowWidth = 2.0
            nugget.position = pos
            container.addChild(nugget)
        }

        // Pickaxe icon - bigger
        let icon = SKLabelNode(text: double ? "\u{26CF}\u{26CF}" : "\u{26CF}")
        icon.fontSize = tileSize * 0.28
        icon.verticalAlignmentMode = .center
        icon.position = CGPoint(x: 0, y: -tileSize * 0.30)
        container.addChild(icon)

        // Pulsing glow animation
        let pulse = SKAction.sequence([
            SKAction.fadeAlpha(to: 0.7, duration: 0.6),
            SKAction.fadeAlpha(to: 1.0, duration: 0.6)
        ])
        container.run(SKAction.repeatForever(pulse))

        return container
    }

    private func createMineCartOverlay() -> SKNode {
        let container = SKNode()

        // Cart body with beveled look
        let cartWidth = tileSize * 0.7
        let cartHeight = tileSize * 0.4
        let cart = SKShapeNode(rectOf: CGSize(width: cartWidth, height: cartHeight), cornerRadius: 4)
        cart.fillColor = SKColor(hex: 0x5C4033)
        cart.strokeColor = SKColor(hex: 0x8B7355)
        cart.lineWidth = 1.5
        cart.position = CGPoint(x: 0, y: -tileSize * 0.1)
        container.addChild(cart)

        // Cart interior highlight
        let interior = SKShapeNode(rectOf: CGSize(width: cartWidth * 0.8, height: cartHeight * 0.6), cornerRadius: 2)
        interior.fillColor = SKColor(hex: 0x3A2A1A)
        interior.strokeColor = .clear
        interior.position = CGPoint(x: 0, y: -tileSize * 0.07)
        container.addChild(interior)

        // Metal wheels with spokes
        for dx: CGFloat in [-1, 1] {
            let wheelR = tileSize * 0.09
            let wheel = SKShapeNode(circleOfRadius: wheelR)
            wheel.fillColor = SKColor(hex: 0x707070)
            wheel.strokeColor = SKColor(hex: 0x505050)
            wheel.lineWidth = 1.0
            wheel.position = CGPoint(x: dx * cartWidth * 0.3, y: -tileSize * 0.27)
            container.addChild(wheel)

            // Hub
            let hub = SKShapeNode(circleOfRadius: wheelR * 0.3)
            hub.fillColor = SKColor(hex: 0x909090)
            hub.strokeColor = .clear
            hub.position = wheel.position
            container.addChild(hub)
        }

        // Gold arrow pointing down
        let arrow = SKLabelNode(text: "\u{25BC}")
        arrow.fontSize = tileSize * 0.25
        arrow.fontColor = ColorPalette.textGold
        arrow.position = CGPoint(x: 0, y: tileSize * 0.2)
        container.addChild(arrow)

        return container
    }

    private func createBlockerOverlay(_ blocker: BlockerType) -> SKNode {
        let container = SKNode()
        container.name = "blocker"
        let spriteSize = CGSize(width: tileSize * 0.95, height: tileSize * 0.95)

        switch blocker {
        case .granite(let layers):
            let assetName = "blocker_granite_\(layers)"
            if let texture = loadBlockerTexture(named: assetName) {
                let sprite = SKSpriteNode(texture: texture, size: spriteSize)
                container.addChild(sprite)
            }
            // Layer indicator dots
            let dotSpacing: CGFloat = 9
            let startX = -dotSpacing * CGFloat(layers - 1) / 2
            for i in 0..<layers {
                let dot = SKShapeNode(circleOfRadius: 3.5)
                dot.fillColor = SKColor(white: 1.0, alpha: 0.9)
                dot.strokeColor = SKColor(white: 0.0, alpha: 0.3)
                dot.lineWidth = 0.5
                dot.position = CGPoint(x: startX + CGFloat(i) * dotSpacing, y: -tileSize * 0.34)
                container.addChild(dot)
            }

        case .boulder:
            if let texture = loadBlockerTexture(named: "blocker_boulder") {
                let sprite = SKSpriteNode(texture: texture, size: spriteSize)
                container.addChild(sprite)
            }

        case .cage:
            if let texture = loadBlockerTexture(named: "blocker_cage") {
                let sprite = SKSpriteNode(texture: texture, size: spriteSize)
                container.addChild(sprite)
            }

        case .lava:
            if let texture = loadBlockerTexture(named: "blocker_lava") {
                let sprite = SKSpriteNode(texture: texture, size: spriteSize)
                container.addChild(sprite)
            }
            // Pulsing glow animation
            let pulse = SKAction.sequence([
                SKAction.group([
                    SKAction.scale(to: 1.04, duration: 0.7),
                    SKAction.fadeAlpha(to: 0.5, duration: 0.7)
                ]),
                SKAction.group([
                    SKAction.scale(to: 1.0, duration: 0.7),
                    SKAction.fadeAlpha(to: 0.7, duration: 0.7)
                ])
            ])
            container.run(SKAction.repeatForever(pulse))

        case .tnt(let countdown):
            if let texture = loadBlockerTexture(named: "blocker_tnt") {
                let sprite = SKSpriteNode(texture: texture, size: spriteSize)
                container.addChild(sprite)
            }
            // Countdown number overlay
            let label = SKLabelNode(text: "\(countdown)")
            label.fontName = "AvenirNext-Heavy"
            label.fontSize = tileSize * 0.34
            label.fontColor = .white
            label.verticalAlignmentMode = .center
            label.zPosition = 1
            container.addChild(label)
            // Fuse spark
            let spark = SKShapeNode(circleOfRadius: 3.0)
            spark.fillColor = SKColor(hex: 0xFF6600)
            spark.strokeColor = .clear
            spark.glowWidth = 4.0
            spark.position = CGPoint(x: tileSize * 0.15, y: tileSize * 0.42)
            spark.zPosition = 1
            container.addChild(spark)
            let sparkPulse = SKAction.sequence([
                SKAction.fadeAlpha(to: 0.4, duration: 0.15),
                SKAction.fadeAlpha(to: 1.0, duration: 0.15)
            ])
            spark.run(SKAction.repeatForever(sparkPulse))

        case .amber:
            if let texture = loadBlockerTexture(named: "blocker_amber") {
                let sprite = SKSpriteNode(texture: texture, size: spriteSize)
                container.addChild(sprite)
            }
        }

        return container
    }

    private func loadBlockerTexture(named name: String) -> SKTexture? {
        guard let image = UIImage(named: name) else { return nil }
        let texture = SKTexture(image: image)
        texture.filteringMode = .linear
        return texture
    }
}
