import SpriteKit

/// Renders gems using high-resolution image assets from Assets.xcassets.
/// Falls back to procedural rendering only if image assets are missing.
class GemRenderer {

    // MARK: - Texture Cache

    private static var textureCache: [String: SKTexture] = [:]

    private static func cachedTexture(named name: String) -> SKTexture? {
        if let cached = textureCache[name] {
            return cached
        }
        // Check if asset exists
        guard UIImage(named: name) != nil else { return nil }
        let texture = SKTexture(imageNamed: name)
        texture.filteringMode = .linear
        textureCache[name] = texture
        return texture
    }

    // MARK: - Asset Name Mapping

    private static func gemAssetName(for color: GemColor) -> String {
        switch color {
        case .ruby: return "gem_ruby"
        case .topaz: return "gem_topaz"
        case .citrine: return "gem_citrine"
        case .emerald: return "gem_emerald"
        case .sapphire: return "gem_sapphire"
        case .amethyst: return "gem_amethyst"
        }
    }

    // MARK: - Main Gem Rendering

    static func createGemNode(color: GemColor, size: CGFloat) -> SKNode {
        let container = SKNode()
        let assetName = gemAssetName(for: color)

        if let texture = cachedTexture(named: assetName) {
            // Use high-res image asset
            createImageGem(container: container, texture: texture, color: color, size: size)
        } else {
            // Fallback to procedural
            createProceduralGem(container: container, color: color, size: size)
        }

        // Idle animations
        addIdleAnimations(to: container, size: size)

        return container
    }

    // MARK: - Image-Based Gem (Primary Path)

    private static func createImageGem(container: SKNode, texture: SKTexture, color: GemColor, size: CGFloat) {
        // Drop shadow
        let shadowSprite = SKSpriteNode(texture: texture, size: CGSize(width: size * 0.95, height: size * 0.95))
        shadowSprite.color = .black
        shadowSprite.colorBlendFactor = 1.0
        shadowSprite.alpha = 0.35
        shadowSprite.position = CGPoint(x: 2, y: -3)
        container.addChild(shadowSprite)

        // Main gem sprite from Firefly asset
        let gemSprite = SKSpriteNode(texture: texture, size: CGSize(width: size, height: size))
        gemSprite.name = "gemBody"
        container.addChild(gemSprite)

        // Subtle glow halo behind gem (additive blend)
        let glowSprite = SKSpriteNode(texture: texture, size: CGSize(width: size * 1.25, height: size * 1.25))
        glowSprite.color = color.lightColor
        glowSprite.colorBlendFactor = 0.7
        glowSprite.alpha = 0.15
        glowSprite.blendMode = .add
        glowSprite.zPosition = -1
        container.addChild(glowSprite)

        // Specular sparkle dot (animated)
        let sparkle = SKShapeNode(circleOfRadius: size * 0.04)
        sparkle.fillColor = SKColor(white: 1.0, alpha: 0.9)
        sparkle.strokeColor = .clear
        sparkle.glowWidth = 2.0
        sparkle.position = CGPoint(x: -size * 0.15, y: size * 0.18)
        sparkle.name = "sparkle"
        container.addChild(sparkle)
    }

    // MARK: - Procedural Fallback

