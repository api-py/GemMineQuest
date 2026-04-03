import SpriteKit

class TileSprite: SKNode {

    let gridPosition: GridPosition
    let tileSize: CGFloat
    private var backgroundNode: SKShapeNode?
    private var overlayNode: SKNode?

    init(position: GridPosition, tileType: TileType, blocker: BlockerType?, size: CGFloat) {
        self.gridPosition = position
        self.tileSize = size
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

        // Base tile
        let inset: CGFloat = 1.0
        let rect = CGSize(width: tileSize - inset * 2, height: tileSize - inset * 2)
        let bg = SKShapeNode(rectOf: rect, cornerRadius: 4)
        bg.fillColor = ColorPalette.tileNormal
        bg.strokeColor = SKColor(white: 0.3, alpha: 0.2)
        bg.lineWidth = 0.5
        backgroundNode = bg
        addChild(bg)

        // Ore vein overlay
        if tileType == .oreVein || tileType == .doubleOre {
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
            blockerNode.zPosition = 2
            addChild(blockerNode)
        }
    }

    func updateOre(tileType: TileType) {
        overlayNode?.removeFromParent()
        if tileType == .oreVein || tileType == .doubleOre {
            let overlay = createOreOverlay(double: tileType == .doubleOre)
            overlay.zPosition = -0.5
            overlayNode = overlay
            addChild(overlay)
        } else {
            overlayNode = nil
        }
    }

    func updateBlocker(_ blocker: BlockerType?) {
        // Remove existing blocker overlay
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
        let inset: CGFloat = 2.0
        let rect = CGSize(width: tileSize - inset * 2, height: tileSize - inset * 2)

        let ore = SKShapeNode(rectOf: rect, cornerRadius: 3)
        ore.fillColor = double ? ColorPalette.oreVeinDouble.withAlphaComponent(0.35) : ColorPalette.oreVein.withAlphaComponent(0.25)
        ore.strokeColor = double ? ColorPalette.oreVeinDouble.withAlphaComponent(0.6) : ColorPalette.oreVein.withAlphaComponent(0.4)
        ore.lineWidth = double ? 2.0 : 1.5
        container.addChild(ore)

        // Speckles
        let speckleCount = double ? 6 : 3
        for _ in 0..<speckleCount {
            let speckle = SKShapeNode(circleOfRadius: 2)
            speckle.fillColor = ColorPalette.sparkleGold.withAlphaComponent(0.5)
            speckle.strokeColor = .clear
            let maxOffset = tileSize * 0.35
            speckle.position = CGPoint(
                x: CGFloat.random(in: -maxOffset...maxOffset),
                y: CGFloat.random(in: -maxOffset...maxOffset)
            )
            container.addChild(speckle)
        }

        return container
    }

    private func createMineCartOverlay() -> SKNode {
        let container = SKNode()

        // Cart shape
        let cartWidth = tileSize * 0.7
        let cartHeight = tileSize * 0.4
        let cart = SKShapeNode(rectOf: CGSize(width: cartWidth, height: cartHeight), cornerRadius: 3)
        cart.fillColor = SKColor(hex: 0x5C4033)
        cart.strokeColor = SKColor(hex: 0x8B7355)
        cart.lineWidth = 1.5
        cart.position = CGPoint(x: 0, y: -tileSize * 0.1)
        container.addChild(cart)

        // Wheels
        for dx: CGFloat in [-1, 1] {
            let wheel = SKShapeNode(circleOfRadius: tileSize * 0.08)
            wheel.fillColor = SKColor(hex: 0x808080)
            wheel.strokeColor = SKColor(hex: 0x606060)
            wheel.position = CGPoint(x: dx * cartWidth * 0.3, y: -tileSize * 0.25)
            container.addChild(wheel)
        }

        // Arrow pointing down
        let arrow = SKLabelNode(text: "\u{25BC}") // Down arrow
        arrow.fontSize = tileSize * 0.25
        arrow.fontColor = ColorPalette.textGold
        arrow.position = CGPoint(x: 0, y: tileSize * 0.2)
        container.addChild(arrow)

        return container
    }

