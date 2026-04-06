import SpriteKit

/// Renders gems using CoreGraphics textures from TextureFactory.
/// Special overlays remain procedural (SKShapeNode) since they are lightweight.
class GemRenderer {

    // MARK: - Main Gem Rendering

    static func createGemNode(color: GemColor, size: CGFloat) -> SKNode {
        let container = SKNode()

        // Main gem body from TextureFactory
        let texture = TextureFactory.shared.gemTexture(for: color, size: size)
        let gemSprite = SKSpriteNode(texture: texture, size: CGSize(width: size, height: size))
        gemSprite.name = "gemBody"
        container.addChild(gemSprite)

        // Glow halo behind gem (additive blend)
        let glowTexture = TextureFactory.shared.softGlowTexture(size: size * 1.3)
        let glowSprite = SKSpriteNode(texture: glowTexture, size: CGSize(width: size * 1.3, height: size * 1.3))
        glowSprite.name = "glowHalo"
        glowSprite.color = color.lightColor
        glowSprite.colorBlendFactor = 0.7
        glowSprite.alpha = 0.18
        glowSprite.blendMode = .add
        glowSprite.zPosition = -1
        container.addChild(glowSprite)

        // Sparkle dot
        let sparkle = SKShapeNode(circleOfRadius: size * 0.04)
        sparkle.fillColor = SKColor(white: 1.0, alpha: 0.9)
        sparkle.strokeColor = .clear
        sparkle.glowWidth = 2.0
        sparkle.position = CGPoint(x: -size * 0.15, y: size * 0.18)
        sparkle.name = "sparkle"
        container.addChild(sparkle)

        // Idle animations
        addIdleAnimations(to: container, size: size)

        return container
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

        let lineWidth: CGFloat = size * 0.10
        let lineLength: CGFloat = size * 0.82

        // Color-matched glow line (behind main line)
        let glowLine = SKShapeNode(rectOf: CGSize(
            width: isHorizontal ? lineLength * 1.1 : lineWidth * 2.5,
            height: isHorizontal ? lineWidth * 2.5 : lineLength * 1.1
        ), cornerRadius: lineWidth)
        glowLine.fillColor = color.primaryColor.withAlphaComponent(0.3)
        glowLine.strokeColor = color.primaryColor.withAlphaComponent(0.2)
        glowLine.lineWidth = 0
        glowLine.glowWidth = 8.0
        glowLine.zPosition = -1
        container.addChild(glowLine)

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

        // Oscillate ±10 degrees (0.1745 radians)
        let oscillate = SKAction.sequence([
            SKAction.rotate(toAngle: 0.1745, duration: 0.8, shortestUnitArc: true),
            SKAction.rotate(toAngle: -0.1745, duration: 0.8, shortestUnitArc: true)
        ])
        container.run(SKAction.repeatForever(oscillate))

        // Keep subtle pulse on the line itself
        let pulse = SKAction.sequence([
            SKAction.fadeAlpha(to: 0.7, duration: 0.6),
            SKAction.fadeAlpha(to: 1.0, duration: 0.6)
        ])
        line.run(SKAction.repeatForever(pulse))
        return container
    }

    static func createVolatileOverlay(size: CGFloat, color: GemColor) -> SKNode {
        let container = SKNode()

        let ring1 = SKShapeNode(circleOfRadius: size * 0.48)
        ring1.fillColor = .clear
        ring1.strokeColor = color.primaryColor.withAlphaComponent(0.7)
        ring1.lineWidth = 2.0
        ring1.glowWidth = 5.0
        container.addChild(ring1)

        let pulse = SKAction.sequence([
            SKAction.group([SKAction.scale(to: 1.15, duration: 0.45), SKAction.fadeAlpha(to: 0.5, duration: 0.45)]),
            SKAction.group([SKAction.scale(to: 1.0, duration: 0.45), SKAction.fadeAlpha(to: 1.0, duration: 0.45)])
        ])
        ring1.run(SKAction.repeatForever(pulse))

        let ring2 = SKShapeNode(circleOfRadius: size * 0.35)
        ring2.fillColor = .clear
        ring2.strokeColor = SKColor(red: 0.8, green: 0.6, blue: 1.0, alpha: 0.5)
        ring2.lineWidth = 1.5
        ring2.glowWidth = 3.0
        container.addChild(ring2)

        // Inner ring pulses opposite to outer
        let pulse2 = SKAction.sequence([
            SKAction.group([SKAction.scale(to: 1.0, duration: 0.45), SKAction.fadeAlpha(to: 1.0, duration: 0.45)]),
            SKAction.group([SKAction.scale(to: 1.15, duration: 0.45), SKAction.fadeAlpha(to: 0.5, duration: 0.45)])
        ])
        ring2.run(SKAction.repeatForever(pulse2))
        return container
    }