    private static func createProceduralGem(container: SKNode, color: GemColor, size: CGFloat) {
        let radius = size * 0.48

        // Shadow
        let shadowPath = gemPath(for: color, radius: radius * 1.06)
        let shadow = SKShapeNode(path: shadowPath)
        shadow.fillColor = SKColor(white: 0.0, alpha: 0.45)
        shadow.strokeColor = .clear
        shadow.position = CGPoint(x: 1.5, y: -2.5)
        container.addChild(shadow)

        // Dark outline
        let outlinePath = gemPath(for: color, radius: radius * 1.05)
        let outline = SKShapeNode(path: outlinePath)
        outline.fillColor = color.darkColor
        outline.strokeColor = SKColor(white: 0.05, alpha: 0.95)
        outline.lineWidth = 2.0
        container.addChild(outline)

        // Main body
        let bodyPath = gemPath(for: color, radius: radius)
        let body = SKShapeNode(path: bodyPath)
        body.fillColor = color.primaryColor
        body.strokeColor = color.darkColor
        body.lineWidth = 1.5
        container.addChild(body)

        // Bottom darkening
        let bottomGrad = SKShapeNode(path: bodyPath)
        bottomGrad.fillColor = color.darkColor.withAlphaComponent(0.55)
        bottomGrad.strokeColor = .clear
        let bottomMask = SKShapeNode(rectOf: CGSize(width: size, height: size / 2))
        bottomMask.fillColor = .white
        bottomMask.strokeColor = .clear
        bottomMask.position = CGPoint(x: 0, y: -size * 0.25)
        let cropNode = SKCropNode()
        cropNode.maskNode = bottomMask
        cropNode.addChild(bottomGrad)
        container.addChild(cropNode)

        // Inner highlight
        let innerPath = innerFacetPath(for: color, radius: radius)
        let inner = SKShapeNode(path: innerPath)
        inner.fillColor = color.lightColor.withAlphaComponent(0.50)
        inner.strokeColor = .clear
        inner.position = CGPoint(x: -size * 0.02, y: size * 0.04)
        container.addChild(inner)

        // Glass shine overlay
        let glassOverlay = SKShapeNode(path: bodyPath)
        glassOverlay.fillColor = SKColor(white: 1.0, alpha: 0.18)
        glassOverlay.strokeColor = .clear
        let topMask = SKShapeNode(rectOf: CGSize(width: size, height: size * 0.6))
        topMask.fillColor = .white
        topMask.strokeColor = .clear
        topMask.position = CGPoint(x: 0, y: size * 0.2)
        let glassCrop = SKCropNode()
        glassCrop.maskNode = topMask
        glassCrop.addChild(glassOverlay)
        container.addChild(glassCrop)

        // Specular highlight
        let shine = SKShapeNode(ellipseOf: CGSize(width: size * 0.45, height: size * 0.24))
        shine.fillColor = SKColor(white: 1.0, alpha: 0.70)
        shine.strokeColor = .clear
        shine.position = CGPoint(x: -size * 0.06, y: size * 0.16)
        shine.zRotation = -0.25
        container.addChild(shine)

        // Sparkle
        let sparkle = SKShapeNode(circleOfRadius: size * 0.04)
        sparkle.fillColor = SKColor(white: 1.0, alpha: 0.9)
        sparkle.strokeColor = .clear
        sparkle.glowWidth = 1.0
        sparkle.position = CGPoint(x: -size * 0.15, y: size * 0.20)
        sparkle.name = "sparkle"
        container.addChild(sparkle)
    }

    // MARK: - Idle Animations

    private static func addIdleAnimations(to container: SKNode, size: CGFloat) {
        // Gentle bob
        let bobDelay = Double.random(in: 0...2.0)
        let bobDuration = Double.random(in: 2.2...3.0)
        let bob = SKAction.sequence([
            SKAction.moveBy(x: 0, y: 1.5, duration: bobDuration / 2),
            SKAction.moveBy(x: 0, y: -1.5, duration: bobDuration / 2)
        ])
        bob.timingMode = .easeInEaseOut
        container.run(SKAction.sequence([
            SKAction.wait(forDuration: bobDelay),
            SKAction.repeatForever(bob)
        ]))

        // Sparkle twinkle
        if let sparkle = container.childNode(withName: "sparkle") {
            let twinkleDelay = Double.random(in: 3.0...8.0)
            let twinkle = SKAction.sequence([
                SKAction.wait(forDuration: twinkleDelay),
                SKAction.run {
                    sparkle.run(SKAction.sequence([
                        SKAction.scale(to: 2.0, duration: 0.12),
                        SKAction.scale(to: 1.0, duration: 0.2),
                    ]))
                }
            ])
            container.run(SKAction.repeatForever(twinkle))
        }
    }

    // MARK: - Special Gem Overlays

