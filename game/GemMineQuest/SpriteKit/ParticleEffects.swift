import SpriteKit

enum ParticleEffects {

    /// Create a gem shatter particle burst
    static func gemShatter(at position: CGPoint, color: SKColor) -> SKNode {
        let container = SKNode()
        container.position = position
        container.zPosition = 50

        let particleCount = 20
        for _ in 0..<particleCount {
            let size = CGFloat.random(in: 4...10)
            let particle = SKSpriteNode(texture: TextureFactory.shared.softGlowTexture(size: size))
            particle.size = CGSize(width: size, height: size)
            particle.color = color
            particle.colorBlendFactor = 1.0
            particle.blendMode = .add
            particle.position = .zero
            particle.zRotation = CGFloat.random(in: 0...(.pi * 2))

            let angle = CGFloat.random(in: 0...(.pi * 2))
            let speed = CGFloat.random(in: 40...120)
            let endPoint = CGPoint(x: cos(angle) * speed, y: sin(angle) * speed)
            let duration = TimeInterval.random(in: 0.3...0.6)

            let action = SKAction.sequence([
                SKAction.group([
                    SKAction.move(to: endPoint, duration: duration),
                    SKAction.fadeOut(withDuration: duration),
                    SKAction.scale(to: 0.1, duration: duration),
                    SKAction.rotate(byAngle: CGFloat.random(in: -2...2), duration: duration)
                ]),
                SKAction.removeFromParent()
            ])
            particle.run(action)
            container.addChild(particle)
        }

        // White flash with glow texture
        let flashTex = TextureFactory.shared.softGlowTexture(size: 30)
        let flash = SKSpriteNode(texture: flashTex, size: CGSize(width: 40, height: 40))
        flash.blendMode = .add
        flash.run(SKAction.sequence([
            SKAction.group([
                SKAction.scale(to: 3.0, duration: 0.15),
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

        // Main beam with glow
        let beam = SKShapeNode(rectOf: CGSize(width: length, height: 6), cornerRadius: 3)
        beam.fillColor = color.withAlphaComponent(0.8)
        beam.strokeColor = .white
        beam.lineWidth = 1
        beam.glowWidth = 8
        beam.position = CGPoint(x: (start.x + end.x) / 2, y: (start.y + end.y) / 2)
        beam.zRotation = angle
        container.addChild(beam)

        // Additive glow overlay
        let glowTex = TextureFactory.shared.softGlowTexture(size: 16)
        let glow = SKSpriteNode(texture: glowTex)
        glow.size = CGSize(width: length * 1.05, height: 20)
        glow.color = color
        glow.colorBlendFactor = 1.0
        glow.alpha = 0.5
        glow.blendMode = .add
        glow.position = beam.position
        glow.zRotation = angle
        container.addChild(glow)

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

        // Expanding ring with glow
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

        // Central flash with glow texture
        let flashTex = TextureFactory.shared.softGlowTexture(size: 40)
        let flash = SKSpriteNode(texture: flashTex, size: CGSize(width: 50, height: 50))
        flash.blendMode = .add
        flash.alpha = 0.9
        container.addChild(flash)

        flash.run(SKAction.sequence([
            SKAction.group([
                SKAction.scale(to: 4.0, duration: 0.2),
                SKAction.fadeOut(withDuration: 0.2)
            ]),
            SKAction.removeFromParent()
        ]))

        // Debris particles with glow textures
        for _ in 0..<20 {
            let size = CGFloat.random(in: 6...14)
            let debris = SKSpriteNode(texture: TextureFactory.shared.softGlowTexture(size: size))
            debris.size = CGSize(width: size, height: size)
            debris.color = [ColorPalette.mineBlastOrange, ColorPalette.sparkleGold, .white].randomElement()!
            debris.colorBlendFactor = 1.0
            debris.blendMode = .add

            let angle = CGFloat.random(in: 0...(.pi * 2))
            let dist = CGFloat.random(in: 50...140)
            let endPoint = CGPoint(x: cos(angle) * dist, y: sin(angle) * dist)

            debris.run(SKAction.sequence([
                SKAction.group([
                    SKAction.move(to: endPoint, duration: 0.4),
                    SKAction.fadeOut(withDuration: 0.4),
                    SKAction.scale(to: 0.2, duration: 0.4)
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
            // Use sparkle texture for each ring
            let sparkle = SKSpriteNode(texture: TextureFactory.shared.softGlowTexture(size: 20))
            sparkle.size = CGSize(width: 20, height: 20)
            sparkle.color = color
            sparkle.colorBlendFactor = 1.0
            sparkle.alpha = 0.8
            sparkle.blendMode = .add

            let delay = Double(i) * 0.05
            sparkle.run(SKAction.sequence([
                SKAction.wait(forDuration: delay),
                SKAction.group([
                    SKAction.scale(to: 15.0, duration: 0.6),
                    SKAction.fadeOut(withDuration: 0.6)
                ]),
                SKAction.removeFromParent()
            ]))
            container.addChild(sparkle)
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

        for _ in 0..<50 {
            let useSparkle = Bool.random()
            let size = CGFloat.random(in: 4...14)
            let tex = useSparkle ? TextureFactory.shared.sparkleTexture(size: size) : TextureFactory.shared.softGlowTexture(size: size)
            let sparkle = SKSpriteNode(texture: tex)
            sparkle.size = CGSize(width: size, height: size)
            sparkle.color = [ColorPalette.sparkleGold, ColorPalette.sparkleWhite, ColorPalette.mineBlastOrange].randomElement()!
            sparkle.colorBlendFactor = 1.0
            sparkle.blendMode = .add
            sparkle.zRotation = CGFloat.random(in: 0...(.pi * 2))

            let angle = CGFloat.random(in: 0...(.pi * 2))
            let dist = CGFloat.random(in: 80...220)
            let endPoint = CGPoint(x: cos(angle) * dist, y: sin(angle) * dist)
            let duration = TimeInterval.random(in: 0.5...1.0)

            sparkle.run(SKAction.sequence([
                SKAction.group([
                    SKAction.move(to: endPoint, duration: duration),
                    SKAction.fadeOut(withDuration: duration),
                    SKAction.scale(to: 0.0, duration: duration),
                    SKAction.rotate(byAngle: CGFloat.random(in: -3...3), duration: duration)
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

    /// Screen shake effect for explosive moments
    static func screenShake(on node: SKNode, intensity: CGFloat = 4, duration: TimeInterval = 0.3) {
        let shakeCount = Int(duration / 0.03)
        var actions: [SKAction] = []
        for _ in 0..<shakeCount {
            let dx = CGFloat.random(in: -intensity...intensity)
            let dy = CGFloat.random(in: -intensity...intensity)
            actions.append(SKAction.moveBy(x: dx, y: dy, duration: 0.03))
        }
        actions.append(SKAction.move(to: .zero, duration: 0.05))
        node.run(SKAction.sequence(actions))
    }
}
