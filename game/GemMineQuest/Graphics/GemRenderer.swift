import SpriteKit

/// Renders gem and special piece sprites using high-quality cached textures.
class GemRenderer {

    /// Create a gem sprite node for a given color and size
    static func createGemNode(color: GemColor, size: CGFloat) -> SKNode {
        let container = SKNode()

        // Glow halo (additive blended, slightly larger)
        let glowTex = TextureFactory.shared.softGlowTexture(size: size * 1.6)
        let glow = SKSpriteNode(texture: glowTex, size: CGSize(width: size * 1.6, height: size * 1.6))
        glow.color = color.primaryColor
        glow.colorBlendFactor = 0.8
        glow.alpha = 0.25
        glow.blendMode = .add
        container.addChild(glow)

        // Main gem body (texture-based)
        let gemTex = TextureFactory.shared.gemTexture(for: color, size: size)
        let gem = SKSpriteNode(texture: gemTex, size: CGSize(width: size, height: size))
        container.addChild(gem)

        return container
    }

    /// Create laser gem overlay (horizontal or vertical line)
    static func createLaserOverlay(direction: SpecialType, size: CGFloat, color: GemColor) -> SKNode {
        let container = SKNode()

        let isHorizontal = direction == .laserHorizontal
        let lineWidth: CGFloat = size * 0.12
        let lineLength: CGFloat = size * 0.85

        // Laser line glow (additive blend)
        let glowTex = TextureFactory.shared.softGlowTexture(size: 16)
        let glowLine = SKSpriteNode(texture: glowTex)
        glowLine.size = CGSize(
            width: isHorizontal ? lineLength * 1.2 : lineWidth * 4,
            height: isHorizontal ? lineWidth * 4 : lineLength * 1.2
        )
        glowLine.color = color.lightColor
        glowLine.colorBlendFactor = 1.0
        glowLine.alpha = 0.5
        glowLine.blendMode = .add
        container.addChild(glowLine)

        // Laser line core
        let line = SKShapeNode(rectOf: CGSize(
            width: isHorizontal ? lineLength : lineWidth,
            height: isHorizontal ? lineWidth : lineLength
        ), cornerRadius: lineWidth / 2)
        line.fillColor = SKColor.white.withAlphaComponent(0.9)
        line.strokeColor = color.lightColor.withAlphaComponent(0.8)
        line.lineWidth = 1.0
        line.glowWidth = 3.0
        container.addChild(line)

        // Arrow indicators at ends
        let arrowSize: CGFloat = size * 0.15
        for sign: CGFloat in [-1, 1] {
            let arrow = SKShapeNode(rectOf: CGSize(width: arrowSize, height: arrowSize), cornerRadius: 2)
            arrow.fillColor = SKColor.white.withAlphaComponent(0.7)
            arrow.strokeColor = .clear
            if isHorizontal {
                arrow.position = CGPoint(x: sign * lineLength * 0.45, y: 0)
            } else {
                arrow.position = CGPoint(x: 0, y: sign * lineLength * 0.45)
            }
            arrow.zRotation = .pi / 4
            container.addChild(arrow)
        }

        // Pulse animation
        let pulse = SKAction.sequence([
            SKAction.fadeAlpha(to: 0.6, duration: 0.5),
            SKAction.fadeAlpha(to: 1.0, duration: 0.5)
        ])
        container.run(SKAction.repeatForever(pulse))

        return container
    }

    /// Create volatile gem overlay (pulsing energy glow)
    static func createVolatileOverlay(size: CGFloat, color: GemColor) -> SKNode {
        let container = SKNode()

        // Outer glow ring (texture-based)
        let ringTex = TextureFactory.shared.softGlowTexture(size: size)
        let ring = SKSpriteNode(texture: ringTex, size: CGSize(width: size * 1.1, height: size * 1.1))
        ring.color = color.lightColor
        ring.colorBlendFactor = 1.0
        ring.alpha = 0.6
        ring.blendMode = .add
        container.addChild(ring)

        // Inner energy dots
        for angle: CGFloat in [0, .pi / 4, .pi / 2, .pi * 3 / 4] {
            let dotTex = TextureFactory.shared.softGlowTexture(size: size * 0.15)
            let dot = SKSpriteNode(texture: dotTex, size: CGSize(width: size * 0.15, height: size * 0.15))
            dot.color = .white
            dot.colorBlendFactor = 1.0
            dot.blendMode = .add
            dot.position = CGPoint(
                x: cos(angle) * size * 0.32,
                y: sin(angle) * size * 0.32
            )
            container.addChild(dot)
        }

        // Pulsing animation
        let pulse = SKAction.sequence([
            SKAction.group([
                SKAction.scale(to: 1.15, duration: 0.4),
                SKAction.fadeAlpha(to: 0.7, duration: 0.4)
            ]),
            SKAction.group([
                SKAction.scale(to: 1.0, duration: 0.4),
                SKAction.fadeAlpha(to: 1.0, duration: 0.4)
            ])
        ])
        container.run(SKAction.repeatForever(pulse))

        return container
    }

