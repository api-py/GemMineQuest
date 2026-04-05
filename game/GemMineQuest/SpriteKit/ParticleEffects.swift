import SpriteKit

enum ParticleEffects {

    /// Create a gem shatter particle burst with gem-colored fragments.
    static func gemShatter(at position: CGPoint, color: SKColor) -> SKNode {
        let container = SKNode()
        container.position = position
        container.zPosition = 50

        let particleCount = 16
        for i in 0..<particleCount {
            let particleSize = CGFloat.random(in: 4.0...10.0)
            let glowTex = TextureFactory.shared.softGlowTexture(size: particleSize)
            let particle = SKSpriteNode(texture: glowTex, size: CGSize(width: particleSize, height: particleSize))
            particle.blendMode = .add
            particle.colorBlendFactor = 1.0

            // Vary between gem color, lighter, and white
            let colorVariant: SKColor = [color, color.withAlphaComponent(0.7), .white][i % 3]
            particle.color = colorVariant
            particle.position = .zero

            let angle = CGFloat.random(in: 0...(.pi * 2))
            let speed = CGFloat.random(in: 50...120)
            let endPoint = CGPoint(x: cos(angle) * speed, y: sin(angle) * speed)
            let duration = TimeInterval.random(in: 0.3...0.6)

            // Add rotation for fragments
            let spin = CGFloat.random(in: -4...4)

            let action = SKAction.sequence([
                SKAction.group([
                    SKAction.move(to: endPoint, duration: duration),
                    SKAction.fadeOut(withDuration: duration),
                    SKAction.scale(to: 0.1, duration: duration),
                    SKAction.rotate(byAngle: spin, duration: duration)
                ]),
                SKAction.removeFromParent()
            ])
            particle.run(action)
            container.addChild(particle)
        }

        // White flash (brighter, with glow texture)
        let flashTex = TextureFactory.shared.softGlowTexture(size: 24)
        let flash = SKSpriteNode(texture: flashTex, size: CGSize(width: 24, height: 24))
        flash.blendMode = .add
        flash.colorBlendFactor = 1.0
        flash.color = SKColor(white: 1.0, alpha: 1.0)
        flash.alpha = 0.7
        flash.run(SKAction.sequence([
            SKAction.group([
                SKAction.scale(to: 2.5, duration: 0.12),
                SKAction.fadeOut(withDuration: 0.15)
            ]),
            SKAction.removeFromParent()
        ]))
        container.addChild(flash)

        // Color flash
        let colorFlashTex = TextureFactory.shared.softGlowTexture(size: 36)
        let colorFlash = SKSpriteNode(texture: colorFlashTex, size: CGSize(width: 36, height: 36))
        colorFlash.blendMode = .add
        colorFlash.colorBlendFactor = 1.0
        colorFlash.color = color
        colorFlash.alpha = 0.4
        colorFlash.run(SKAction.sequence([
            SKAction.group([
                SKAction.scale(to: 2.0, duration: 0.18),
                SKAction.fadeOut(withDuration: 0.2)
            ]),
            SKAction.removeFromParent()
        ]))
        container.addChild(colorFlash)

        container.run(SKAction.sequence([
            SKAction.wait(forDuration: 0.7),
            SKAction.removeFromParent()
        ]))

        return container
    }

