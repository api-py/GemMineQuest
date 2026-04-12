import SpriteKit
import UIKit

/// Generates and caches high-resolution textures using CoreGraphics at 3x Retina.
/// All gems use smooth, symmetrical shapes with rich radial gradients and glass-like highlights.
class TextureFactory {
    static let shared = TextureFactory()

    private var gemTextureCache: [String: SKTexture] = [:]
    private var miscCache: [String: SKTexture] = [:]
    private static let colorSpace = CGColorSpaceCreateDeviceRGB()

    // MARK: - Gem Textures

    /// Asset name mapping for each gem color (Welsh mineral names)
    private func gemAssetName(for color: GemColor) -> String {
        switch color {
        case .ruby:     return "gem_dragon_stone"
        case .gold:     return "gem_welsh_gold"
        case .silver:   return "gem_arian"
        case .emerald:  return "gem_preseli_stone"
        case .sapphire: return "gem_slate_gem"
        case .amethyst: return "gem_ceridwen_crystal"
        }
    }

    func gemTexture(for color: GemColor, size: CGFloat) -> SKTexture {
        let key = "\(color.rawValue)_\(Int(size))"
        if let cached = gemTextureCache[key] { return cached }

        let scale: CGFloat = 3.0
        let px = size * scale
        let targetSize = CGSize(width: px, height: px)

        // Try loading from asset catalog first
        if let assetImage = UIImage(named: gemAssetName(for: color)) {
            let renderer = UIGraphicsImageRenderer(size: targetSize)
            let scaled = renderer.image { ctx in
                assetImage.draw(in: CGRect(origin: .zero, size: targetSize))
            }
            let texture = SKTexture(image: scaled)
            texture.filteringMode = .linear
            gemTextureCache[key] = texture
            return texture
        }

        // Fallback to procedural rendering
        let renderer = UIGraphicsImageRenderer(size: targetSize)
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
        guard radius > 0 else { return }  // Prevent empty path / clip warnings

        let primary = color.primaryColor
        let light = color.lightColor
        let dark = color.darkColor
        let colorSpace = Self.colorSpace

        // 1) Drop shadow
        gc.saveGState()
        gc.setShadow(offset: CGSize(width: 3, height: 5), blur: 12,
                      color: UIColor(white: 0, alpha: 0.55).cgColor)
        let shapePath = gemShapePath(for: color, center: center, radius: radius)
        guard !shapePath.isEmpty else { gc.restoreGState(); return }
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

        // 5) Glossy highlight (radial gradient — no hard edges)
        gc.saveGState()
        gc.addPath(gemShapePath(for: color, center: center, radius: radius))
        gc.clip()

        let shineCenter = CGPoint(x: center.x - radius * 0.15, y: center.y - radius * 0.35)
        let shineColors = [
            UIColor(white: 1.0, alpha: 0.5).cgColor,
            UIColor(white: 1.0, alpha: 0.15).cgColor,
            UIColor(white: 1.0, alpha: 0.0).cgColor
        ] as CFArray
        if let shineGrad = CGGradient(colorsSpace: colorSpace, colors: shineColors, locations: [0.0, 0.4, 1.0]) {
            gc.drawRadialGradient(shineGrad,
                                  startCenter: shineCenter, startRadius: 0,
                                  endCenter: shineCenter, endRadius: radius * 0.85,
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
        let r = radius
        switch color {
        case .ruby:
            // 6-point tall shield (straight lines only)
            path.move(to: CGPoint(x: center.x - r * 0.3, y: center.y - r * 0.85))
            path.addLine(to: CGPoint(x: center.x + r * 0.3, y: center.y - r * 0.85))
            path.addLine(to: CGPoint(x: center.x + r * 0.85, y: center.y - r * 0.2))
            path.addLine(to: CGPoint(x: center.x + r * 0.35, y: center.y + r * 0.55))
            path.addLine(to: CGPoint(x: center.x, y: center.y + r * 0.92))
            path.addLine(to: CGPoint(x: center.x - r * 0.35, y: center.y + r * 0.55))
            path.addLine(to: CGPoint(x: center.x - r * 0.85, y: center.y - r * 0.2))
            path.closeSubpath()

        case .gold:
            // Rounded square (cushion-cut gem) — slightly larger
            let s = r * 0.85
            let cr = r * 0.35
            path.addRoundedRect(in: CGRect(x: center.x - s, y: center.y - s, width: s * 2, height: s * 2),
                                cornerWidth: cr, cornerHeight: cr)

        case .silver:
            // Circle — slightly larger
            path.addEllipse(in: CGRect(x: center.x - r * 0.92, y: center.y - r * 0.92,
                                       width: r * 1.84, height: r * 1.84))

        case .emerald:
            // Tall emerald-cut octagon (taller than wide, clipped corners)
            let w = r * 0.72
            let h = r * 0.92
            let bevel = r * 0.22
            path.move(to: CGPoint(x: center.x - w + bevel, y: center.y - h))
            path.addLine(to: CGPoint(x: center.x + w - bevel, y: center.y - h))
            path.addLine(to: CGPoint(x: center.x + w, y: center.y - h + bevel))
            path.addLine(to: CGPoint(x: center.x + w, y: center.y + h - bevel))
            path.addLine(to: CGPoint(x: center.x + w - bevel, y: center.y + h))
            path.addLine(to: CGPoint(x: center.x - w + bevel, y: center.y + h))
            path.addLine(to: CGPoint(x: center.x - w, y: center.y + h - bevel))
            path.addLine(to: CGPoint(x: center.x - w, y: center.y - h + bevel))
            path.closeSubpath()

        case .sapphire:
            // Tighter rounded octagon
            let sr = r * 0.9
            let cut = sr * 0.42
            path.move(to: CGPoint(x: center.x - cut, y: center.y - sr))
            path.addLine(to: CGPoint(x: center.x + cut, y: center.y - sr))
            path.addQuadCurve(to: CGPoint(x: center.x + sr, y: center.y - cut),
                              control: CGPoint(x: center.x + sr * 0.85, y: center.y - sr * 0.85))
            path.addLine(to: CGPoint(x: center.x + sr, y: center.y + cut))
            path.addQuadCurve(to: CGPoint(x: center.x + cut, y: center.y + sr),
                              control: CGPoint(x: center.x + sr * 0.85, y: center.y + sr * 0.85))
            path.addLine(to: CGPoint(x: center.x - cut, y: center.y + sr))
            path.addQuadCurve(to: CGPoint(x: center.x - sr, y: center.y + cut),
                              control: CGPoint(x: center.x - sr * 0.85, y: center.y + sr * 0.85))
            path.addLine(to: CGPoint(x: center.x - sr, y: center.y - cut))
            path.addQuadCurve(to: CGPoint(x: center.x - cut, y: center.y - sr),
                              control: CGPoint(x: center.x - sr * 0.85, y: center.y - sr * 0.85))
            path.closeSubpath()

        case .amethyst:
            // Rounded triangle / pear (smooth teardrop — wider at top, pointed at bottom)
            let topW = r * 0.85
            let topY = center.y - r * 0.5
            let bottomY = center.y + r * 0.9
            let peakY = center.y - r * 0.85

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
        let cornerR: CGFloat = 8 * scale
        let renderer = UIGraphicsImageRenderer(size: CGSize(width: px, height: px))

        let image = renderer.image { ctx in
            let gc = ctx.cgContext
            let rect = CGRect(x: inset, y: inset, width: px - inset * 2, height: px - inset * 2)
            let path = UIBezierPath(roundedRect: rect, cornerRadius: cornerR).cgPath
            let colorSpace = Self.colorSpace

            // Rich warm gradient fill
            gc.saveGState()
            gc.addPath(path)
            gc.clip()

            // Uniform blue tiles — identical for both light/dark variants
            let topColor = UIColor(red: 0.45, green: 0.65, blue: 0.90, alpha: 1.0)   // Light sky blue
            let botColor = UIColor(red: 0.22, green: 0.40, blue: 0.68, alpha: 1.0)   // Deeper blue

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
            let colorSpace = Self.colorSpace
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
