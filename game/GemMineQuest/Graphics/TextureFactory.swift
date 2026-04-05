import SpriteKit
import UIKit

/// Generates and caches high-resolution textures using CoreGraphics at 3x Retina.
/// All gems use smooth, symmetrical shapes with rich radial gradients and glass-like highlights.
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
        gc.setShadow(offset: CGSize(width: 3, height: 5), blur: 12,
                      color: UIColor(white: 0, alpha: 0.55).cgColor)
        let shapePath = gemShapePath(for: color, center: center, radius: radius)
        gc.addPath(shapePath)
        gc.setFillColor(dark.cgColor)
        gc.fillPath()
        gc.restoreGState()

        // 2) Main body with radial gradient (rich 3-stop: light → primary → dark)
        gc.saveGState()
        gc.addPath(gemShapePath(for: color, center: center, radius: radius))
        gc.clip()

        let gradColors = [light.cgColor, primary.cgColor, dark.cgColor] as CFArray
        if let grad = CGGradient(colorsSpace: colorSpace, colors: gradColors, locations: [0.0, 0.4, 1.0]) {
            // Light source from top-left — offset gradient center slightly
            let gradCenter = CGPoint(x: center.x - radius * 0.12, y: center.y - radius * 0.12)
            gc.drawRadialGradient(grad,
                                  startCenter: gradCenter, startRadius: 0,
                                  endCenter: center, endRadius: radius * 1.05,
                                  options: [.drawsAfterEndLocation])
        }
        gc.restoreGState()

        // 3) Dark outline stroke
        gc.setStrokeColor(dark.withAlphaComponent(0.9).cgColor)
        gc.setLineWidth(2.0)
        gc.addPath(gemShapePath(for: color, center: center, radius: radius))
        gc.strokePath()

        // 4) Bottom half darkening for 3D roundness
        gc.saveGState()
        gc.addPath(gemShapePath(for: color, center: center, radius: radius))
        gc.clip()
        let bottomRect = CGRect(x: 0, y: center.y - radius * 0.1, width: px, height: px)
        gc.clip(to: [bottomRect])
        gc.setFillColor(UIColor(white: 0, alpha: 0.2).cgColor)
        gc.addPath(gemShapePath(for: color, center: center, radius: radius))
        gc.fillPath()
        gc.restoreGState()

        // 5) Large glossy highlight (top portion — glass-like shine)
        gc.saveGState()
        // Clip to gem shape first
        gc.addPath(gemShapePath(for: color, center: center, radius: radius))
        gc.clip()
        // Then clip to an ellipse in the upper part
        let shineEllipse = CGRect(
            x: center.x - radius * 0.75,
            y: center.y - radius * 1.1,
            width: radius * 1.5,
            height: radius * 1.1
        )
        gc.addEllipse(in: shineEllipse)
        gc.clip()

        let shineColors = [
            UIColor(white: 1.0, alpha: 0.6).cgColor,
            UIColor(white: 1.0, alpha: 0.15).cgColor,
            UIColor(white: 1.0, alpha: 0.0).cgColor
        ] as CFArray
        if let shineGrad = CGGradient(colorsSpace: colorSpace, colors: shineColors, locations: [0.0, 0.5, 1.0]) {
            gc.drawLinearGradient(shineGrad,
                                  start: CGPoint(x: center.x, y: center.y - radius * 1.0),
                                  end: CGPoint(x: center.x, y: center.y + radius * 0.15),
                                  options: [])
        }
        gc.restoreGState()

        // 6) Specular highlight (bright white dot, top-left)
        let specPos = CGPoint(x: center.x - radius * 0.2, y: center.y - radius * 0.3)
        gc.saveGState()
        let specColors = [
            UIColor(white: 1.0, alpha: 0.95).cgColor,
            UIColor(white: 1.0, alpha: 0.0).cgColor
        ] as CFArray
        if let specGrad = CGGradient(colorsSpace: colorSpace, colors: specColors, locations: [0.0, 1.0]) {
            gc.drawRadialGradient(specGrad,
                                  startCenter: specPos, startRadius: 0,
                                  endCenter: specPos, endRadius: radius * 0.18,
                                  options: [])
        }
        gc.restoreGState()

        // 7) Tiny secondary sparkle
        let spark2Pos = CGPoint(x: center.x - radius * 0.05, y: center.y - radius * 0.42)
        gc.saveGState()
        if let sparkGrad = CGGradient(colorsSpace: colorSpace, colors: specColors, locations: [0.0, 1.0]) {
            gc.drawRadialGradient(sparkGrad,
                                  startCenter: spark2Pos, startRadius: 0,
                                  endCenter: spark2Pos, endRadius: radius * 0.07,
                                  options: [])
        }
        gc.restoreGState()

        // 8) Rim light (subtle bright edge on right side for depth)
        gc.saveGState()
        gc.addPath(gemShapePath(for: color, center: center, radius: radius))
        gc.clip()
        let rimRect = CGRect(x: center.x + radius * 0.5, y: center.y - radius * 0.6,
                             width: radius * 0.6, height: radius * 1.2)
        gc.clip(to: [rimRect])
        gc.setStrokeColor(light.withAlphaComponent(0.4).cgColor)
        gc.setLineWidth(3.0)
        gc.addPath(gemShapePath(for: color, center: center, radius: radius))
        gc.strokePath()
        gc.restoreGState()
    }

    // MARK: - Gem Shape Paths
    // All shapes are smooth and symmetrical — no awkward polygons

    private func gemShapePath(for color: GemColor, center: CGPoint, radius: CGFloat) -> CGPath {
        let path = CGMutablePath()
        switch color {
        case .ruby:
            // Rounded diamond (4 points with curved edges)
            let s = radius * 0.92
            let curve = s * 0.35
            path.move(to: CGPoint(x: center.x, y: center.y - s))
            path.addQuadCurve(to: CGPoint(x: center.x + s, y: center.y),
                              control: CGPoint(x: center.x + curve, y: center.y - curve))
            path.addQuadCurve(to: CGPoint(x: center.x, y: center.y + s),
                              control: CGPoint(x: center.x + curve, y: center.y + curve))
            path.addQuadCurve(to: CGPoint(x: center.x - s, y: center.y),
                              control: CGPoint(x: center.x - curve, y: center.y + curve))
            path.addQuadCurve(to: CGPoint(x: center.x, y: center.y - s),
                              control: CGPoint(x: center.x - curve, y: center.y - curve))
            path.closeSubpath()

        case .gold:
            // Rounded square (like a cushion-cut gem)
            let s = radius * 0.82
            let cr = radius * 0.35
            path.addRoundedRect(in: CGRect(x: center.x - s, y: center.y - s, width: s * 2, height: s * 2),
                                cornerWidth: cr, cornerHeight: cr)

        case .silver:
            // Circle (clean, simple, distinctive as the metal type)
            path.addEllipse(in: CGRect(x: center.x - radius * 0.9, y: center.y - radius * 0.9,
                                       width: radius * 1.8, height: radius * 1.8))

        case .emerald:
            // Oval (wider than tall — classic emerald cut look)
            let w = radius * 0.95
            let h = radius * 0.78
            path.addEllipse(in: CGRect(x: center.x - w, y: center.y - h,
                                       width: w * 2, height: h * 2))

        case .sapphire:
            // Rounded octagon (8 sides with smooth corners)
            let r = radius * 0.9
            let cut = r * 0.38  // How much to cut corners
            // Start from top
            path.move(to: CGPoint(x: center.x - cut, y: center.y - r))
            path.addLine(to: CGPoint(x: center.x + cut, y: center.y - r))
            path.addQuadCurve(to: CGPoint(x: center.x + r, y: center.y - cut),
                              control: CGPoint(x: center.x + r * 0.7, y: center.y - r * 0.7))
            path.addLine(to: CGPoint(x: center.x + r, y: center.y + cut))
            path.addQuadCurve(to: CGPoint(x: center.x + cut, y: center.y + r),
                              control: CGPoint(x: center.x + r * 0.7, y: center.y + r * 0.7))
            path.addLine(to: CGPoint(x: center.x - cut, y: center.y + r))
            path.addQuadCurve(to: CGPoint(x: center.x - r, y: center.y + cut),
                              control: CGPoint(x: center.x - r * 0.7, y: center.y + r * 0.7))
            path.addLine(to: CGPoint(x: center.x - r, y: center.y - cut))
            path.addQuadCurve(to: CGPoint(x: center.x - cut, y: center.y - r),
                              control: CGPoint(x: center.x - r * 0.7, y: center.y - r * 0.7))
            path.closeSubpath()

        case .amethyst:
            // Rounded triangle / pear (smooth teardrop — wider at top, pointed at bottom)
            let topW = radius * 0.85
            let topY = center.y - radius * 0.5
            let bottomY = center.y + radius * 0.9
            let peakY = center.y - radius * 0.85

            path.move(to: CGPoint(x: center.x, y: peakY))
            // Right side curve
            path.addQuadCurve(to: CGPoint(x: center.x + topW, y: center.y),
                              control: CGPoint(x: center.x + topW * 0.95, y: topY))
            // Bottom right curve
            path.addQuadCurve(to: CGPoint(x: center.x, y: bottomY),
                              control: CGPoint(x: center.x + topW * 0.5, y: bottomY))
            // Bottom left curve
            path.addQuadCurve(to: CGPoint(x: center.x - topW, y: center.y),
                              control: CGPoint(x: center.x - topW * 0.5, y: bottomY))
            // Left side curve back to top
            path.addQuadCurve(to: CGPoint(x: center.x, y: peakY),
                              control: CGPoint(x: center.x - topW * 0.95, y: topY))
            path.closeSubpath()
        }
        return path
    }

    // MARK: - Tile Textures

    func tileTexture(size: CGFloat, isLight: Bool) -> SKTexture {
        let key = "tile_\(Int(size))_\(isLight ? "L" : "D")"
        if let cached = miscCache[key] { return cached }

        let scale: CGFloat = 3.0
        let px = size * scale
        let inset: CGFloat = scale * 0.5
        let cornerR: CGFloat = 4 * scale
        let renderer = UIGraphicsImageRenderer(size: CGSize(width: px, height: px))

        let image = renderer.image { ctx in
            let gc = ctx.cgContext
            let rect = CGRect(x: inset, y: inset, width: px - inset * 2, height: px - inset * 2)
            let path = UIBezierPath(roundedRect: rect, cornerRadius: cornerR).cgPath
            let colorSpace = CGColorSpaceCreateDeviceRGB()

            // Rich warm gradient fill
            gc.saveGState()
            gc.addPath(path)
            gc.clip()

            let topColor: UIColor
            let botColor: UIColor
            if isLight {
                topColor = UIColor(red: 0.62, green: 0.52, blue: 0.38, alpha: 1.0)  // Rich warm tan
                botColor = UIColor(red: 0.54, green: 0.44, blue: 0.30, alpha: 1.0)
            } else {
                topColor = UIColor(red: 0.50, green: 0.40, blue: 0.28, alpha: 1.0)  // Warm brown
                botColor = UIColor(red: 0.42, green: 0.34, blue: 0.22, alpha: 1.0)
            }

            let tileColors = [topColor.cgColor, botColor.cgColor] as CFArray
            if let tileGrad = CGGradient(colorsSpace: colorSpace, colors: tileColors, locations: [0.0, 1.0]) {
                gc.drawLinearGradient(tileGrad,
                                      start: CGPoint(x: px / 2, y: inset),
                                      end: CGPoint(x: px / 2, y: px - inset),
                                      options: [])
            }

            // Stone texture noise
            for _ in 0..<12 {
                let sx = CGFloat.random(in: inset * 2...(px - inset * 2))
                let sy = CGFloat.random(in: inset * 2...(px - inset * 2))
                let sr = CGFloat.random(in: 1.0...2.0) * scale / 3
                let alpha = CGFloat.random(in: 0.03...0.08)
                gc.setFillColor(UIColor(white: Bool.random() ? 1.0 : 0.0, alpha: alpha).cgColor)
                gc.fillEllipse(in: CGRect(x: sx - sr, y: sy - sr, width: sr * 2, height: sr * 2))
            }
            gc.restoreGState()

            // Top + left bevel highlight
            gc.saveGState()
            gc.addPath(path)
            gc.clip()
            gc.setFillColor(UIColor(white: 1.0, alpha: 0.15).cgColor)
            gc.fill(CGRect(x: rect.minX, y: rect.minY, width: rect.width, height: 2.5 * scale))
            gc.fill(CGRect(x: rect.minX, y: rect.minY, width: 2 * scale, height: rect.height))
            gc.restoreGState()

            // Bottom + right bevel shadow
            gc.saveGState()
            gc.addPath(path)
            gc.clip()
            gc.setFillColor(UIColor(white: 0.0, alpha: 0.18).cgColor)
            gc.fill(CGRect(x: rect.minX, y: rect.maxY - 2.5 * scale, width: rect.width, height: 2.5 * scale))
            gc.fill(CGRect(x: rect.maxX - 2 * scale, y: rect.minY, width: 2 * scale, height: rect.height))
            gc.restoreGState()

            // Thin border
            gc.setStrokeColor(UIColor(white: 0.2, alpha: 0.3).cgColor)
            gc.setLineWidth(scale / 3)
            gc.addPath(path)
            gc.strokePath()
        }

        let texture = SKTexture(image: image)
        texture.filteringMode = .linear
        miscCache[key] = texture
        return texture
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