    /// Laser beam effect with double-line and sparkle trail.
    static func laserBeam(from start: CGPoint, to end: CGPoint, color: SKColor) -> SKNode {
        let container = SKNode()
        container.zPosition = 45

        let dx = end.x - start.x
        let dy = end.y - start.y
        let length = sqrt(dx * dx + dy * dy)
        let angle = atan2(dy, dx)
        let center = CGPoint(x: (start.x + end.x) / 2, y: (start.y + end.y) / 2)

        // Core beam (bright)
        let beam = SKShapeNode(rectOf: CGSize(width: length, height: 5), cornerRadius: 2.5)
        beam.fillColor = SKColor.white.withAlphaComponent(0.9)
        beam.strokeColor = .clear
        beam.glowWidth = 6
        beam.position = center
        beam.zRotation = angle
        container.addChild(beam)

        // Outer beam (colored glow)
        let outerBeam = SKShapeNode(rectOf: CGSize(width: length, height: 10), cornerRadius: 5)
        outerBeam.fillColor = color.withAlphaComponent(0.4)
        outerBeam.strokeColor = .clear
        outerBeam.glowWidth = 10
        outerBeam.position = center
        outerBeam.zRotation = angle
        container.addChild(outerBeam)

        // Sparkle trail along beam
        let numSparkles = Int(length / 20)
        for i in 0..<numSparkles {
            let t = CGFloat(i) / CGFloat(max(numSparkles - 1, 1))
            let sparkle = SKShapeNode(circleOfRadius: CGFloat.random(in: 1.0...2.5))
            sparkle.fillColor = SKColor.white.withAlphaComponent(0.7)
            sparkle.strokeColor = .clear
            sparkle.glowWidth = 2.0
            sparkle.position = CGPoint(
                x: start.x + dx * t,
                y: start.y + dy * t + CGFloat.random(in: -3...3)
            )

            let delay = Double(i) * 0.02
            sparkle.run(SKAction.sequence([
                SKAction.wait(forDuration: delay),
                SKAction.group([
                    SKAction.scale(to: 0.0, duration: 0.25),
                    SKAction.fadeOut(withDuration: 0.25)
                ]),
                SKAction.removeFromParent()
            ]))
            container.addChild(sparkle)
        }

        // Fade out
        container.run(SKAction.sequence([
            SKAction.wait(forDuration: 0.15),
            SKAction.fadeOut(withDuration: 0.2),
            SKAction.removeFromParent()
        ]))

        return container
    }

