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

    /// Create a floating score popup
    static func createScorePopup(text: String, at position: CGPoint, color: SKColor = ColorPalette.textGold) -> SKNode {
        let label = SKLabelNode(text: text)
        label.fontName = "AvenirNext-Bold"
        label.fontSize = 18
        label.fontColor = color
        label.position = position
        label.zPosition = 100

        let action = SKAction.sequence([
            SKAction.group([
                SKAction.moveBy(x: 0, y: 50, duration: 0.8),
                SKAction.sequence([
                    SKAction.fadeIn(withDuration: 0.1),
                    SKAction.wait(forDuration: 0.4),
                    SKAction.fadeOut(withDuration: 0.3)
                ]),
                SKAction.scale(to: 1.3, duration: 0.8)
            ]),
            SKAction.removeFromParent()
        ])

        label.run(action)
        return label
    }

    /// Create a star burst effect at position
    static func createStarBurst(at position: CGPoint, color: SKColor, count: Int = 8) -> SKNode {
        let container = SKNode()
        container.position = position

        for i in 0..<count {
            let angle = CGFloat(i) / CGFloat(count) * .pi * 2
            let particle = SKShapeNode(circleOfRadius: 3)
            particle.fillColor = color
            particle.strokeColor = .clear

            let distance: CGFloat = 60
            let endPoint = CGPoint(
                x: cos(angle) * distance,
                y: sin(angle) * distance
            )

            let action = SKAction.sequence([
                SKAction.group([
                    SKAction.move(to: endPoint, duration: 0.5),
                    SKAction.fadeOut(withDuration: 0.5),
                    SKAction.scale(to: 0.1, duration: 0.5)
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
