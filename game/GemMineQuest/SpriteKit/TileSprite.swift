import SpriteKit

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
            // Tint tile gold for ore
            if let sprite = backgroundNode as? SKSpriteNode {
                sprite.color = SKColor(hex: 0xDAA520)
                sprite.colorBlendFactor = tileType == .doubleOre ? 0.4 : 0.25
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
            blockerNode.zPosition = 2
            addChild(blockerNode)
        }
    }

    func updateOre(tileType: TileType) {
        overlayNode?.removeFromParent()
        overlayNode = nil

        if tileType == .oreVein || tileType == .doubleOre {
            // Tint tile gold for ore
            if let sprite = backgroundNode as? SKSpriteNode {
                sprite.color = SKColor(hex: 0xDAA520)
                sprite.colorBlendFactor = tileType == .doubleOre ? 0.4 : 0.25
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
            ? SKColor(red: 0.85, green: 0.65, blue: 0.10, alpha: 0.50)
            : SKColor(red: 0.75, green: 0.55, blue: 0.10, alpha: 0.40)
        ore.strokeColor = SKColor(hex: 0xFFD700)
        ore.lineWidth = double ? 3.5 : 3.0
        ore.glowWidth = double ? 4.0 : 2.5
        container.addChild(ore)

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

        switch blocker {
        case .granite(let layers):
            let rect = CGSize(width: tileSize * 0.9, height: tileSize * 0.9)
            let stone = SKShapeNode(rectOf: rect, cornerRadius: 3)
            let alpha = 0.45 + Double(layers) * 0.18
            stone.fillColor = ColorPalette.granite.withAlphaComponent(alpha)
            stone.strokeColor = ColorPalette.graniteDark
            stone.lineWidth = CGFloat(layers) + 0.5
            container.addChild(stone)

            // Texture spots
            let spotData: [(CGPoint, CGFloat)] = [
                (CGPoint(x: -tileSize * 0.15, y: tileSize * 0.12), tileSize * 0.08),
                (CGPoint(x: tileSize * 0.18, y: -tileSize * 0.08), tileSize * 0.06),
                (CGPoint(x: -tileSize * 0.05, y: -tileSize * 0.18), tileSize * 0.07),
            ]
            for (pos, r) in spotData {
                let spot = SKShapeNode(circleOfRadius: r)
                spot.fillColor = ColorPalette.graniteDark.withAlphaComponent(0.3)
                spot.strokeColor = .clear
                spot.position = pos
                container.addChild(spot)
            }

            // Top highlight
            let highlight = SKShapeNode(rectOf: CGSize(width: rect.width * 0.7, height: rect.height * 0.15), cornerRadius: 2)
            highlight.fillColor = ColorPalette.graniteLight.withAlphaComponent(0.15)
            highlight.strokeColor = .clear
            highlight.position = CGPoint(x: -tileSize * 0.05, y: tileSize * 0.25)
            container.addChild(highlight)

            // Layer indicator dots
            let dotSpacing: CGFloat = 8
            let startX = -dotSpacing * CGFloat(layers - 1) / 2
            for i in 0..<layers {
                let dot = SKShapeNode(circleOfRadius: 3)
                dot.fillColor = .white
                dot.strokeColor = SKColor(white: 0.0, alpha: 0.3)
                dot.lineWidth = 0.5
                dot.position = CGPoint(x: startX + CGFloat(i) * dotSpacing, y: -tileSize * 0.34)
                container.addChild(dot)
            }

            // Crack lines for damaged granite
            if layers < 3 {
                let crack = SKShapeNode()
                let path = CGMutablePath()
                path.move(to: CGPoint(x: -tileSize * 0.22, y: tileSize * 0.22))
                path.addLine(to: CGPoint(x: -tileSize * 0.05, y: tileSize * 0.05))
                path.addLine(to: CGPoint(x: tileSize * 0.1, y: -tileSize * 0.1))
                if layers == 1 {
                    path.addLine(to: CGPoint(x: tileSize * 0.22, y: -tileSize * 0.28))
                }
                crack.path = path
                crack.strokeColor = SKColor(white: 0.85, alpha: 0.6)
                crack.lineWidth = 1.5
                container.addChild(crack)
            }

        case .boulder:
            let boulder = SKShapeNode(circleOfRadius: tileSize * 0.38)
            boulder.fillColor = SKColor(hex: 0x787878)
            boulder.strokeColor = SKColor(hex: 0x4A4A4A)
            boulder.lineWidth = 2.0
            container.addChild(boulder)

            let bottomBoulder = SKShapeNode(circleOfRadius: tileSize * 0.37)
            bottomBoulder.fillColor = SKColor(hex: 0x5A5A5A, alpha: 0.4)
            bottomBoulder.strokeColor = .clear
            let bMask = SKShapeNode(rectOf: CGSize(width: tileSize, height: tileSize / 2))
            bMask.fillColor = .white
            bMask.strokeColor = .clear
            bMask.position = CGPoint(x: 0, y: -tileSize * 0.2)
            let bCrop = SKCropNode()
            bCrop.maskNode = bMask
            bCrop.addChild(bottomBoulder)
            container.addChild(bCrop)

            let bHighlight = SKShapeNode(ellipseOf: CGSize(width: tileSize * 0.24, height: tileSize * 0.14))
            bHighlight.fillColor = SKColor(white: 1.0, alpha: 0.22)
            bHighlight.strokeColor = .clear
            bHighlight.position = CGPoint(x: -tileSize * 0.06, y: tileSize * 0.1)
            container.addChild(bHighlight)

        case .cage:
            let barColor = ColorPalette.cageMetallic
            let barHighlight = ColorPalette.cageRivet
            let barCount = 3
            let spacing = tileSize * 0.7 / CGFloat(barCount + 1)
            for i in 1...barCount {
                let xPos = -tileSize * 0.35 + spacing * CGFloat(i)
                let bar = SKShapeNode(rectOf: CGSize(width: 3, height: tileSize * 0.82), cornerRadius: 1)
                bar.fillColor = barColor
                bar.strokeColor = SKColor(white: 0.3, alpha: 0.4)
                bar.lineWidth = 0.5
                bar.position.x = xPos
                container.addChild(bar)
            }
            for dy: CGFloat in [-0.3, 0, 0.3] {
                let bar = SKShapeNode(rectOf: CGSize(width: tileSize * 0.82, height: 3), cornerRadius: 1)
                bar.fillColor = barColor
                bar.strokeColor = SKColor(white: 0.3, alpha: 0.4)
                bar.lineWidth = 0.5
                bar.position.y = dy * tileSize
                container.addChild(bar)
            }
            for i in 1...barCount {
                for dy: CGFloat in [-0.3, 0, 0.3] {
                    let rivet = SKShapeNode(circleOfRadius: 2.0)
                    rivet.fillColor = barHighlight.withAlphaComponent(0.5)
                    rivet.strokeColor = SKColor(white: 0.4, alpha: 0.3)
                    rivet.lineWidth = 0.5
                    rivet.position = CGPoint(x: -tileSize * 0.35 + spacing * CGFloat(i), y: dy * tileSize)
                    container.addChild(rivet)
                }
            }

        case .lava:
            let lava = SKShapeNode(rectOf: CGSize(width: tileSize * 0.9, height: tileSize * 0.9), cornerRadius: 4)
            lava.fillColor = ColorPalette.lava.withAlphaComponent(0.7)
            lava.strokeColor = ColorPalette.lavaGlow
            lava.lineWidth = 2
            lava.glowWidth = 5
            container.addChild(lava)

            let core = SKShapeNode(rectOf: CGSize(width: tileSize * 0.5, height: tileSize * 0.5), cornerRadius: 8)
            core.fillColor = ColorPalette.lavaYellow.withAlphaComponent(0.25)
            core.strokeColor = .clear
            container.addChild(core)

            // Animated lava bubbles
            for j in 0..<4 {
                let bubble = SKShapeNode(circleOfRadius: tileSize * CGFloat.random(in: 0.04...0.07))
                let bubbleColor = j % 2 == 0
                    ? SKColor(red: 1.0, green: 0.6, blue: 0.0, alpha: 0.8)
                    : SKColor(red: 1.0, green: 0.8, blue: 0.2, alpha: 0.7)
                bubble.fillColor = bubbleColor
                bubble.strokeColor = .clear
                bubble.glowWidth = 1.5
                let startX = CGFloat.random(in: -tileSize * 0.3...tileSize * 0.3)
                bubble.position = CGPoint(x: startX, y: -tileSize * 0.2)
                container.addChild(bubble)

                let rise = SKAction.sequence([
                    SKAction.group([
                        SKAction.moveBy(x: CGFloat.random(in: -8...8), y: tileSize * 0.4, duration: 0.9),
                        SKAction.fadeOut(withDuration: 0.9),
                        SKAction.scale(to: 1.5, duration: 0.9)
                    ]),
                    SKAction.run { [tileSize] in
                        bubble.position = CGPoint(x: CGFloat.random(in: -tileSize * 0.3...tileSize * 0.3), y: -tileSize * 0.2)
                        bubble.alpha = 0.8
                        bubble.setScale(1.0)
                    }
                ])
                bubble.run(SKAction.sequence([
                    SKAction.wait(forDuration: Double.random(in: 0...0.8)),
                    SKAction.repeatForever(rise)
                ]))
            }

            // Pulsing glow
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
            let barrelW = tileSize * 0.7
            let barrelH = tileSize * 0.75
            let tntBody = SKShapeNode(rectOf: CGSize(width: barrelW, height: barrelH), cornerRadius: barrelW * 0.3)
            tntBody.fillColor = ColorPalette.tnt
            tntBody.strokeColor = SKColor(hex: 0x8B0000)
            tntBody.lineWidth = 2.0
            tntBody.glowWidth = 3.0
            container.addChild(tntBody)

            // Bottom darkening for 3D
            let tntBottom = SKShapeNode(rectOf: CGSize(width: barrelW, height: barrelH * 0.5), cornerRadius: barrelW * 0.25)
            tntBottom.fillColor = SKColor(white: 0.0, alpha: 0.25)
            tntBottom.strokeColor = .clear
            tntBottom.position = CGPoint(x: 0, y: -barrelH * 0.25)
            container.addChild(tntBottom)

            // Metal bands
            for dy: CGFloat in [-0.22, 0.22] {
                let band = SKShapeNode(rectOf: CGSize(width: barrelW + 2, height: 3.5), cornerRadius: 1)
                band.fillColor = ColorPalette.tntBand
                band.strokeColor = SKColor(hex: 0x6B3410, alpha: 0.6)
                band.lineWidth = 0.5
                band.position.y = dy * barrelH
                container.addChild(band)
            }

            // "TNT" text
            let tntLabel = SKLabelNode(text: "TNT")
            tntLabel.fontName = "AvenirNext-Heavy"
            tntLabel.fontSize = tileSize * 0.18
            tntLabel.fontColor = .white
            tntLabel.verticalAlignmentMode = .center
            tntLabel.position = CGPoint(x: 0, y: barrelH * 0.05)
            container.addChild(tntLabel)

            // Glossy highlight
            let tntHighlight = SKShapeNode(ellipseOf: CGSize(width: barrelW * 0.5, height: barrelH * 0.2))
            tntHighlight.fillColor = SKColor(white: 1.0, alpha: 0.18)
            tntHighlight.strokeColor = .clear
            tntHighlight.position = CGPoint(x: -barrelW * 0.08, y: barrelH * 0.22)
            container.addChild(tntHighlight)

            // Countdown number (always shown on top)
            let label = SKLabelNode(text: "\(countdown)")
            label.fontName = "AvenirNext-Heavy"
            label.fontSize = tileSize * 0.34
            label.fontColor = .white
            label.verticalAlignmentMode = .center
            container.addChild(label)

            // Fuse spark
            let spark = SKShapeNode(circleOfRadius: 3.0)
            spark.fillColor = SKColor(hex: 0xFF6600)
            spark.strokeColor = .clear
            spark.glowWidth = 4.0
            spark.position = CGPoint(x: tileSize * 0.15, y: tileSize * 0.42)
            container.addChild(spark)

            let sparkPulse = SKAction.sequence([
                SKAction.fadeAlpha(to: 0.4, duration: 0.15),
                SKAction.fadeAlpha(to: 1.0, duration: 0.15)
            ])
            spark.run(SKAction.repeatForever(sparkPulse))

        case .amber:
            let amberRect = SKShapeNode(rectOf: CGSize(width: tileSize * 0.85, height: tileSize * 0.85), cornerRadius: 8)
            amberRect.fillColor = ColorPalette.amber.withAlphaComponent(0.35)
            amberRect.strokeColor = ColorPalette.amber.withAlphaComponent(0.7)
            amberRect.lineWidth = 2.0
            container.addChild(amberRect)

            let innerGlow = SKShapeNode(rectOf: CGSize(width: tileSize * 0.6, height: tileSize * 0.6), cornerRadius: 6)
            innerGlow.fillColor = ColorPalette.amberLight.withAlphaComponent(0.15)
            innerGlow.strokeColor = .clear
            container.addChild(innerGlow)

            let refraction = SKShapeNode(ellipseOf: CGSize(width: tileSize * 0.25, height: tileSize * 0.12))
            refraction.fillColor = SKColor(white: 1.0, alpha: 0.2)
            refraction.strokeColor = .clear
            refraction.position = CGPoint(x: -tileSize * 0.1, y: tileSize * 0.15)
            refraction.zRotation = -0.3
            container.addChild(refraction)
        }

        return container
    }
}