    static func createLaserOverlay(direction: SpecialType, size: CGFloat, color: GemColor) -> SKNode {
        let container = SKNode()
        let isHorizontal = direction == .laserHorizontal

        // Try image asset first
        let assetName = isHorizontal ? "special_laser_h" : "special_laser_v"
        if let texture = cachedTexture(named: assetName) {
            let sprite = SKSpriteNode(texture: texture, size: CGSize(width: size * 0.9, height: size * 0.9))
            sprite.alpha = 0.85
            sprite.blendMode = .add
            container.addChild(sprite)

            let pulse = SKAction.sequence([
                SKAction.fadeAlpha(to: 0.5, duration: 0.5),
                SKAction.fadeAlpha(to: 0.85, duration: 0.5)
            ])
            sprite.run(SKAction.repeatForever(pulse))
            return container
        }

        // Fallback: procedural laser
        let lineWidth: CGFloat = size * 0.10
        let lineLength: CGFloat = size * 0.82

        let line = SKShapeNode(rectOf: CGSize(
            width: isHorizontal ? lineLength : lineWidth,
            height: isHorizontal ? lineWidth : lineLength
        ), cornerRadius: lineWidth / 2)
        line.fillColor = SKColor.white.withAlphaComponent(0.85)
        line.strokeColor = color.lightColor.withAlphaComponent(0.7)
        line.lineWidth = 1.0
        line.glowWidth = 4.0
        container.addChild(line)

        for sign: CGFloat in [-1, 1] {
            let arrow = SKShapeNode(circleOfRadius: size * 0.055)
            arrow.fillColor = SKColor.white.withAlphaComponent(0.8)
            arrow.strokeColor = .clear
            arrow.glowWidth = 2.0
            arrow.position = isHorizontal
                ? CGPoint(x: sign * lineLength * 0.46, y: 0)
                : CGPoint(x: 0, y: sign * lineLength * 0.46)
            container.addChild(arrow)
        }

        let pulse = SKAction.sequence([
            SKAction.fadeAlpha(to: 0.6, duration: 0.5),
            SKAction.fadeAlpha(to: 1.0, duration: 0.5)
        ])
        line.run(SKAction.repeatForever(pulse))
        return container
    }

    static func createVolatileOverlay(size: CGFloat, color: GemColor) -> SKNode {
        let container = SKNode()

        // Try image asset first
        if let texture = cachedTexture(named: "special_volatile") {
            let sprite = SKSpriteNode(texture: texture, size: CGSize(width: size * 0.95, height: size * 0.95))
            sprite.alpha = 0.8
            sprite.blendMode = .add
            container.addChild(sprite)

            let pulse = SKAction.sequence([
                SKAction.group([SKAction.scale(to: 1.12, duration: 0.45), SKAction.fadeAlpha(to: 0.5, duration: 0.45)]),
                SKAction.group([SKAction.scale(to: 1.0, duration: 0.45), SKAction.fadeAlpha(to: 0.8, duration: 0.45)])
            ])
            sprite.run(SKAction.repeatForever(pulse))
            return container
        }

        // Fallback: procedural rings
        let ring1 = SKShapeNode(circleOfRadius: size * 0.48)
        ring1.fillColor = .clear
        ring1.strokeColor = color.lightColor.withAlphaComponent(0.7)
        ring1.lineWidth = 2.0
        ring1.glowWidth = 5.0
        container.addChild(ring1)

        let pulse = SKAction.sequence([
            SKAction.group([SKAction.scale(to: 1.15, duration: 0.45), SKAction.fadeAlpha(to: 0.5, duration: 0.45)]),
            SKAction.group([SKAction.scale(to: 1.0, duration: 0.45), SKAction.fadeAlpha(to: 1.0, duration: 0.45)])
        ])
        ring1.run(SKAction.repeatForever(pulse))
        return container
    }

