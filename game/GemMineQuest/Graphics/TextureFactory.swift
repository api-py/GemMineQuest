import SpriteKit
import UIKit

/// Generates and caches high-resolution textures using CoreGraphics.
/// Produces rich radial gradients, glossy highlights, and metallic sheens
/// at 3x Retina quality — replacing both flat SKShapeNode and low-quality Firefly PNGs.
class TextureFactory {
    static let shared = TextureFactory()

    private var gemTextureCache: [String: SKTexture] = [:]
    private var miscCache: [String: SKTexture] = [:]

    // MARK: - Gem Textures

    func gemTexture(for color: GemColor, size: CGFloat) -> SKTexture {
        let key = "\(color.rawValue)_\(Int(size))"
        if let cached = gemTextureCache[key] { return cached }

        let scale: CGFloat = 3.0
        let px = size * scale
        let renderer = UIGraphicsImageRenderer(size: CGSize(width: px, height: px))

        let image = renderer.image { ctx in
            let gc = ctx.cgContext
            let center = CGPoint(x: px / 2, y: px / 2)
            let radius = px * 0.42

            drawGemstone(gc: gc, center: center, radius: radius, px: px, color: color)
        }

        let texture = SKTexture(image: image)
        texture.filteringMode = .linear
        gemTextureCache[key] = texture
        return texture
    }

    // MARK: - Gemstone Rendering

    private func drawGemstone(gc: CGContext, center: CGPoint, radius: CGFloat, px: CGFloat, color: GemColor) {
        let primary = color.primaryColor
        let light = color.lightColor
        let dark = color.darkColor
        let colorSpace = CGColorSpaceCreateDeviceRGB()

        // 1) Drop shadow
        gc.saveGState()
        gc.setShadow(offset: CGSize(width: 4, height: 4), blur: 10,
                      color: UIColor(white: 0, alpha: 0.5).cgColor)
        let shapePath = gemShapePath(for: color, center: center, radius: radius)
        gc.addPath(shapePath)
        gc.setFillColor(primary.cgColor)
        gc.fillPath()
        gc.restoreGState()

        // 2) Main body with radial gradient
        gc.saveGState()
        gc.addPath(gemShapePath(for: color, center: center, radius: radius))
        gc.clip()

        let gradColors = [light.cgColor, primary.cgColor, dark.cgColor] as CFArray
        if let grad = CGGradient(colorsSpace: colorSpace, colors: gradColors, locations: [0.0, 0.45, 1.0]) {
            let gradCenter = CGPoint(x: center.x - radius * 0.15, y: center.y - radius * 0.15)
            gc.drawRadialGradient(grad,
                                  startCenter: gradCenter, startRadius: 0,
                                  endCenter: center, endRadius: radius * 1.1,
                                  options: [.drawsAfterEndLocation])
        }
        gc.restoreGState()

        // 3) Facet lines (subtle)
        gc.saveGState()
        gc.addPath(gemShapePath(for: color, center: center, radius: radius))
        gc.clip()
        gc.setStrokeColor(UIColor(white: 1.0, alpha: 0.1).cgColor)
        gc.setLineWidth(1.5)
        let facetCount = facetLineCount(for: color)
        for i in 0..<facetCount {
            let angle = CGFloat(i) / CGFloat(facetCount) * .pi * 2
            gc.move(to: center)
            gc.addLine(to: CGPoint(x: center.x + cos(angle) * radius,
                                    y: center.y + sin(angle) * radius))
        }
        gc.strokePath()
        gc.restoreGState()

        // 4) Dark outline
        gc.setStrokeColor(dark.cgColor)
        gc.setLineWidth(2.5)
        gc.addPath(gemShapePath(for: color, center: center, radius: radius))
        gc.strokePath()

        // 5) Bottom darkening (3D depth)
        gc.saveGState()
        gc.addPath(gemShapePath(for: color, center: center, radius: radius))
        gc.clip()
        let bottomRect = CGRect(x: 0, y: center.y, width: px, height: px / 2)
        gc.clip(to: [bottomRect])
        gc.setFillColor(UIColor(white: 0, alpha: 0.25).cgColor)
        gc.addPath(gemShapePath(for: color, center: center, radius: radius))
        gc.fillPath()
        gc.restoreGState()

        // 6) Glossy highlight arc (top 40%)
        gc.saveGState()
        let highlightEllipse = CGRect(
            x: center.x - radius * 0.7,
            y: center.y - radius * 1.0,
            width: radius * 1.4,
            height: radius * 0.95
        )
        gc.addEllipse(in: highlightEllipse)
        gc.clip()
        gc.addPath(gemShapePath(for: color, center: center, radius: radius))
        gc.clip()

        let hlColors = [
            UIColor(white: 1.0, alpha: 0.55).cgColor,
            UIColor(white: 1.0, alpha: 0.0).cgColor
        ] as CFArray
        if let hlGrad = CGGradient(colorsSpace: colorSpace, colors: hlColors, locations: [0.0, 1.0]) {
            gc.drawLinearGradient(hlGrad,
                                  start: CGPoint(x: center.x, y: center.y - radius),
                                  end: CGPoint(x: center.x, y: center.y + radius * 0.1),
                                  options: [])
        }
        gc.restoreGState()

        // 7) Specular highlight dot
        let specCenter = CGPoint(x: center.x - radius * 0.22, y: center.y - radius * 0.28)
        gc.saveGState()
        let specColors = [
            UIColor(white: 1.0, alpha: 0.9).cgColor,
            UIColor(white: 1.0, alpha: 0.0).cgColor
        ] as CFArray
        if let specGrad = CGGradient(colorsSpace: colorSpace, colors: specColors, locations: [0.0, 1.0]) {
            gc.drawRadialGradient(specGrad,
                                  startCenter: specCenter, startRadius: 0,
                                  endCenter: specCenter, endRadius: radius * 0.15,
                                  options: [])
        }
        gc.restoreGState()

        // 8) Secondary sparkle
        let spark2 = CGPoint(x: center.x - radius * 0.1, y: center.y - radius * 0.38)
        gc.saveGState()
        if let sparkGrad = CGGradient(colorsSpace: colorSpace, colors: specColors, locations: [0.0, 1.0]) {
            gc.drawRadialGradient(sparkGrad,
                                  startCenter: spark2, startRadius: 0,
                                  endCenter: spark2, endRadius: radius * 0.06,
                                  options: [])
        }
        gc.restoreGState()
    }

