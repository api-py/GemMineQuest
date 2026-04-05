import SpriteKit

/// Renders richly detailed, faceted gem shapes with 3D lighting effects.
/// Uses resolution-independent procedural vector rendering for crisp quality at any size.
class GemRenderer {

    // MARK: - Gem Shape Paths

    private static func gemPath(for color: GemColor, radius: CGFloat) -> CGPath {
        let path = CGMutablePath()
        switch color {
        case .ruby:
            // Symmetrical diamond
            let s = radius * 0.95
            path.move(to: CGPoint(x: 0, y: s))
            path.addLine(to: CGPoint(x: s, y: 0))
            path.addLine(to: CGPoint(x: 0, y: -s))
            path.addLine(to: CGPoint(x: -s, y: 0))
            path.closeSubpath()
        case .topaz:
            // Symmetrical rounded square
            let s = radius * 0.88, cr = radius * 0.28
            path.addRoundedRect(in: CGRect(x: -s, y: -s, width: s * 2, height: s * 2), cornerWidth: cr, cornerHeight: cr)
        case .citrine:
            // Symmetrical hexagon
            for i in 0..<6 {
                let angle = CGFloat(i) / 6.0 * .pi * 2 - .pi / 2
                let pt = CGPoint(x: cos(angle) * radius, y: sin(angle) * radius)
                if i == 0 { path.move(to: pt) } else { path.addLine(to: pt) }
            }
            path.closeSubpath()
        case .emerald:
            // Symmetrical circle (was oval - looked skewed)
            path.addEllipse(in: CGRect(x: -radius, y: -radius, width: radius * 2, height: radius * 2))
        case .sapphire:
            // Symmetrical pentagon
            let r = radius * 0.95
            for i in 0..<5 {
                let angle = CGFloat(i) / 5.0 * .pi * 2 - .pi / 2
                let pt = CGPoint(x: cos(angle) * r, y: sin(angle) * r)
                if i == 0 { path.move(to: pt) } else { path.addLine(to: pt) }
            }
            path.closeSubpath()
        case .amethyst:
            // Symmetrical teardrop (more balanced)
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
        let path = CGMutablePath()
        let r = radius * scale
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

    // MARK: - Main Gem Rendering

    static func createGemNode(color: GemColor, size: CGFloat) -> SKNode {
        let container = SKNode()
        let radius = size * 0.48

        // Layer 1: Drop shadow
        let shadowPath = gemPath(for: color, radius: radius * 1.06)
        let shadow = SKShapeNode(path: shadowPath)
        shadow.fillColor = SKColor(white: 0.0, alpha: 0.45)
        shadow.strokeColor = .clear
        shadow.position = CGPoint(x: 1.5, y: -2.5)
        container.addChild(shadow)

        // Layer 2: Dark outline (thick, near-black)
        let outlinePath = gemPath(for: color, radius: radius * 1.05)
        let outline = SKShapeNode(path: outlinePath)
        outline.fillColor = color.darkColor
        outline.strokeColor = SKColor(white: 0.05, alpha: 0.95)
        outline.lineWidth = 2.0
        container.addChild(outline)

        // Layer 3: Main gem body
        let bodyPath = gemPath(for: color, radius: radius)
        let body = SKShapeNode(path: bodyPath)
        body.fillColor = color.primaryColor
        body.strokeColor = color.darkColor
        body.lineWidth = 1.5
        container.addChild(body)

        // Layer 4: Bottom gradient (stronger 3D rounding)
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

        // Layer 5: Inner glow / facet highlight
        let innerPath = innerFacetPath(for: color, radius: radius)
        let inner = SKShapeNode(path: innerPath)
        inner.fillColor = color.lightColor.withAlphaComponent(0.50)
        inner.strokeColor = .clear
        inner.position = CGPoint(x: -size * 0.02, y: size * 0.04)
        container.addChild(inner)

        // Layer 6: Glass overlay (candy/glass shine over top 60%)
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

        // Layer 7: Large specular highlight
        let shineW = size * 0.45
        let shineH = size * 0.24
        let shine = SKShapeNode(ellipseOf: CGSize(width: shineW, height: shineH))
        shine.fillColor = SKColor(white: 1.0, alpha: 0.70)
        shine.strokeColor = .clear
        shine.position = CGPoint(x: -size * 0.06, y: size * 0.16)
        shine.zRotation = -0.25
        container.addChild(shine)

        // Layer 8: Rim light (bright edge on right side)
        let rimPath = gemPath(for: color, radius: radius * 0.96)
        let rim = SKShapeNode(path: rimPath)
        rim.fillColor = .clear
        rim.strokeColor = color.lightColor.withAlphaComponent(0.55)
        rim.lineWidth = 1.8
        rim.position = CGPoint(x: size * 0.02, y: -size * 0.01)
        let rimMask = SKShapeNode(rectOf: CGSize(width: size * 0.35, height: size))
        rimMask.fillColor = .white
        rimMask.strokeColor = .clear
        rimMask.position = CGPoint(x: size * 0.25, y: 0)
        let rimCrop = SKCropNode()
        rimCrop.maskNode = rimMask
        rimCrop.addChild(rim)
        container.addChild(rimCrop)

        // Layer 9: Primary sparkle
        let sparkle = SKShapeNode(circleOfRadius: size * 0.04)
        sparkle.fillColor = SKColor(white: 1.0, alpha: 0.9)
        sparkle.strokeColor = .clear
        sparkle.glowWidth = 1.0
        sparkle.position = CGPoint(x: -size * 0.15, y: size * 0.20)
        sparkle.name = "sparkle"
        container.addChild(sparkle)

        // Layer 10: Secondary sparkle
        let sparkle2 = SKShapeNode(circleOfRadius: size * 0.025)
        sparkle2.fillColor = SKColor(white: 1.0, alpha: 0.7)
        sparkle2.strokeColor = .clear
        sparkle2.position = CGPoint(x: -size * 0.08, y: size * 0.22)
        container.addChild(sparkle2)

        // MARK: Idle Animations
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

        return container
    }

    // MARK: - Special Gem Overlays

    static func createLaserOverlay(direction: SpecialType, size: CGFloat, color: GemColor) -> SKNode {
        let container = SKNode()
        let isHorizontal = direction == .laserHorizontal
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

        let line2Width: CGFloat = size * 0.04
        let line2 = SKShapeNode(rectOf: CGSize(
            width: isHorizontal ? lineLength * 0.6 : line2Width,
            height: isHorizontal ? line2Width : lineLength * 0.6
        ), cornerRadius: line2Width / 2)
        line2.fillColor = color.lightColor.withAlphaComponent(0.5)
        line2.strokeColor = .clear
        let offset: CGFloat = lineWidth * 0.7
        line2.position = isHorizontal ? CGPoint(x: 0, y: offset) : CGPoint(x: offset, y: 0)
        container.addChild(line2)

        for sign: CGFloat in [-1, 1] {
            let arrow = SKShapeNode(circleOfRadius: size * 0.055)
            arrow.fillColor = SKColor.white.withAlphaComponent(0.8)
            arrow.strokeColor = color.lightColor.withAlphaComponent(0.4)
            arrow.lineWidth = 0.5
            arrow.glowWidth = 2.0
            arrow.position = isHorizontal
                ? CGPoint(x: sign * lineLength * 0.46, y: 0)
                : CGPoint(x: 0, y: sign * lineLength * 0.46)
            container.addChild(arrow)
        }

        let sweepDot = SKShapeNode(circleOfRadius: size * 0.04)
        sweepDot.fillColor = SKColor.white.withAlphaComponent(0.9)
        sweepDot.strokeColor = .clear
        sweepDot.glowWidth = 3.0
        container.addChild(sweepDot)

        let sweepDist = lineLength * 0.4
        let sweep = SKAction.sequence([
            SKAction.move(to: isHorizontal ? CGPoint(x: -sweepDist, y: 0) : CGPoint(x: 0, y: -sweepDist), duration: 0),
            SKAction.move(to: isHorizontal ? CGPoint(x: sweepDist, y: 0) : CGPoint(x: 0, y: sweepDist), duration: 0.8),
            SKAction.fadeOut(withDuration: 0.1),
            SKAction.wait(forDuration: 0.5),
            SKAction.fadeIn(withDuration: 0.05),
        ])
        sweep.timingMode = .easeInEaseOut
        sweepDot.run(SKAction.repeatForever(sweep))

        let sway = SKAction.sequence([
            SKAction.rotate(toAngle: .pi / 20, duration: 0.9, shortestUnitArc: true),
            SKAction.rotate(toAngle: -.pi / 20, duration: 0.9, shortestUnitArc: true),
            SKAction.rotate(toAngle: 0, duration: 0.5, shortestUnitArc: true),
            SKAction.wait(forDuration: 0.2),
        ])
        container.run(SKAction.repeatForever(sway))

        let pulse = SKAction.sequence([
            SKAction.fadeAlpha(to: 0.6, duration: 0.5),
            SKAction.fadeAlpha(to: 1.0, duration: 0.5)
        ])
        line.run(SKAction.repeatForever(pulse))
        return container
    }

    static func createVolatileOverlay(size: CGFloat, color: GemColor) -> SKNode {
        let container = SKNode()

        let ring1 = SKShapeNode(circleOfRadius: size * 0.48)
        ring1.fillColor = .clear
        ring1.strokeColor = color.lightColor.withAlphaComponent(0.7)
        ring1.lineWidth = 2.0
        ring1.glowWidth = 5.0
        container.addChild(ring1)

        let ring2 = SKShapeNode(circleOfRadius: size * 0.34)
        ring2.fillColor = .clear
        ring2.strokeColor = color.lightColor.withAlphaComponent(0.4)
        ring2.lineWidth = 1.5
        ring2.glowWidth = 3.0
        container.addChild(ring2)

        for i in 0..<8 {
            let angle = CGFloat(i) / 8.0 * .pi * 2
            let dot = SKShapeNode(circleOfRadius: size * 0.04)
            dot.fillColor = SKColor.white.withAlphaComponent(0.75)
            dot.strokeColor = .clear
            dot.glowWidth = 2.0
            let dist = size * 0.35
            dot.position = CGPoint(x: cos(angle) * dist, y: sin(angle) * dist)
            container.addChild(dot)

            let orbit = SKAction.sequence([
                SKAction.move(to: CGPoint(x: cos(angle + 0.3) * dist, y: sin(angle + 0.3) * dist), duration: 0.4),
                SKAction.move(to: CGPoint(x: cos(angle) * dist, y: sin(angle) * dist), duration: 0.4),
            ])
            dot.run(SKAction.repeatForever(orbit))
        }

        let pulse1 = SKAction.sequence([
            SKAction.group([SKAction.scale(to: 1.15, duration: 0.45), SKAction.fadeAlpha(to: 0.5, duration: 0.45)]),
            SKAction.group([SKAction.scale(to: 1.0, duration: 0.45), SKAction.fadeAlpha(to: 1.0, duration: 0.45)])
        ])
        ring1.run(SKAction.repeatForever(pulse1))

        let pulse2 = SKAction.sequence([
            SKAction.group([SKAction.scale(to: 1.0, duration: 0.45), SKAction.fadeAlpha(to: 1.0, duration: 0.45)]),
            SKAction.group([SKAction.scale(to: 1.12, duration: 0.45), SKAction.fadeAlpha(to: 0.5, duration: 0.45)])
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

        let baseRing = SKShapeNode(circleOfRadius: radius * 1.03)
        baseRing.fillColor = SKColor(hex: 0x2A0050)
        baseRing.strokeColor = .clear
        container.addChild(baseRing)

        let orb = SKShapeNode(circleOfRadius: radius)
        orb.fillColor = SKColor(hex: 0x4A0080)
        orb.strokeColor = SKColor(hex: 0x8B00FF)
        orb.lineWidth = 1.5
        orb.glowWidth = 5.0
        container.addChild(orb)

        let bottomDark = SKShapeNode(circleOfRadius: radius)
        bottomDark.fillColor = SKColor(white: 0.0, alpha: 0.3)
        bottomDark.strokeColor = .clear
        let orbBottomMask = SKShapeNode(rectOf: CGSize(width: size, height: size / 2))
        orbBottomMask.fillColor = .white
        orbBottomMask.strokeColor = .clear
        orbBottomMask.position = CGPoint(x: 0, y: -size * 0.25)
        let orbCrop = SKCropNode()
        orbCrop.maskNode = orbBottomMask
        orbCrop.addChild(bottomDark)
        container.addChild(orbCrop)

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

        let innerOrbit = SKNode()
        for (i, orbColor) in colors.enumerated() {
            let angle = CGFloat(i) / CGFloat(colors.count) * .pi * 2 + .pi / 7
            let dot = SKShapeNode(circleOfRadius: size * 0.035)
            dot.fillColor = orbColor.withAlphaComponent(0.4)
            dot.strokeColor = .clear
            dot.position = CGPoint(x: cos(angle) * size * 0.13, y: sin(angle) * size * 0.13)
            innerOrbit.addChild(dot)
        }
        container.addChild(innerOrbit)
        innerOrbit.run(SKAction.repeatForever(SKAction.rotate(byAngle: -.pi * 2, duration: 2.0)))

        let shine = SKShapeNode(ellipseOf: CGSize(width: size * 0.28, height: size * 0.14))
        shine.fillColor = SKColor(white: 1.0, alpha: 0.5)
        shine.strokeColor = .clear
        shine.position = CGPoint(x: -size * 0.07, y: size * 0.16)
        shine.zRotation = -0.2
        container.addChild(shine)

        let sparkle = SKShapeNode(circleOfRadius: size * 0.03)
        sparkle.fillColor = SKColor(white: 1.0, alpha: 0.8)
        sparkle.strokeColor = .clear
        sparkle.position = CGPoint(x: -size * 0.14, y: size * 0.2)
        container.addChild(sparkle)

        let orbPulse = SKAction.sequence([
            SKAction.run { orb.glowWidth = 7.0 },
            SKAction.wait(forDuration: 0.8),
            SKAction.run { orb.glowWidth = 5.0 },
            SKAction.wait(forDuration: 0.8),
        ])
        container.run(SKAction.repeatForever(orbPulse))
        return container
    }

    static func createDroneNode(size: CGFloat) -> SKNode {
        let container = SKNode()
        let radius = size * 0.40

        let shadow = SKShapeNode(circleOfRadius: radius * 1.05)
        shadow.fillColor = SKColor(white: 0.0, alpha: 0.35)
        shadow.strokeColor = .clear
        shadow.position = CGPoint(x: 1.5, y: -2.5)
        container.addChild(shadow)

        let base = SKShapeNode(circleOfRadius: radius * 1.03)
        base.fillColor = SKColor(red: 0.0, green: 0.3, blue: 0.3, alpha: 1.0)
        base.strokeColor = .clear
        container.addChild(base)

        let orb = SKShapeNode(circleOfRadius: radius)
        orb.fillColor = SKColor(red: 0.0, green: 0.7, blue: 0.7, alpha: 1.0)
        orb.strokeColor = SKColor(red: 0.0, green: 0.9, blue: 0.9, alpha: 1.0)
        orb.lineWidth = 1.5
        orb.glowWidth = 3.0
        container.addChild(orb)

        let bottomDark = SKShapeNode(circleOfRadius: radius)
        bottomDark.fillColor = SKColor(red: 0.0, green: 0.2, blue: 0.2, alpha: 0.4)
        bottomDark.strokeColor = .clear
        let droneMask = SKShapeNode(rectOf: CGSize(width: size, height: size / 2))
        droneMask.fillColor = .white
        droneMask.strokeColor = .clear
        droneMask.position = CGPoint(x: 0, y: -size * 0.25)
        let droneCrop = SKCropNode()
        droneCrop.maskNode = droneMask
        droneCrop.addChild(bottomDark)
        container.addChild(droneCrop)

        for angle: CGFloat in [0, .pi / 2, .pi, .pi * 1.5] {
            let line = SKShapeNode(rectOf: CGSize(width: 1.5, height: size * 0.22))
            line.fillColor = SKColor.white.withAlphaComponent(0.7)
            line.strokeColor = .clear
            line.position = CGPoint(x: cos(angle) * size * 0.12, y: sin(angle) * size * 0.12)
            line.zRotation = angle
            container.addChild(line)
        }

        let center = SKShapeNode(circleOfRadius: size * 0.05)
        center.fillColor = .white
        center.strokeColor = .clear
        center.glowWidth = 1.5
        container.addChild(center)

        let targetRing = SKShapeNode(circleOfRadius: radius * 0.75)
        targetRing.fillColor = .clear
        targetRing.strokeColor = SKColor.white.withAlphaComponent(0.25)
        targetRing.lineWidth = 0.8
        container.addChild(targetRing)

        let orbitNode = SKNode()
        for i in 0..<5 {
            let a = CGFloat(i) / 5.0 * .pi * 2
            let dot = SKShapeNode(circleOfRadius: size * 0.045)
            dot.fillColor = SKColor(red: 1.0, green: 1.0, blue: 0.3, alpha: 1.0)
            dot.strokeColor = .clear
            dot.glowWidth = 2.0
            dot.position = CGPoint(x: cos(a) * size * 0.28, y: sin(a) * size * 0.28)
            orbitNode.addChild(dot)
        }
        container.addChild(orbitNode)
        orbitNode.run(SKAction.repeatForever(SKAction.rotate(byAngle: .pi * 2, duration: 2.0)))

        let shine = SKShapeNode(ellipseOf: CGSize(width: size * 0.24, height: size * 0.13))
        shine.fillColor = SKColor(white: 1.0, alpha: 0.45)
        shine.strokeColor = .clear
        shine.position = CGPoint(x: -size * 0.07, y: size * 0.14)
        container.addChild(shine)

        return container
    }
}