    /// Create crystal ball (rainbow swirling orb)
    static func createCrystalBallNode(size: CGFloat) -> SKNode {
        let container = SKNode()

        // Glow backdrop
        let glowTex = TextureFactory.shared.softGlowTexture(size: size * 1.6)
        let glow = SKSpriteNode(texture: glowTex, size: CGSize(width: size * 1.6, height: size * 1.6))
        glow.color = SKColor(hex: 0x8B00FF)
        glow.colorBlendFactor = 0.8
        glow.alpha = 0.35
        glow.blendMode = .add
        container.addChild(glow)

        // Main orb
        let orb = SKShapeNode(circleOfRadius: size * 0.42)
        orb.fillColor = SKColor(hex: 0x4A0080)
        orb.strokeColor = SKColor(hex: 0x8B00FF)
        orb.lineWidth = 1.5
        orb.glowWidth = 4.0
        container.addChild(orb)

        // Rainbow inner swirl dots
        let colors: [SKColor] = [.red, .orange, .yellow, .green, .cyan, .blue, .purple]
        for (i, color) in colors.enumerated() {
            let angle = CGFloat(i) / CGFloat(colors.count) * .pi * 2
            let dotTex = TextureFactory.shared.softGlowTexture(size: size * 0.15)
            let dot = SKSpriteNode(texture: dotTex, size: CGSize(width: size * 0.15, height: size * 0.15))
            dot.color = color
            dot.colorBlendFactor = 1.0
            dot.alpha = 0.85
            dot.blendMode = .add
            dot.position = CGPoint(
                x: cos(angle) * size * 0.22,
                y: sin(angle) * size * 0.22
            )
            container.addChild(dot)
        }

        // Specular highlight
        let shine = SKShapeNode(ellipseOf: CGSize(width: size * 0.3, height: size * 0.18))
        shine.fillColor = SKColor(white: 1.0, alpha: 0.45)
        shine.strokeColor = .clear
        shine.position = CGPoint(x: -size * 0.08, y: size * 0.15)
        container.addChild(shine)

        // Rotating animation for inner dots
        let rotate = SKAction.rotate(byAngle: .pi * 2, duration: 3.0)
        for (i, child) in container.children.enumerated() {
            if i >= 2 && i < 2 + colors.count {
                child.run(SKAction.repeatForever(rotate))
            }
        }

        return container
    }

    /// Create mining drone node
    static func createDroneNode(size: CGFloat) -> SKNode {
        let container = SKNode()

        // Body
        let bodySize = size * 0.5
        let body = SKShapeNode(rectOf: CGSize(width: bodySize, height: bodySize * 0.6), cornerRadius: 4)
        body.fillColor = SKColor(hex: 0x607D8B)
        body.strokeColor = SKColor(hex: 0x455A64)
        body.lineWidth = 1.0
        container.addChild(body)

        // Propellers with glow
        for (dx, dy) in [(-1.0, 1.0), (1.0, 1.0), (-1.0, -1.0), (1.0, -1.0)] as [(CGFloat, CGFloat)] {
            let prop = SKShapeNode(circleOfRadius: size * 0.08)
            prop.fillColor = SKColor(hex: 0x90A4AE)
            prop.strokeColor = .clear
            prop.position = CGPoint(x: dx * bodySize * 0.5, y: dy * bodySize * 0.35)
            container.addChild(prop)

            // Spinning blur glow
            let blurTex = TextureFactory.shared.softGlowTexture(size: size * 0.25)
            let blur = SKSpriteNode(texture: blurTex, size: CGSize(width: size * 0.25, height: size * 0.25))
            blur.color = SKColor(hex: 0x90A4AE)
            blur.colorBlendFactor = 0.8
            blur.alpha = 0.4
            blur.blendMode = .add
            blur.position = prop.position
            container.addChild(blur)
        }

        // Eye/sensor light with glow
        let eye = SKShapeNode(circleOfRadius: size * 0.06)
        eye.fillColor = SKColor(hex: 0x00E676)
        eye.strokeColor = .clear
        eye.glowWidth = 3.0
        container.addChild(eye)

        // Hover animation
        let hover = SKAction.sequence([
            SKAction.moveBy(x: 0, y: 2, duration: 0.4),
            SKAction.moveBy(x: 0, y: -2, duration: 0.4)
        ])
        container.run(SKAction.repeatForever(hover))

        return container
    }
}
