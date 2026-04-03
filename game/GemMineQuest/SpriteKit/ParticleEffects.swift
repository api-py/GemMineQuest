import SpriteKit

enum ParticleEffects {

    /// Create a gem shatter particle burst
    static func gemShatter(at position: CGPoint, color: SKColor) -> SKNode {
        let container = SKNode()
        container.position = position
        container.zPosition = 50

        let particleCount = 12
        for _ in 0..<particleCount {
            let particle = SKShapeNode(circleOfRadius: CGFloat.random(in: 1.5...4.0))
            particle.fillColor = color
            particle.strokeColor = .clear
            particle.position = .zero

            let angle = CGFloat.random(in: 0...(.pi * 2))
            let speed = CGFloat.random(in: 40...100)
            let endPoint = CGPoint(x: cos(angle) * speed, y: sin(angle) * speed)
            let duration = TimeInterval.random(in: 0.3...0.6)

            let action = SKAction.sequence([
                SKAction.group([
                    SKAction.move(to: endPoint, duration: duration),
                    SKAction.fadeOut(withDuration: duration),
                    SKAction.scale(to: 0.1, duration: duration)
                ]),
                SKAction.removeFromParent()
            ])
            particle.run(action)
            container.addChild(particle)
        }

        // White flash
        let flash = SKShapeNode(circleOfRadius: 15)
        flash.fillColor = SKColor(white: 1.0, alpha: 0.6)
        flash.strokeColor = .clear
        flash.run(SKAction.sequence([
            SKAction.group([
                SKAction.scale(to: 2.0, duration: 0.15),
                SKAction.fadeOut(withDuration: 0.15)
            ]),
            SKAction.removeFromParent()
        ]))
        container.addChild(flash)

        container.run(SKAction.sequence([
            SKAction.wait(forDuration: 0.7),
            SKAction.removeFromParent()
        ]))

        return container
    }

    /// Laser beam effect along row or column
    static func laserBeam(from start: CGPoint, to end: CGPoint, color: SKColor) -> SKNode {
        let container = SKNode()
        container.zPosition = 45

        let dx = end.x - start.x
        let dy = end.y - start.y
        let length = sqrt(dx * dx + dy * dy)
        let angle = atan2(dy, dx)

        // Main beam
        let beam = SKShapeNode(rectOf: CGSize(width: length, height: 6), cornerRadius: 3)
        beam.fillColor = color.withAlphaComponent(0.8)
        beam.strokeColor = .white
        beam.lineWidth = 1
        beam.glowWidth = 8
        beam.position = CGPoint(x: (start.x + end.x) / 2, y: (start.y + end.y) / 2)
        beam.zRotation = angle
        container.addChild(beam)

        // Fade out
        container.run(SKAction.sequence([
            SKAction.wait(forDuration: 0.2),
            SKAction.fadeOut(withDuration: 0.2),
            SKAction.removeFromParent()
        ]))

        return container
    }

    /// Volatile explosion effect (3x3 area)
    static func volatileExplosion(at position: CGPoint) -> SKNode {
        let container = SKNode()
        container.position = position
        container.zPosition = 50

        // Expanding ring
        let ring = SKShapeNode(circleOfRadius: 5)
        ring.fillColor = .clear
        ring.strokeColor = SKColor(hex: 0xFF8C00)
        ring.lineWidth = 3
        ring.glowWidth = 5
        container.addChild(ring)

        ring.run(SKAction.sequence([
            SKAction.group([
                SKAction.scale(to: 8.0, duration: 0.35),
                SKAction.fadeOut(withDuration: 0.35)
            ]),
            SKAction.removeFromParent()
        ]))

        // Central flash
        let flash = SKShapeNode(circleOfRadius: 20)
        flash.fillColor = SKColor(white: 1.0, alpha: 0.8)
        flash.strokeColor = .clear
        container.addChild(flash)

        flash.run(SKAction.sequence([
            SKAction.group([
                SKAction.scale(to: 3.0, duration: 0.2),
                SKAction.fadeOut(withDuration: 0.2)
            ]),
            SKAction.removeFromParent()
        ]))

        // Debris particles
        for _ in 0..<16 {
            let debris = SKShapeNode(circleOfRadius: CGFloat.random(in: 2...5))
            debris.fillColor = [ColorPalette.mineBlastOrange, ColorPalette.sparkleGold, .white].randomElement()!
            debris.strokeColor = .clear

            let angle = CGFloat.random(in: 0...(.pi * 2))
            let dist = CGFloat.random(in: 50...120)
            let endPoint = CGPoint(x: cos(angle) * dist, y: sin(angle) * dist)

            debris.run(SKAction.sequence([
                SKAction.group([
                    SKAction.move(to: endPoint, duration: 0.4),
                    SKAction.fadeOut(withDuration: 0.4)
                ]),
                SKAction.removeFromParent()
            ]))
            container.addChild(debris)
        }

        container.run(SKAction.sequence([
            SKAction.wait(forDuration: 0.5),
            SKAction.removeFromParent()
        ]))

        return container
    }

    /// Crystal ball activation (rainbow wave)
    static func crystalBallWave(at position: CGPoint) -> SKNode {
        let container = SKNode()
        container.position = position
        container.zPosition = 50

        let colors: [SKColor] = [.red, .orange, .yellow, .green, .cyan, .blue, .purple]
        for (i, color) in colors.enumerated() {
            let ring = SKShapeNode(circleOfRadius: 3)
            ring.fillColor = .clear
            ring.strokeColor = color
            ring.lineWidth = 2
            ring.glowWidth = 3

            let delay = Double(i) * 0.05
            ring.run(SKAction.sequence([
                SKAction.wait(forDuration: delay),
                SKAction.group([
                    SKAction.scale(to: 15.0, duration: 0.6),
                    SKAction.fadeOut(withDuration: 0.6)
                ]),
                SKAction.removeFromParent()
            ]))
            container.addChild(ring)
        }

        container.run(SKAction.sequence([
            SKAction.wait(forDuration: 0.8),
            SKAction.removeFromParent()
        ]))

        return container
    }

    /// Mine Blast finale explosion
    static func mineBlastFinale(at position: CGPoint) -> SKNode {
        let container = SKNode()
        container.position = position
        container.zPosition = 60

        for _ in 0..<30 {
            let sparkle = SKShapeNode(circleOfRadius: CGFloat.random(in: 2...6))
            sparkle.fillColor = [ColorPalette.sparkleGold, ColorPalette.sparkleWhite, ColorPalette.mineBlastOrange].randomElement()!
            sparkle.strokeColor = .clear

            let angle = CGFloat.random(in: 0...(.pi * 2))
            let dist = CGFloat.random(in: 80...200)
            let endPoint = CGPoint(x: cos(angle) * dist, y: sin(angle) * dist)
            let duration = TimeInterval.random(in: 0.5...1.0)

            sparkle.run(SKAction.sequence([
                SKAction.group([
                    SKAction.move(to: endPoint, duration: duration),
                    SKAction.fadeOut(withDuration: duration),
                    SKAction.scale(to: 0.0, duration: duration)
                ]),
                SKAction.removeFromParent()
            ]))
            container.addChild(sparkle)
        }

        container.run(SKAction.sequence([
            SKAction.wait(forDuration: 1.2),
            SKAction.removeFromParent()
        ]))

        return container
    }
}