    static func createCrystalBallNode(size: CGFloat) -> SKNode {
        let container = SKNode()

        // Try image asset
        if let texture = cachedTexture(named: "special_crystal_ball") {
            let shadow = SKSpriteNode(texture: texture, size: CGSize(width: size * 0.9, height: size * 0.9))
            shadow.color = .black
            shadow.colorBlendFactor = 1.0
            shadow.alpha = 0.3
            shadow.position = CGPoint(x: 2, y: -3)
            container.addChild(shadow)

            let sprite = SKSpriteNode(texture: texture, size: CGSize(width: size, height: size))
            container.addChild(sprite)

            // Glow
            let glow = SKSpriteNode(texture: texture, size: CGSize(width: size * 1.2, height: size * 1.2))
            glow.color = SKColor(hex: 0x8B00FF)
            glow.colorBlendFactor = 0.6
            glow.alpha = 0.2
            glow.blendMode = .add
            glow.zPosition = -1
            container.addChild(glow)

            let pulse = SKAction.sequence([
                SKAction.fadeAlpha(to: 0.35, duration: 0.8),
                SKAction.fadeAlpha(to: 0.2, duration: 0.8)
            ])
            glow.run(SKAction.repeatForever(pulse))
            return container
        }

        // Fallback: procedural crystal ball
        let radius = size * 0.42

        let shadow = SKShapeNode(circleOfRadius: radius * 1.05)
        shadow.fillColor = SKColor(white: 0.0, alpha: 0.4)
        shadow.strokeColor = .clear
        shadow.position = CGPoint(x: 1.5, y: -2.5)
        container.addChild(shadow)

        let orb = SKShapeNode(circleOfRadius: radius)
        orb.fillColor = SKColor(hex: 0x4A0080)
        orb.strokeColor = SKColor(hex: 0x8B00FF)
        orb.lineWidth = 1.5
        orb.glowWidth = 5.0
        container.addChild(orb)

        let colors: [SKColor] = [.red, .orange, .yellow, .green, .cyan, .blue, .purple]
        let orbitNode = SKNode()
        for (i, orbColor) in colors.enumerated() {
            let angle = CGFloat(i) / CGFloat(colors.count) * .pi * 2
            let dot = SKShapeNode(circleOfRadius: size * 0.055)
            dot.fillColor = orbColor.withAlphaComponent(0.75)
            dot.strokeColor = .clear
            dot.glowWidth = 2.0
            dot.position = CGPoint(x: cos(angle) * size * 0.22, y: sin(angle) * size * 0.22)
            orbitNode.addChild(dot)
        }
        container.addChild(orbitNode)
        orbitNode.run(SKAction.repeatForever(SKAction.rotate(byAngle: .pi * 2, duration: 3.0)))

        let shine = SKShapeNode(ellipseOf: CGSize(width: size * 0.28, height: size * 0.14))
        shine.fillColor = SKColor(white: 1.0, alpha: 0.5)
        shine.strokeColor = .clear
        shine.position = CGPoint(x: -size * 0.07, y: size * 0.16)
        container.addChild(shine)

        return container
    }

    static func createDroneNode(size: CGFloat) -> SKNode {
        let container = SKNode()

        // Try image asset
        if let texture = cachedTexture(named: "special_drone") {
            let shadow = SKSpriteNode(texture: texture, size: CGSize(width: size * 0.9, height: size * 0.9))
            shadow.color = .black
            shadow.colorBlendFactor = 1.0
            shadow.alpha = 0.3
            shadow.position = CGPoint(x: 2, y: -3)
            container.addChild(shadow)

            let sprite = SKSpriteNode(texture: texture, size: CGSize(width: size, height: size))
            container.addChild(sprite)

            // Hover animation
            let hover = SKAction.sequence([
                SKAction.moveBy(x: 0, y: 2, duration: 0.4),
                SKAction.moveBy(x: 0, y: -2, duration: 0.4)
            ])
            container.run(SKAction.repeatForever(hover))
            return container
        }

        // Fallback: procedural drone
        let radius = size * 0.40

        let shadow = SKShapeNode(circleOfRadius: radius * 1.05)
        shadow.fillColor = SKColor(white: 0.0, alpha: 0.35)
        shadow.strokeColor = .clear
        shadow.position = CGPoint(x: 1.5, y: -2.5)
        container.addChild(shadow)

        let orb = SKShapeNode(circleOfRadius: radius)
        orb.fillColor = SKColor(red: 0.0, green: 0.7, blue: 0.7, alpha: 1.0)
        orb.strokeColor = SKColor(red: 0.0, green: 0.9, blue: 0.9, alpha: 1.0)
        orb.lineWidth = 1.5
        orb.glowWidth = 3.0
        container.addChild(orb)

        let center = SKShapeNode(circleOfRadius: size * 0.05)
        center.fillColor = .white
        center.strokeColor = .clear
        center.glowWidth = 1.5
        container.addChild(center)

        let hover = SKAction.sequence([
            SKAction.moveBy(x: 0, y: 2, duration: 0.4),
            SKAction.moveBy(x: 0, y: -2, duration: 0.4)
        ])
        container.run(SKAction.repeatForever(hover))

        return container
    }

    // MARK: - Gem Shape Paths (for procedural fallback)

