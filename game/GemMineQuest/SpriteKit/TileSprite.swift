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
            case .lava, .amber:
                blockerNode.zPosition = 0.5  // Below gem — gem shows through
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
            switch blocker {
            case .lava, .amber:
                node.zPosition = 0.5  // Below gem — gem shows through
            default:
                node.zPosition = 2    // Above gem for cage, granite, etc.
            }
            addChild(node)
        }
    }

    // MARK: - Overlays

    private func createOreOverlay(double: Bool) -> SKNode {
        let container = SKNode()
        let halfSize = tileSize * 0.47

        // Diagonal gold lines at 45° angle
        let linePath = CGMutablePath()
        let spacing: CGFloat = tileSize * (double ? 0.10 : 0.14)
        let extent = halfSize * 2.5  // extend beyond tile for full coverage at 45°
        var offset = -extent
        while offset <= extent {
            // Lines going ↘
            linePath.move(to: CGPoint(x: -halfSize, y: offset))
            linePath.addLine(to: CGPoint(x: halfSize, y: offset - halfSize * 2))
            offset += spacing
        }

        let lines = SKShapeNode(path: linePath)
        lines.strokeColor = SKColor(hex: 0xFFD700, alpha: double ? 0.8 : 0.6)
        lines.lineWidth = double ? 2.0 : 1.5
        lines.glowWidth = double ? 1.5 : 1.0
        lines.fillColor = .clear

        // Crop lines to tile bounds
        let mask = SKShapeNode(rectOf: CGSize(width: tileSize - 2, height: tileSize - 2), cornerRadius: 4)
        mask.fillColor = .white
        let crop = SKCropNode()
        crop.maskNode = mask
        crop.addChild(lines)
        container.addChild(crop)

        // Thin gold border
        let border = SKShapeNode(rectOf: CGSize(width: tileSize - 2, height: tileSize - 2), cornerRadius: 4)
        border.fillColor = .clear
        border.strokeColor = SKColor(hex: 0xFFD700, alpha: 0.5)
        border.lineWidth = 1.5
        container.addChild(border)

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
                sprite.alpha = 0.9  // Slightly transparent so gem beneath is visible
                container.addChild(sprite)
            }

        case .lava:
            let lavaSize = CGSize(width: tileSize, height: tileSize)
            if let texture = loadBlockerTexture(named: "blocker_lava") {
                let sprite = SKSpriteNode(texture: texture, size: lavaSize)
                container.addChild(sprite)
            }
            // Subtle scale pulse — fully opaque
            let pulse = SKAction.sequence([
                SKAction.scale(to: 1.04, duration: 0.7),
                SKAction.scale(to: 1.0, duration: 0.7)
            ])
            container.run(SKAction.repeatForever(pulse))

        case .tnt(let countdown):
            let tntSize = CGSize(width: tileSize, height: tileSize)
            if let texture = loadBlockerTexture(named: "blocker_tnt") {
                let sprite = SKSpriteNode(texture: texture, size: tntSize)
                container.addChild(sprite)
            }
            // Countdown number with dark grey outline
            let outline = SKLabelNode(text: "\(countdown)")
            outline.fontName = "AvenirNext-Heavy"
            outline.fontSize = tileSize * 0.38
            outline.fontColor = SKColor(hex: 0x333333)
            outline.verticalAlignmentMode = .center
            outline.zPosition = 1
            container.addChild(outline)
            // Offset copies for stroke effect
            for dx: CGFloat in [-1, 0, 1] {
                for dy: CGFloat in [-1, 0, 1] {
                    if dx == 0 && dy == 0 { continue }
                    let strokeLabel = SKLabelNode(text: "\(countdown)")
                    strokeLabel.fontName = "AvenirNext-Heavy"
                    strokeLabel.fontSize = tileSize * 0.38
                    strokeLabel.fontColor = SKColor(hex: 0x333333)
                    strokeLabel.verticalAlignmentMode = .center
                    strokeLabel.position = CGPoint(x: dx * 1.2, y: dy * 1.2)
                    strokeLabel.zPosition = 1
                    container.addChild(strokeLabel)
                }
            }
            // White number on top
            let label = SKLabelNode(text: "\(countdown)")
            label.fontName = "AvenirNext-Heavy"
            label.fontSize = tileSize * 0.38
            label.fontColor = .white
            label.verticalAlignmentMode = .center
            label.zPosition = 2
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
            if let texture = loadBlockerTexture(named: "blocker_topaz") {
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