    /// Volatile explosion with shockwave ring and colored debris.
    static func volatileExplosion(at position: CGPoint) -> SKNode {
        let container = SKNode()
        container.position = position
        container.zPosition = 50

        // Primary shockwave ring
        let ring = SKShapeNode(circleOfRadius: 5)
        ring.fillColor = .clear
        ring.strokeColor = SKColor(hex: 0xFF8C00)
        ring.lineWidth = 3
        ring.glowWidth = 6
        container.addChild(ring)

        ring.run(SKAction.sequence([
            SKAction.group([
                SKAction.scale(to: 8.0, duration: 0.3),
                SKAction.fadeOut(withDuration: 0.35)
            ]),
            SKAction.removeFromParent()
        ]))

        // Secondary ring (slightly delayed)
        let ring2 = SKShapeNode(circleOfRadius: 5)
        ring2.fillColor = .clear
        ring2.strokeColor = SKColor(hex: 0xFFCC00)
        ring2.lineWidth = 2
        ring2.glowWidth = 4
        container.addChild(ring2)

        ring2.run(SKAction.sequence([
            SKAction.wait(forDuration: 0.08),
            SKAction.group([
                SKAction.scale(to: 6.0, duration: 0.3),
                SKAction.fadeOut(withDuration: 0.3)
            ]),
            SKAction.removeFromParent()
        ]))

        // Central flash
        let flash = SKShapeNode(circleOfRadius: 18)
        flash.fillColor = SKColor(white: 1.0, alpha: 0.85)
        flash.strokeColor = .clear
        flash.glowWidth = 10
        container.addChild(flash)

        flash.run(SKAction.sequence([
            SKAction.group([
                SKAction.scale(to: 3.5, duration: 0.18),
                SKAction.fadeOut(withDuration: 0.2)
            ]),
            SKAction.removeFromParent()
        ]))

        // Debris particles with gravity arc
        for _ in 0..<20 {
            let size = CGFloat.random(in: 2...5)
            let debris: SKShapeNode
            if Bool.random() {
                debris = SKShapeNode(circleOfRadius: size)
            } else {
                debris = SKShapeNode(rectOf: CGSize(width: size * 1.5, height: size), cornerRadius: 1)
            }
            debris.fillColor = [ColorPalette.mineBlastOrange, ColorPalette.sparkleGold, .white, SKColor(hex: 0xFF6600)].randomElement()!
            debris.strokeColor = .clear
            debris.glowWidth = 1.0

            let angle = CGFloat.random(in: 0...(.pi * 2))
            let dist = CGFloat.random(in: 50...130)
            let endX = cos(angle) * dist
            let endY = sin(angle) * dist - 20 // Gravity pull down

            debris.run(SKAction.sequence([
                SKAction.group([
                    SKAction.move(to: CGPoint(x: endX, y: endY), duration: 0.45),
                    SKAction.fadeOut(withDuration: 0.45),
                    SKAction.rotate(byAngle: CGFloat.random(in: -3...3), duration: 0.45)
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

    /// Crystal ball activation — rainbow wave with sparkle trail.
    static func crystalBallWave(at position: CGPoint) -> SKNode {
        let container = SKNode()
        container.position = position
        container.zPosition = 50

        let colors: [SKColor] = [.red, .orange, .yellow, .green, .cyan, .blue, .purple]
        for (i, color) in colors.enumerated() {
            let ring = SKShapeNode(circleOfRadius: 3)
            ring.fillColor = .clear
            ring.strokeColor = color
            ring.lineWidth = 2.5
            ring.glowWidth = 4

            let delay = Double(i) * 0.05
            ring.run(SKAction.sequence([
                SKAction.wait(forDuration: delay),
                SKAction.group([
                    SKAction.scale(to: 15.0, duration: 0.55),
                    SKAction.fadeOut(withDuration: 0.55)
                ]),
                SKAction.removeFromParent()
            ]))
            container.addChild(ring)

            // Sparkle dots on each ring
            for j in 0..<4 {
                let sparkle = SKShapeNode(circleOfRadius: 2)
                sparkle.fillColor = color.withAlphaComponent(0.8)
                sparkle.strokeColor = .clear
                sparkle.glowWidth = 2.0

                let sparkAngle = CGFloat(j) / 4.0 * .pi * 2 + CGFloat(i) * 0.3
                let sparkDist: CGFloat = 40
                let sparkEnd = CGPoint(x: cos(sparkAngle) * sparkDist, y: sin(sparkAngle) * sparkDist)

                sparkle.run(SKAction.sequence([
                    SKAction.wait(forDuration: delay + 0.1),
                    SKAction.group([
                        SKAction.move(to: sparkEnd, duration: 0.4),
                        SKAction.fadeOut(withDuration: 0.4),
                        SKAction.scale(to: 0.3, duration: 0.4)
                    ]),
                    SKAction.removeFromParent()
                ]))
                container.addChild(sparkle)
            }
        }

        // Central purple flash
        let flash = SKShapeNode(circleOfRadius: 10)
        flash.fillColor = SKColor(hex: 0x8B00FF, alpha: 0.6)
        flash.strokeColor = .clear
        flash.glowWidth = 8
        flash.run(SKAction.sequence([
            SKAction.group([
                SKAction.scale(to: 3.0, duration: 0.2),
                SKAction.fadeOut(withDuration: 0.25)
            ]),
            SKAction.removeFromParent()
        ]))
        container.addChild(flash)

        container.run(SKAction.sequence([
            SKAction.wait(forDuration: 0.8),
            SKAction.removeFromParent()
        ]))

        return container
    }

    /// Mine Blast finale explosion — larger, more dramatic.
    static func mineBlastFinale(at position: CGPoint) -> SKNode {
        let container = SKNode()
        container.position = position
        container.zPosition = 60

        // Central burst flash
        let burst = SKShapeNode(circleOfRadius: 15)
        burst.fillColor = ColorPalette.sparkleGold.withAlphaComponent(0.8)
        burst.strokeColor = .clear
        burst.glowWidth = 12
        burst.run(SKAction.sequence([
            SKAction.group([
                SKAction.scale(to: 4.0, duration: 0.3),
                SKAction.fadeOut(withDuration: 0.35)
            ]),
            SKAction.removeFromParent()
        ]))
        container.addChild(burst)

        for i in 0..<35 {
            let sparkle: SKShapeNode
            if i % 4 == 0 {
                // Star-shaped sparkle
                let s = CGFloat.random(in: 3...7)
                let path = CGMutablePath()
                path.move(to: CGPoint(x: 0, y: s))
                path.addLine(to: CGPoint(x: s * 0.3, y: s * 0.3))
                path.addLine(to: CGPoint(x: s, y: 0))
                path.addLine(to: CGPoint(x: s * 0.3, y: -s * 0.3))
                path.addLine(to: CGPoint(x: 0, y: -s))
                path.addLine(to: CGPoint(x: -s * 0.3, y: -s * 0.3))
                path.addLine(to: CGPoint(x: -s, y: 0))
                path.addLine(to: CGPoint(x: -s * 0.3, y: s * 0.3))
                path.closeSubpath()
                sparkle = SKShapeNode(path: path)
            } else {
                sparkle = SKShapeNode(circleOfRadius: CGFloat.random(in: 2...6))
            }

            sparkle.fillColor = [ColorPalette.sparkleGold, ColorPalette.sparkleWhite, ColorPalette.mineBlastOrange].randomElement()!
            sparkle.strokeColor = .clear
            sparkle.glowWidth = 1.5

            let angle = CGFloat.random(in: 0...(.pi * 2))
            let dist = CGFloat.random(in: 80...220)
            let endPoint = CGPoint(x: cos(angle) * dist, y: sin(angle) * dist - dist * 0.1)
            let duration = TimeInterval.random(in: 0.5...1.0)

            sparkle.run(SKAction.sequence([
                SKAction.group([
                    SKAction.move(to: endPoint, duration: duration),
                    SKAction.fadeOut(withDuration: duration),
                    SKAction.scale(to: 0.0, duration: duration),
                    SKAction.rotate(byAngle: CGFloat.random(in: -2...2), duration: duration)
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

    /// Dust puff effect for gem landing after fall.
    static func dustPuff(at position: CGPoint) -> SKNode {
        let container = SKNode()
        container.position = position
        container.zPosition = 8

        for _ in 0..<4 {
            let dust = SKShapeNode(circleOfRadius: CGFloat.random(in: 1.5...3.0))
            dust.fillColor = ColorPalette.dustBrown.withAlphaComponent(0.3)
            dust.strokeColor = .clear

            let dx = CGFloat.random(in: -10...10)
            dust.run(SKAction.sequence([
                SKAction.group([
                    SKAction.move(to: CGPoint(x: dx, y: CGFloat.random(in: 5...12)), duration: 0.3),
                    SKAction.fadeOut(withDuration: 0.3),
                    SKAction.scale(to: 1.5, duration: 0.3)
                ]),
                SKAction.removeFromParent()
            ]))
            container.addChild(dust)
        }

        container.run(SKAction.sequence([
            SKAction.wait(forDuration: 0.35),
            SKAction.removeFromParent()
        ]))

        return container
    }

    /// Combo text popup ("Great!", "Amazing!", etc.)
    static func comboText(_ text: String, at position: CGPoint, size: CGFloat = 22) -> SKNode {
        let label = SKLabelNode(text: text)
        label.fontName = "AvenirNext-Heavy"
        label.fontSize = size
        label.fontColor = ColorPalette.sparkleGold
        label.position = position
        label.zPosition = 70
        label.setScale(0.5)

        label.run(SKAction.sequence([
            SKAction.group([
                SKAction.scale(to: 1.2, duration: 0.15),
                SKAction.fadeIn(withDuration: 0.1)
            ]),
            SKAction.scale(to: 1.0, duration: 0.1),
            SKAction.wait(forDuration: 0.5),
            SKAction.group([
                SKAction.moveBy(x: 0, y: 40, duration: 0.4),
                SKAction.fadeOut(withDuration: 0.4)
            ]),
            SKAction.removeFromParent()
        ]))

        return label
    }
}
