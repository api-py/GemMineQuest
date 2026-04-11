import SpriteKit
import UIKit

/// Renders gems using PNG textures from Assets.xcassets.
/// Special overlays use PNG assets with lightweight SpriteKit animations.
class GemRenderer {

    /// Load a texture from the asset catalog, returns nil if not found.
    private static func loadTexture(named name: String) -> SKTexture? {
        guard let image = UIImage(named: name) else { return nil }
        let texture = SKTexture(image: image)
        texture.filteringMode = .linear
        return texture
    }

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

        // Gem-specific effects
        addGemEffects(to: container, color: color, size: size)

        return container
    }

    // MARK: - Gem-Specific Effects

    private static func addGemEffects(to container: SKNode, color: GemColor, size: CGFloat) {
        switch color {
        case .silver:
            // Random shine sweep — a bright highlight that flashes across the gem
            let shine = SKShapeNode(ellipseOf: CGSize(width: size * 0.3, height: size * 0.08))
            shine.fillColor = SKColor(white: 1.0, alpha: 0.7)
            shine.strokeColor = .clear
            shine.glowWidth = 4.0
            shine.alpha = 0.0
            shine.zPosition = 2
            shine.position = CGPoint(x: -size * 0.3, y: size * 0.1)
            container.addChild(shine)

            let shineSweep = SKAction.sequence([
                SKAction.wait(forDuration: Double.random(in: 3.0...7.0)),
                SKAction.fadeAlpha(to: 0.8, duration: 0.1),
                SKAction.move(to: CGPoint(x: size * 0.3, y: size * 0.1), duration: 0.3),
                SKAction.fadeAlpha(to: 0.0, duration: 0.1),
                SKAction.move(to: CGPoint(x: -size * 0.3, y: size * 0.1), duration: 0.0)
            ])
            shine.run(SKAction.repeatForever(shineSweep))

        case .gold, .emerald:
            // Random crystal glitter — small sparkle dots that flash at random positions
            for _ in 0..<3 {
                let glitter = SKShapeNode(circleOfRadius: size * 0.025)
                glitter.fillColor = color == .gold
                    ? SKColor(red: 1.0, green: 0.95, blue: 0.6, alpha: 1.0)
                    : SKColor(red: 0.6, green: 1.0, blue: 0.7, alpha: 1.0)
                glitter.strokeColor = .clear
                glitter.glowWidth = 2.5
                glitter.alpha = 0.0
                glitter.zPosition = 2
                let rx = CGFloat.random(in: -size * 0.25...size * 0.25)
                let ry = CGFloat.random(in: -size * 0.25...size * 0.25)
                glitter.position = CGPoint(x: rx, y: ry)
                container.addChild(glitter)

                let flash = SKAction.sequence([
                    SKAction.wait(forDuration: Double.random(in: 2.0...6.0)),
                    SKAction.fadeAlpha(to: 1.0, duration: 0.08),
                    SKAction.scale(to: 2.0, duration: 0.1),
                    SKAction.group([
                        SKAction.fadeAlpha(to: 0.0, duration: 0.2),
                        SKAction.scale(to: 1.0, duration: 0.2)
                    ]),
                    SKAction.run {
                        glitter.position = CGPoint(
                            x: CGFloat.random(in: -size * 0.25...size * 0.25),
                            y: CGFloat.random(in: -size * 0.25...size * 0.25)
                        )
                    }
                ])
                glitter.run(SKAction.repeatForever(flash))
            }

        default:
            break
        }
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
        let assetName = isHorizontal ? "special_laser_h" : "special_laser_v"

        if let texture = loadTexture(named: assetName) {
            let sprite = SKSpriteNode(texture: texture, size: CGSize(width: size, height: size))
            sprite.alpha = 0.85
            container.addChild(sprite)

            // Subtle pulse on the laser sprite
            let pulse = SKAction.sequence([
                SKAction.fadeAlpha(to: 0.7, duration: 0.6),
                SKAction.fadeAlpha(to: 1.0, duration: 0.6)
            ])
            sprite.run(SKAction.repeatForever(pulse))
        }

        // Oscillate ±10 degrees (0.1745 radians)
        let oscillate = SKAction.sequence([
            SKAction.rotate(toAngle: 0.1745, duration: 0.8, shortestUnitArc: true),
            SKAction.rotate(toAngle: -0.1745, duration: 0.8, shortestUnitArc: true)
        ])
        container.run(SKAction.repeatForever(oscillate))

        return container
    }

    static func createVolatileOverlay(size: CGFloat, color: GemColor) -> SKNode {
        let container = SKNode()

        if let texture = loadTexture(named: "special_volatile") {
            let sprite = SKSpriteNode(texture: texture, size: CGSize(width: size * 1.3, height: size * 1.3))
            sprite.color = color.primaryColor
            sprite.colorBlendFactor = 0.6
            container.addChild(sprite)
        }

        // Pulsing ring animation
        let pulse = SKAction.sequence([
            SKAction.group([SKAction.scale(to: 1.15, duration: 0.45), SKAction.fadeAlpha(to: 0.5, duration: 0.45)]),
            SKAction.group([SKAction.scale(to: 1.0, duration: 0.45), SKAction.fadeAlpha(to: 1.0, duration: 0.45)])
        ])
        container.run(SKAction.repeatForever(pulse))

        return container
    }

    static func createCrystalBallNode(size: CGFloat) -> SKNode {
        let container = SKNode()

        if let texture = loadTexture(named: "special_crystal_ball") {
            let sprite = SKSpriteNode(texture: texture, size: CGSize(width: size, height: size))
            sprite.name = "crystalBallBody"
            container.addChild(sprite)
        }

        // Slow random rotation
        let rotate = SKAction.repeatForever(SKAction.rotate(byAngle: .pi * 2, duration: 12.0))
        container.run(rotate)

        // Heartbeat glow — random interval pulse
        let heartbeat = SKAction.sequence([
            SKAction.wait(forDuration: Double.random(in: 2.0...5.0)),
            SKAction.scale(to: 1.08, duration: 0.15),
            SKAction.scale(to: 1.0, duration: 0.1),
            SKAction.scale(to: 1.05, duration: 0.12),
            SKAction.scale(to: 1.0, duration: 0.2)
        ])
        container.run(SKAction.repeatForever(heartbeat))

        // Glow halo behind with slow rotation
        let glow = TextureFactory.shared.softGlowTexture(size: size * 1.3)
        let glowSprite = SKSpriteNode(texture: glow, size: CGSize(width: size * 1.3, height: size * 1.3))
        glowSprite.alpha = 0.2
        glowSprite.blendMode = .add
        glowSprite.zPosition = -1
        container.addChild(glowSprite)

        // Random glow brightness pulse
        let glowPulse = SKAction.sequence([
            SKAction.wait(forDuration: Double.random(in: 1.5...4.0)),
            SKAction.fadeAlpha(to: 0.4, duration: 0.3),
            SKAction.fadeAlpha(to: 0.15, duration: 0.5)
        ])
        glowSprite.run(SKAction.repeatForever(glowPulse))

        return container
    }

    static func createDroneNode(size: CGFloat) -> SKNode {
        let container = SKNode()

        if let texture = loadTexture(named: "special_drone") {
            let sprite = SKSpriteNode(texture: texture, size: CGSize(width: size, height: size))
            container.addChild(sprite)
        }

        // Red blinking LED in center
        let led = SKShapeNode(circleOfRadius: size * 0.04)
        led.fillColor = SKColor(red: 1.0, green: 0.1, blue: 0.1, alpha: 1.0)
        led.strokeColor = .clear
        led.glowWidth = 3.0
        led.zPosition = 1
        container.addChild(led)

        let ledBlink = SKAction.sequence([
            SKAction.wait(forDuration: Double.random(in: 1.0...3.0)),
            SKAction.fadeAlpha(to: 1.0, duration: 0.05),
            SKAction.wait(forDuration: 0.15),
            SKAction.fadeAlpha(to: 0.0, duration: 0.1),
            SKAction.wait(forDuration: 0.2),
            SKAction.fadeAlpha(to: 1.0, duration: 0.05),
            SKAction.wait(forDuration: 0.1),
            SKAction.fadeAlpha(to: 0.0, duration: 0.15)
        ])
        led.run(SKAction.repeatForever(ledBlink))

        // Hover animation (±2pt Y bob)
        let hover = SKAction.sequence([
            SKAction.moveBy(x: 0, y: 2, duration: 0.4),
            SKAction.moveBy(x: 0, y: -2, duration: 0.4)
        ])
        container.run(SKAction.repeatForever(hover))

        // Slight wobble rotation (±0.06 radians)
        let wobble = SKAction.sequence([
            SKAction.rotate(toAngle: 0.06, duration: 0.7),
            SKAction.rotate(toAngle: -0.06, duration: 0.7)
        ])
        wobble.timingMode = .easeInEaseOut
        container.run(SKAction.repeatForever(wobble))

        return container
    }
}