    private static func gemPath(for color: GemColor, radius: CGFloat) -> CGPath {
        let path = CGMutablePath()
        switch color {
        case .ruby:
            let s = radius * 0.95
            path.move(to: CGPoint(x: 0, y: s))
            path.addLine(to: CGPoint(x: s, y: 0))
            path.addLine(to: CGPoint(x: 0, y: -s))
            path.addLine(to: CGPoint(x: -s, y: 0))
            path.closeSubpath()
        case .topaz:
            let s = radius * 0.88, cr = radius * 0.28
            path.addRoundedRect(in: CGRect(x: -s, y: -s, width: s * 2, height: s * 2), cornerWidth: cr, cornerHeight: cr)
        case .citrine:
            for i in 0..<6 {
                let angle = CGFloat(i) / 6.0 * .pi * 2 - .pi / 2
                let pt = CGPoint(x: cos(angle) * radius, y: sin(angle) * radius)
                if i == 0 { path.move(to: pt) } else { path.addLine(to: pt) }
            }
            path.closeSubpath()
        case .emerald:
            path.addEllipse(in: CGRect(x: -radius, y: -radius, width: radius * 2, height: radius * 2))
        case .sapphire:
            let r = radius * 0.95
            for i in 0..<5 {
                let angle = CGFloat(i) / 5.0 * .pi * 2 - .pi / 2
                let pt = CGPoint(x: cos(angle) * r, y: sin(angle) * r)
                if i == 0 { path.move(to: pt) } else { path.addLine(to: pt) }
            }
            path.closeSubpath()
        case .amethyst:
            let top = radius * 0.90, bottom = radius * 0.85, wide = radius * 0.80
            path.move(to: CGPoint(x: 0, y: top))
            path.addCurve(to: CGPoint(x: wide, y: -bottom * 0.15), control1: CGPoint(x: wide * 0.5, y: top), control2: CGPoint(x: wide, y: top * 0.3))
            path.addCurve(to: CGPoint(x: 0, y: -bottom), control1: CGPoint(x: wide, y: -bottom * 0.6), control2: CGPoint(x: wide * 0.35, y: -bottom))
            path.addCurve(to: CGPoint(x: -wide, y: -bottom * 0.15), control1: CGPoint(x: -wide * 0.35, y: -bottom), control2: CGPoint(x: -wide, y: -bottom * 0.6))
            path.addCurve(to: CGPoint(x: 0, y: top), control1: CGPoint(x: -wide, y: top * 0.3), control2: CGPoint(x: -wide * 0.5, y: top))
            path.closeSubpath()
        }
        return path
    }

    private static func innerFacetPath(for color: GemColor, radius: CGFloat) -> CGPath {
        let scale: CGFloat = 0.62
        let r = radius * scale
        let path = CGMutablePath()
        switch color {
        case .ruby:
            let s = r * 0.95
            path.move(to: CGPoint(x: 0, y: s))
            path.addLine(to: CGPoint(x: s, y: 0))
            path.addLine(to: CGPoint(x: 0, y: -s))
            path.addLine(to: CGPoint(x: -s, y: 0))
            path.closeSubpath()
        case .topaz:
            let s = r * 0.88, cr = r * 0.2
            path.addRoundedRect(in: CGRect(x: -s, y: -s, width: s * 2, height: s * 2), cornerWidth: cr, cornerHeight: cr)
        case .citrine:
            for i in 0..<6 {
                let angle = CGFloat(i) / 6.0 * .pi * 2 - .pi / 2
                let pt = CGPoint(x: cos(angle) * r, y: sin(angle) * r)
                if i == 0 { path.move(to: pt) } else { path.addLine(to: pt) }
            }
            path.closeSubpath()
        case .emerald:
            path.addEllipse(in: CGRect(x: -r, y: -r, width: r * 2, height: r * 2))
        case .sapphire:
            for i in 0..<5 {
                let angle = CGFloat(i) / 5.0 * .pi * 2 - .pi / 2
                let pt = CGPoint(x: cos(angle) * r * 0.95, y: sin(angle) * r * 0.95)
                if i == 0 { path.move(to: pt) } else { path.addLine(to: pt) }
            }
            path.closeSubpath()
        case .amethyst:
            path.addEllipse(in: CGRect(x: -r * 0.8, y: -r * 0.8, width: r * 1.6, height: r * 1.7))
        }
        return path
    }
}