    static func createCrystalBallNode(size: CGFloat) -> SKNode {
        let container = SKNode()
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
        let radius = size * 0.30

        // Shadow
        let shadow = SKShapeNode(circleOfRadius: radius * 1.1)
        shadow.fillColor = SKColor(white: 0.0, alpha: 0.35)
        shadow.strokeColor = .clear
        shadow.position = CGPoint(x: 1.5, y: -2.5)
        container.addChild(shadow)

        // Hexagonal body
        let hexPath = CGMutablePath()
        for i in 0..<6 {
            let angle = CGFloat(i) / 6.0 * .pi * 2 - .pi / 6
            let pt = CGPoint(x: cos(angle) * radius, y: sin(angle) * radius)
            if i == 0 { hexPath.move(to: pt) } else { hexPath.addLine(to: pt) }
        }
        hexPath.closeSubpath()
        let body = SKShapeNode(path: hexPath)
        body.fillColor = SKColor(hex: 0x4A5568)
        body.strokeColor = SKColor(hex: 0x2D3748)
        body.lineWidth = 1.5
        container.addChild(body)

        // Wing/arm lines extending horizontally
        for sign: CGFloat in [-1, 1] {
            let wing = SKShapeNode(rectOf: CGSize(width: size * 0.22, height: size * 0.04), cornerRadius: 1)
            wing.fillColor = SKColor(hex: 0x718096)
            wing.strokeColor = SKColor(hex: 0x4A5568)
            wing.lineWidth = 0.5
            wing.position = CGPoint(x: sign * (radius + size * 0.09), y: 0)
            container.addChild(wing)
        }

        // Glowing cyan eye in center
        let eye = SKShapeNode(circleOfRadius: size * 0.06)
        eye.fillColor = SKColor(red: 0.0, green: 0.9, blue: 0.95, alpha: 1.0)
        eye.strokeColor = .clear
        eye.glowWidth = 4.0
        container.addChild(eye)

        // Pulsing ring around eye
        let ring = SKShapeNode(circleOfRadius: size * 0.10)
        ring.fillColor = .clear
        ring.strokeColor = SKColor(red: 0.0, green: 0.9, blue: 0.95, alpha: 0.6)
        ring.lineWidth = 1.0
        ring.glowWidth = 2.0
        container.addChild(ring)
        let ringPulse = SKAction.sequence([
            SKAction.group([SKAction.scale(to: 1.3, duration: 0.6), SKAction.fadeAlpha(to: 0.3, duration: 0.6)]),
            SKAction.group([SKAction.scale(to: 1.0, duration: 0.6), SKAction.fadeAlpha(to: 1.0, duration: 0.6)])
        ])
        ring.run(SKAction.repeatForever(ringPulse))

        // Small antenna dot on top
        let antenna = SKShapeNode(circleOfRadius: size * 0.025)
        antenna.fillColor = SKColor(red: 0.0, green: 0.9, blue: 0.95, alpha: 0.8)
        antenna.strokeColor = .clear
        antenna.glowWidth = 1.5
        antenna.position = CGPoint(x: 0, y: radius + size * 0.06)
        container.addChild(antenna)

        // Hover animation
        let hover = SKAction.sequence([
            SKAction.moveBy(x: 0, y: 2, duration: 0.4),
            SKAction.moveBy(x: 0, y: -2, duration: 0.4)
        ])
        container.run(SKAction.repeatForever(hover))

        // Slight wobble rotation
        let wobble = SKAction.sequence([
            SKAction.rotate(toAngle: 0.06, duration: 0.7),
            SKAction.rotate(toAngle: -0.06, duration: 0.7)
        ])
        wobble.timingMode = .easeInEaseOut
        container.run(SKAction.repeatForever(wobble))

        return container
    }
}