    private func createBlockerOverlay(_ blocker: BlockerType) -> SKNode {
        let container = SKNode()
        container.name = "blocker"

        switch blocker {
        case .granite(let layers):
            let rect = CGSize(width: tileSize * 0.9, height: tileSize * 0.9)
            let stone = SKShapeNode(rectOf: rect, cornerRadius: 2)
            let alpha = 0.4 + Double(layers) * 0.2
            stone.fillColor = ColorPalette.granite.withAlphaComponent(alpha)
            stone.strokeColor = ColorPalette.graniteCracked
            stone.lineWidth = CGFloat(layers)
            container.addChild(stone)

            // Crack lines for damaged granite
            if layers < 3 {
                let crack = SKShapeNode()
                let path = CGMutablePath()
                path.move(to: CGPoint(x: -tileSize * 0.2, y: tileSize * 0.2))
                path.addLine(to: CGPoint(x: tileSize * 0.1, y: -tileSize * 0.1))
                if layers == 1 {
                    path.addLine(to: CGPoint(x: tileSize * 0.2, y: -tileSize * 0.25))
                }
                crack.path = path
                crack.strokeColor = SKColor(white: 0.3, alpha: 0.6)
                crack.lineWidth = 1.5
                container.addChild(crack)
            }

        case .boulder:
            let boulder = SKShapeNode(circleOfRadius: tileSize * 0.38)
            boulder.fillColor = ColorPalette.boulder
            boulder.strokeColor = SKColor(hex: 0x3D2B1F)
            boulder.lineWidth = 1.5
            container.addChild(boulder)

        case .cage:
            // Vertical bars
            let barCount = 3
            let spacing = tileSize * 0.7 / CGFloat(barCount + 1)
            for i in 1...barCount {
                let bar = SKShapeNode(rectOf: CGSize(width: 2, height: tileSize * 0.8))
                bar.fillColor = ColorPalette.cage
                bar.strokeColor = .clear
                bar.position.x = -tileSize * 0.35 + spacing * CGFloat(i)
                container.addChild(bar)
            }
            // Horizontal bars
            for dy: CGFloat in [-0.3, 0, 0.3] {
                let bar = SKShapeNode(rectOf: CGSize(width: tileSize * 0.8, height: 2))
                bar.fillColor = ColorPalette.cage
                bar.strokeColor = .clear
                bar.position.y = dy * tileSize
                container.addChild(bar)
            }

        case .lava:
            let lava = SKShapeNode(rectOf: CGSize(width: tileSize * 0.9, height: tileSize * 0.9), cornerRadius: 3)
            lava.fillColor = ColorPalette.lava.withAlphaComponent(0.7)
            lava.strokeColor = ColorPalette.lavaGlow
            lava.lineWidth = 2
            lava.glowWidth = 4
            container.addChild(lava)

            // Pulsing glow
            lava.run(VisualEffects.pulseAction(scale: 1.05, duration: 1.0))

        case .tnt(let countdown):
            let tntBody = SKShapeNode(circleOfRadius: tileSize * 0.35)
            tntBody.fillColor = ColorPalette.tnt
            tntBody.strokeColor = SKColor.black
            tntBody.lineWidth = 1.5
            container.addChild(tntBody)

            let label = SKLabelNode(text: "\(countdown)")
            label.fontName = "AvenirNext-Bold"
            label.fontSize = tileSize * 0.35
            label.fontColor = .white
            label.verticalAlignmentMode = .center
            container.addChild(label)

            // Fuse line
            let fuse = SKShapeNode()
            let fusePath = CGMutablePath()
            fusePath.move(to: CGPoint(x: 0, y: tileSize * 0.35))
            fusePath.addCurve(to: CGPoint(x: tileSize * 0.15, y: tileSize * 0.5),
                              control1: CGPoint(x: tileSize * 0.1, y: tileSize * 0.4),
                              control2: CGPoint(x: tileSize * 0.05, y: tileSize * 0.45))
            fuse.path = fusePath
            fuse.strokeColor = SKColor(hex: 0xDEB887)
            fuse.lineWidth = 1.5
            container.addChild(fuse)

        case .amber:
            let amberRect = SKShapeNode(rectOf: CGSize(width: tileSize * 0.85, height: tileSize * 0.85), cornerRadius: 6)
            amberRect.fillColor = ColorPalette.amber.withAlphaComponent(0.4)
            amberRect.strokeColor = ColorPalette.amber.withAlphaComponent(0.7)
            amberRect.lineWidth = 2.0
            container.addChild(amberRect)
        }

        return container
    }
}
