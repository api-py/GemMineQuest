import SpriteKit

/// Renders beautiful faceted gem shapes programmatically.
class GemRenderer {

    /// Create a gem sprite node for a given color and size
    static func createGemNode(color: GemColor, size: CGFloat) -> SKNode {
        let container = SKNode()

        // Shadow
        let shadow = SKShapeNode(circleOfRadius: size * 0.42)
        shadow.fillColor = SKColor(white: 0.0, alpha: 0.3)
        shadow.strokeColor = .clear
        shadow.position = CGPoint(x: 2, y: -2)
        container.addChild(shadow)

        // Main gem body - octagonal faceted shape
        let gemPath = createGemPath(size: size)
        let body = SKShapeNode(path: gemPath)
        body.fillColor = color.primaryColor
        body.strokeColor = color.darkColor
        body.lineWidth = 1.0
        container.addChild(body)

        // Inner facet highlight
        let innerPath = createGemPath(size: size * 0.65)
        let inner = SKShapeNode(path: innerPath)
        inner.fillColor = color.lightColor.withAlphaComponent(0.4)
        inner.strokeColor = .clear
        inner.position = CGPoint(x: -size * 0.03, y: size * 0.05)
        container.addChild(inner)

        // Specular highlight (top-left shine)
        let shine = SKShapeNode(ellipseOf: CGSize(width: size * 0.35, height: size * 0.2))
        shine.fillColor = SKColor(white: 1.0, alpha: 0.55)
        shine.strokeColor = .clear
        shine.position = CGPoint(x: -size * 0.1, y: size * 0.15)
        shine.zRotation = -0.3
        container.addChild(shine)

        // Small sparkle dot
        let sparkle = SKShapeNode(circleOfRadius: size * 0.05)
        sparkle.fillColor = SKColor(white: 1.0, alpha: 0.8)
        sparkle.strokeColor = .clear
        sparkle.position = CGPoint(x: -size * 0.18, y: size * 0.22)
        container.addChild(sparkle)

        return container
    }

    /// Create laser gem overlay (horizontal or vertical line)
    static func createLaserOverlay(direction: SpecialType, size: CGFloat, color: GemColor) -> SKNode {
        let container = SKNode()

        let isHorizontal = direction == .laserHorizontal
        let lineWidth: CGFloat = size * 0.12
        let lineLength: CGFloat = size * 0.85

        // Laser line
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

        // Outer glow ring
        let ring = SKShapeNode(circleOfRadius: size * 0.48)
        ring.fillColor = .clear
        ring.strokeColor = color.lightColor.withAlphaComponent(0.8)
        ring.lineWidth = 2.5
        ring.glowWidth = 5.0
        container.addChild(ring)

        // Inner cross pattern
        for angle: CGFloat in [0, .pi / 4, .pi / 2, .pi * 3 / 4] {
            let dot = SKShapeNode(circleOfRadius: size * 0.06)
            dot.fillColor = SKColor.white.withAlphaComponent(0.8)
            dot.strokeColor = .clear
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

        // Shadow
        let shadow = SKShapeNode(circleOfRadius: size * 0.42)
        shadow.fillColor = SKColor(white: 0.0, alpha: 0.3)
        shadow.strokeColor = .clear
        shadow.position = CGPoint(x: 2, y: -2)
        container.addChild(shadow)

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
            let dot = SKShapeNode(circleOfRadius: size * 0.06)
            dot.fillColor = color.withAlphaComponent(0.8)
            dot.strokeColor = .clear
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

        // Rotating animation
        let rotate = SKAction.rotate(byAngle: .pi * 2, duration: 3.0)
        // Rotate just the inner dots
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

        // Propellers (4 dots at corners)
        for (dx, dy) in [(-1.0, 1.0), (1.0, 1.0), (-1.0, -1.0), (1.0, -1.0)] as [(CGFloat, CGFloat)] {
            let prop = SKShapeNode(circleOfRadius: size * 0.08)
            prop.fillColor = SKColor(hex: 0x90A4AE)
            prop.strokeColor = .clear
            prop.position = CGPoint(x: dx * bodySize * 0.5, y: dy * bodySize * 0.35)
            container.addChild(prop)

            // Spinning blur
            let blur = SKShapeNode(circleOfRadius: size * 0.12)
            blur.fillColor = SKColor(white: 0.7, alpha: 0.3)
            blur.strokeColor = .clear
            blur.position = prop.position
            container.addChild(blur)
        }

        // Eye/sensor light
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

    // MARK: - Gem Path

    private static func createGemPath(size: CGFloat) -> CGPath {
        let path = CGMutablePath()
        let sides = 8
        let radius = size * 0.42
        let angleOffset = CGFloat.pi / CGFloat(sides) // Rotate to have flat top

        for i in 0..<sides {
            let angle = CGFloat(i) / CGFloat(sides) * .pi * 2 + angleOffset
            let x = cos(angle) * radius
            let y = sin(angle) * radius

            if i == 0 {
                path.move(to: CGPoint(x: x, y: y))
            } else {
                path.addLine(to: CGPoint(x: x, y: y))
            }
        }
        path.closeSubpath()
        return path
    }
}