    // MARK: - Gem Shape Paths (per gem type, matching original shapes)

    private func gemShapePath(for color: GemColor, center: CGPoint, radius: CGFloat) -> CGPath {
        let path = CGMutablePath()
        switch color {
        case .ruby:
            // Diamond shape
            let s = radius * 0.95
            path.move(to: CGPoint(x: center.x, y: center.y - s))
            path.addLine(to: CGPoint(x: center.x + s, y: center.y))
            path.addLine(to: CGPoint(x: center.x, y: center.y + s))
            path.addLine(to: CGPoint(x: center.x - s, y: center.y))
            path.closeSubpath()
        case .gold:
            // Rounded square
            let s = radius * 0.88
            let cr = radius * 0.28
            path.addRoundedRect(in: CGRect(x: center.x - s, y: center.y - s, width: s * 2, height: s * 2),
                                cornerWidth: cr, cornerHeight: cr)
        case .silver:
            // Hexagon
            for i in 0..<6 {
                let angle = CGFloat(i) / 6.0 * .pi * 2 - .pi / 2
                let pt = CGPoint(x: center.x + cos(angle) * radius, y: center.y + sin(angle) * radius)
                if i == 0 { path.move(to: pt) } else { path.addLine(to: pt) }
            }
            path.closeSubpath()
        case .emerald:
            // Circle
            path.addEllipse(in: CGRect(x: center.x - radius, y: center.y - radius,
                                       width: radius * 2, height: radius * 2))
        case .sapphire:
            // Pentagon
            let r = radius * 0.95
            for i in 0..<5 {
                let angle = CGFloat(i) / 5.0 * .pi * 2 - .pi / 2
                let pt = CGPoint(x: center.x + cos(angle) * r, y: center.y + sin(angle) * r)
                if i == 0 { path.move(to: pt) } else { path.addLine(to: pt) }
            }
            path.closeSubpath()
        case .amethyst:
            // Teardrop
            let top = radius * 0.90, bottom = radius * 0.85, wide = radius * 0.80
            path.move(to: CGPoint(x: center.x, y: center.y - top))
            path.addCurve(to: CGPoint(x: center.x + wide, y: center.y + bottom * 0.15),
                          control1: CGPoint(x: center.x + wide * 0.5, y: center.y - top),
                          control2: CGPoint(x: center.x + wide, y: center.y - top * 0.3))
            path.addCurve(to: CGPoint(x: center.x, y: center.y + bottom),
                          control1: CGPoint(x: center.x + wide, y: center.y + bottom * 0.6),
                          control2: CGPoint(x: center.x + wide * 0.35, y: center.y + bottom))
            path.addCurve(to: CGPoint(x: center.x - wide, y: center.y + bottom * 0.15),
                          control1: CGPoint(x: center.x - wide * 0.35, y: center.y + bottom),
                          control2: CGPoint(x: center.x - wide, y: center.y + bottom * 0.6))
            path.addCurve(to: CGPoint(x: center.x, y: center.y - top),
                          control1: CGPoint(x: center.x - wide, y: center.y - top * 0.3),
                          control2: CGPoint(x: center.x - wide * 0.5, y: center.y - top))
            path.closeSubpath()
        }
        return path
    }

    private func facetLineCount(for color: GemColor) -> Int {
        switch color {
        case .ruby: return 4
        case .gold: return 4
        case .silver: return 6
        case .emerald: return 8
        case .sapphire: return 5
        case .amethyst: return 6
        }
    }

    // MARK: - Soft Glow Texture (particles + halos)

    func softGlowTexture(size: CGFloat) -> SKTexture {
        let key = "glow_\(Int(size))"
        if let cached = miscCache[key] { return cached }

        let px = size * 2
        let renderer = UIGraphicsImageRenderer(size: CGSize(width: px, height: px))
        let image = renderer.image { ctx in
            let gc = ctx.cgContext
            let center = CGPoint(x: px / 2, y: px / 2)
            let colorSpace = CGColorSpaceCreateDeviceRGB()
            let colors = [
                UIColor(white: 1.0, alpha: 1.0).cgColor,
                UIColor(white: 1.0, alpha: 0.3).cgColor,
                UIColor(white: 1.0, alpha: 0.0).cgColor
            ] as CFArray
            if let grad = CGGradient(colorsSpace: colorSpace, colors: colors, locations: [0.0, 0.4, 1.0]) {
                gc.drawRadialGradient(grad, startCenter: center, startRadius: 0,
                                      endCenter: center, endRadius: px / 2, options: [])
            }
        }
        let texture = SKTexture(image: image)
        texture.filteringMode = .linear
        miscCache[key] = texture
        return texture
    }

    func clearCaches() {
        gemTextureCache.removeAll()
        miscCache.removeAll()
    }
}
