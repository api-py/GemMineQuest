import SpriteKit

enum VisualEffects {

    /// Add a glowing border effect to a node
    static func addGlow(to node: SKShapeNode, color: SKColor, width: CGFloat = 5.0) {
        node.glowWidth = width
        node.strokeColor = color
    }

    /// Create a shimmer animation action
    static func shimmerAction(duration: TimeInterval = 1.5) -> SKAction {
        SKAction.repeatForever(SKAction.sequence([
            SKAction.fadeAlpha(to: 0.7, duration: duration / 2),
            SKAction.fadeAlpha(to: 1.0, duration: duration / 2)
        ]))
    }

    /// Create a pulse scale animation
    static func pulseAction(scale: CGFloat = 1.08, duration: TimeInterval = 0.8) -> SKAction {
        SKAction.repeatForever(SKAction.sequence([
            SKAction.scale(to: scale, duration: duration / 2),
            SKAction.scale(to: 1.0, duration: duration / 2)
        ]))
    }

    /// Create a floating score popup with shadow outline
    static func createScorePopup(text: String, at position: CGPoint, color: SKColor = ColorPalette.textGold) -> SKNode {
        let container = SKNode()
        container.position = position
        container.zPosition = 100

        // Shadow label (outline effect)
        let shadow = SKLabelNode(text: text)
        shadow.fontName = "AvenirNext-Heavy"
        shadow.fontSize = 20
        shadow.fontColor = SKColor(white: 0.0, alpha: 0.7)
        shadow.position = CGPoint(x: 1, y: -1)
        container.addChild(shadow)

        // Main label
        let label = SKLabelNode(text: text)
        label.fontName = "AvenirNext-Heavy"
        label.fontSize = 20
        label.fontColor = color
        container.addChild(label)

        let action = SKAction.sequence([
            SKAction.group([
                SKAction.moveBy(x: 0, y: 60, duration: 0.8),
                SKAction.sequence([
                    SKAction.group([
                        SKAction.fadeIn(withDuration: 0.1),
                        SKAction.springScale(to: 1.3, duration: 0.2)
                    ]),
                    SKAction.wait(forDuration: 0.3),
                    SKAction.fadeOut(withDuration: 0.3)
                ])
            ]),
            SKAction.removeFromParent()
        ])

        container.run(action)
        return container
    }

    /// Create a star burst effect at position using sparkle textures
    static func createStarBurst(at position: CGPoint, color: SKColor, count: Int = 10) -> SKNode {
        let container = SKNode()
        container.position = position

        for i in 0..<count {
            let angle = CGFloat(i) / CGFloat(count) * .pi * 2
            let size = CGFloat.random(in: 6...12)
            let particle = SKSpriteNode(texture: TextureFactory.shared.sparkleTexture(size: size))
            particle.size = CGSize(width: size, height: size)
            particle.color = color
            particle.colorBlendFactor = 1.0
            particle.blendMode = .add

            let distance: CGFloat = 70
            let endPoint = CGPoint(
                x: cos(angle) * distance,
                y: sin(angle) * distance
            )

            let action = SKAction.sequence([
                SKAction.group([
                    SKAction.move(to: endPoint, duration: 0.5),
                    SKAction.fadeOut(withDuration: 0.5),
                    SKAction.scale(to: 0.1, duration: 0.5),
                    SKAction.rotate(byAngle: CGFloat.random(in: -2...2), duration: 0.5)
                ]),
                SKAction.removeFromParent()
            ])

            particle.run(action)
            container.addChild(particle)
        }

        let cleanup = SKAction.sequence([
            SKAction.wait(forDuration: 0.6),
            SKAction.removeFromParent()
        ])
        container.run(cleanup)

        return container
    }
}
