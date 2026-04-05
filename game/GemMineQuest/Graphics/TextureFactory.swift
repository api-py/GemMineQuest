import SpriteKit
import UIKit

/// Generates and caches high-resolution textures using CoreGraphics.
/// Replaces flat SKShapeNode rendering with rich gradients, highlights, and depth.
class TextureFactory {
    static let shared = TextureFactory()

    private var gemTextureCache: [String: SKTexture] = [:]
    private var tileTextureCache: [String: SKTexture] = [:]
    private var glowTextureCache: [String: SKTexture] = [:]

    // MARK: - Gem Textures

    func gemTexture(for color: GemColor, size: CGFloat) -> SKTexture {
        let key = "\(color.rawValue)_\(Int(size))"
        if let cached = gemTextureCache[key] { return cached }

        let scale: CGFloat = 3.0
        let pixelSize = size * scale
        let renderer = UIGraphicsImageRenderer(size: CGSize(width: pixelSize, height: pixelSize))

        let image = renderer.image { ctx in
            let gc = ctx.cgContext
            let center = CGPoint(x: pixelSize / 2, y: pixelSize / 2)
            let radius = pixelSize * 0.42

            if color.isMetal {
                drawMetalNugget(gc: gc, center: center, radius: radius, pixelSize: pixelSize, color: color)
            } else {
                drawGemstone(gc: gc, center: center, radius: radius, pixelSize: pixelSize, color: color)
            }
        }

        let texture = SKTexture(image: image)
        texture.filteringMode = .linear
        gemTextureCache[key] = texture
        return texture
    }

    // MARK: - Gemstone Rendering

    private func drawGemstone(gc: CGContext, center: CGPoint, radius: CGFloat, pixelSize: CGFloat, color: GemColor) {
        let primary = color.primaryColor
        let light = color.lightColor
        let dark = color.darkColor

        // Drop shadow
        gc.saveGState()
        gc.setShadow(offset: CGSize(width: 3, height: 3), blur: 8, color: UIColor(white: 0, alpha: 0.4).cgColor)
        let shadowPath = createOctagonPath(center: center, radius: radius)
        gc.addPath(shadowPath)
        gc.setFillColor(primary.cgColor)
        gc.fillPath()
        gc.restoreGState()

        // Main gem body with radial gradient
        gc.saveGState()
        let gemPath = createOctagonPath(center: center, radius: radius)
        gc.addPath(gemPath)
        gc.clip()

        let colorSpace = CGColorSpaceCreateDeviceRGB()
        let gradientColors = [light.cgColor, primary.cgColor, dark.cgColor] as CFArray
        let gradientLocations: [CGFloat] = [0.0, 0.5, 1.0]
        if let gradient = CGGradient(colorsSpace: colorSpace, colors: gradientColors, locations: gradientLocations) {
            gc.drawRadialGradient(gradient,
                                  startCenter: CGPoint(x: center.x - radius * 0.2, y: center.y - radius * 0.2),
                                  startRadius: 0,
                                  endCenter: center,
                                  endRadius: radius * 1.1,
                                  options: [.drawsAfterEndLocation])
        }
        gc.restoreGState()

        // Facet lines
        gc.saveGState()
        let facetPath = createOctagonPath(center: center, radius: radius)
        gc.addPath(facetPath)
        gc.clip()
        gc.setStrokeColor(UIColor(white: 1.0, alpha: 0.15).cgColor)
        gc.setLineWidth(1.5)
        for i in 0..<8 {
            let angle = CGFloat(i) / 8.0 * .pi * 2 + .pi / 8
            gc.move(to: center)
            gc.addLine(to: CGPoint(
                x: center.x + cos(angle) * radius,
                y: center.y + sin(angle) * radius
            ))
        }
        gc.strokePath()
        gc.restoreGState()

        // Outline stroke
        gc.setStrokeColor(dark.cgColor)
        gc.setLineWidth(2.0)
        gc.addPath(createOctagonPath(center: center, radius: radius))
        gc.strokePath()

        // Glossy highlight arc (upper portion)
        gc.saveGState()
        let highlightRect = CGRect(
            x: center.x - radius * 0.65,
            y: center.y - radius * 0.9,
            width: radius * 1.3,
            height: radius * 0.9
        )
        gc.addEllipse(in: highlightRect)
        gc.clip()

        let highlightColors = [
            UIColor(white: 1.0, alpha: 0.55).cgColor,
            UIColor(white: 1.0, alpha: 0.0).cgColor
        ] as CFArray
        let highlightLocs: [CGFloat] = [0.0, 1.0]
        if let highlightGrad = CGGradient(colorsSpace: colorSpace, colors: highlightColors, locations: highlightLocs) {
            gc.drawLinearGradient(highlightGrad,
                                  start: CGPoint(x: center.x, y: center.y - radius * 0.9),
                                  end: CGPoint(x: center.x, y: center.y),
                                  options: [])
        }
        gc.restoreGState()

        // Specular dot
        let specCenter = CGPoint(x: center.x - radius * 0.25, y: center.y - radius * 0.3)
        let specRadius: CGFloat = radius * 0.1
        gc.saveGState()
        let specColors = [
            UIColor(white: 1.0, alpha: 0.9).cgColor,
            UIColor(white: 1.0, alpha: 0.0).cgColor
        ] as CFArray
        if let specGrad = CGGradient(colorsSpace: colorSpace, colors: specColors, locations: [0.0, 1.0]) {
            gc.drawRadialGradient(specGrad,
                                  startCenter: specCenter, startRadius: 0,
                                  endCenter: specCenter, endRadius: specRadius * 2,
                                  options: [])
        }
        gc.restoreGState()
    }

    // MARK: - Metal Nugget Rendering

    private func drawMetalNugget(gc: CGContext, center: CGPoint, radius: CGFloat, pixelSize: CGFloat, color: GemColor) {
        let primary = color.primaryColor
        let light = color.lightColor
        let dark = color.darkColor

        // Drop shadow
        gc.saveGState()
        gc.setShadow(offset: CGSize(width: 3, height: 3), blur: 8, color: UIColor(white: 0, alpha: 0.4).cgColor)
        let nuggetRect = CGRect(x: center.x - radius, y: center.y - radius * 0.85,
                                width: radius * 2, height: radius * 1.7)
        let nuggetPath = UIBezierPath(roundedRect: nuggetRect, cornerRadius: radius * 0.35).cgPath
        gc.addPath(nuggetPath)
        gc.setFillColor(primary.cgColor)
        gc.fillPath()
        gc.restoreGState()

        // Main body with vertical linear gradient (metallic sheen)
        gc.saveGState()
        gc.addPath(nuggetPath)
        gc.clip()

        let colorSpace = CGColorSpaceCreateDeviceRGB()
        let metalColors = [dark.cgColor, primary.cgColor, light.cgColor, primary.cgColor, dark.cgColor] as CFArray
        let metalLocs: [CGFloat] = [0.0, 0.25, 0.45, 0.65, 1.0]
        if let metalGrad = CGGradient(colorsSpace: colorSpace, colors: metalColors, locations: metalLocs) {
            gc.drawLinearGradient(metalGrad,
                                  start: CGPoint(x: center.x, y: nuggetRect.minY),
                                  end: CGPoint(x: center.x, y: nuggetRect.maxY),
                                  options: [])
        }
        gc.restoreGState()

        // Horizontal highlight band (metallic reflection)
        gc.saveGState()
        gc.addPath(nuggetPath)
        gc.clip()
        let bandY = center.y - radius * 0.3
        let bandHeight = radius * 0.35
        let bandRect = CGRect(x: nuggetRect.minX, y: bandY, width: nuggetRect.width, height: bandHeight)
        gc.addEllipse(in: bandRect)
        gc.clip()

        let bandColors = [
            UIColor(white: 1.0, alpha: 0.0).cgColor,
            UIColor(white: 1.0, alpha: 0.45).cgColor,
            UIColor(white: 1.0, alpha: 0.0).cgColor
        ] as CFArray
        if let bandGrad = CGGradient(colorsSpace: colorSpace, colors: bandColors, locations: [0.0, 0.5, 1.0]) {
            gc.drawLinearGradient(bandGrad,
                                  start: CGPoint(x: nuggetRect.minX, y: bandY),
                                  end: CGPoint(x: nuggetRect.maxX, y: bandY),
                                  options: [])
        }
        gc.restoreGState()

        // Outline
        gc.setStrokeColor(dark.cgColor)
        gc.setLineWidth(2.0)
        gc.addPath(nuggetPath)
        gc.strokePath()

        // Surface bumps/facets for metallic texture
        gc.saveGState()
        gc.addPath(nuggetPath)
        gc.clip()
        gc.setStrokeColor(UIColor(white: 1.0, alpha: 0.12).cgColor)
        gc.setLineWidth(1.0)
        for i in 0..<5 {
            let offsetX = CGFloat(i) * radius * 0.35 - radius * 0.7
            gc.move(to: CGPoint(x: center.x + offsetX, y: center.y - radius * 0.6))
            gc.addLine(to: CGPoint(x: center.x + offsetX + radius * 0.15, y: center.y + radius * 0.5))
        }
        gc.strokePath()
        gc.restoreGState()

        // Specular highlight
        let specCenter = CGPoint(x: center.x - radius * 0.2, y: center.y - radius * 0.35)
        gc.saveGState()
        let specColors = [
            UIColor(white: 1.0, alpha: 0.85).cgColor,
            UIColor(white: 1.0, alpha: 0.0).cgColor
        ] as CFArray
        if let specGrad = CGGradient(colorsSpace: colorSpace, colors: specColors, locations: [0.0, 1.0]) {
            gc.drawRadialGradient(specGrad,
                                  startCenter: specCenter, startRadius: 0,
                                  endCenter: specCenter, endRadius: radius * 0.15,
                                  options: [])
        }
        gc.restoreGState()
    }

    // MARK: - Tile Texture

    func tileTexture(size: CGFloat) -> SKTexture {
        let key = "tile_\(Int(size))"
        if let cached = tileTextureCache[key] { return cached }

        let scale: CGFloat = 3.0
        let pixelSize = size * scale
        let inset: CGFloat = scale
        let renderer = UIGraphicsImageRenderer(size: CGSize(width: pixelSize, height: pixelSize))

        let image = renderer.image { ctx in
            let gc = ctx.cgContext
            let rect = CGRect(x: inset, y: inset, width: pixelSize - inset * 2, height: pixelSize - inset * 2)
            let path = UIBezierPath(roundedRect: rect, cornerRadius: 6 * scale).cgPath

            // Base fill with subtle gradient
            gc.saveGState()
            gc.addPath(path)
            gc.clip()

            let colorSpace = CGColorSpaceCreateDeviceRGB()
            let baseTop = UIColor(red: 0.32, green: 0.22, blue: 0.17, alpha: 0.55)
            let baseBot = UIColor(red: 0.25, green: 0.16, blue: 0.11, alpha: 0.55)
            let tileColors = [baseTop.cgColor, baseBot.cgColor] as CFArray
            if let tileGrad = CGGradient(colorsSpace: colorSpace, colors: tileColors, locations: [0.0, 1.0]) {
                gc.drawLinearGradient(tileGrad,
                                      start: CGPoint(x: pixelSize / 2, y: 0),
                                      end: CGPoint(x: pixelSize / 2, y: pixelSize),
                                      options: [])
            }

            // Noise speckles for stone texture
            for _ in 0..<12 {
                let speckX = CGFloat.random(in: inset * 2...(pixelSize - inset * 2))
                let speckY = CGFloat.random(in: inset * 2...(pixelSize - inset * 2))
                let speckR = CGFloat.random(in: 1.5...3.0) * scale / 3
                let alpha = CGFloat.random(in: 0.05...0.15)
                gc.setFillColor(UIColor(white: 1.0, alpha: alpha).cgColor)
                gc.fillEllipse(in: CGRect(x: speckX - speckR, y: speckY - speckR, width: speckR * 2, height: speckR * 2))
            }
            gc.restoreGState()

            // Inner bevel - top/left lighter edge
            gc.saveGState()
            gc.addPath(path)
            gc.clip()
            gc.setStrokeColor(UIColor(white: 1.0, alpha: 0.12).cgColor)
            gc.setLineWidth(2 * scale / 3)
            let topEdge = UIBezierPath()
            topEdge.move(to: CGPoint(x: rect.minX + 6 * scale, y: rect.minY))
            topEdge.addLine(to: CGPoint(x: rect.maxX - 6 * scale, y: rect.minY))
            gc.addPath(topEdge.cgPath)
            gc.strokePath()

            let leftEdge = UIBezierPath()
            leftEdge.move(to: CGPoint(x: rect.minX, y: rect.minY + 6 * scale))
            leftEdge.addLine(to: CGPoint(x: rect.minX, y: rect.maxY - 6 * scale))
            gc.addPath(leftEdge.cgPath)
            gc.strokePath()

            // Bottom/right darker edge
            gc.setStrokeColor(UIColor(white: 0.0, alpha: 0.15).cgColor)
            let bottomEdge = UIBezierPath()
            bottomEdge.move(to: CGPoint(x: rect.minX + 6 * scale, y: rect.maxY))
            bottomEdge.addLine(to: CGPoint(x: rect.maxX - 6 * scale, y: rect.maxY))
            gc.addPath(bottomEdge.cgPath)
            gc.strokePath()

            let rightEdge = UIBezierPath()
            rightEdge.move(to: CGPoint(x: rect.maxX, y: rect.minY + 6 * scale))
            rightEdge.addLine(to: CGPoint(x: rect.maxX, y: rect.maxY - 6 * scale))
            gc.addPath(rightEdge.cgPath)
            gc.strokePath()
            gc.restoreGState()

            // Outer border
            gc.setStrokeColor(UIColor(white: 0.3, alpha: 0.25).cgColor)
            gc.setLineWidth(1.0 * scale / 3)
            gc.addPath(path)
            gc.strokePath()
        }

        let texture = SKTexture(image: image)
        texture.filteringMode = .linear
        tileTextureCache[key] = texture
        return texture
    }

    // MARK: - Soft Glow Texture (for particles and gem halos)

    func softGlowTexture(size: CGFloat) -> SKTexture {
        let key = "glow_\(Int(size))"
        if let cached = glowTextureCache[key] { return cached }

        let pixelSize = size * 2
        let renderer = UIGraphicsImageRenderer(size: CGSize(width: pixelSize, height: pixelSize))

        let image = renderer.image { ctx in
            let gc = ctx.cgContext
            let center = CGPoint(x: pixelSize / 2, y: pixelSize / 2)
            let radius = pixelSize / 2

            let colorSpace = CGColorSpaceCreateDeviceRGB()
            let colors = [
                UIColor(white: 1.0, alpha: 1.0).cgColor,
                UIColor(white: 1.0, alpha: 0.3).cgColor,
                UIColor(white: 1.0, alpha: 0.0).cgColor
            ] as CFArray
            let locations: [CGFloat] = [0.0, 0.4, 1.0]
            if let gradient = CGGradient(colorsSpace: colorSpace, colors: colors, locations: locations) {
                gc.drawRadialGradient(gradient,
                                      startCenter: center, startRadius: 0,
                                      endCenter: center, endRadius: radius,
                                      options: [])
            }
        }

        let texture = SKTexture(image: image)
        texture.filteringMode = .linear
        glowTextureCache[key] = texture
        return texture
    }

    // MARK: - Sparkle Texture (star-shaped for match effects)

    func sparkleTexture(size: CGFloat = 32) -> SKTexture {
        let key = "sparkle_\(Int(size))"
        if let cached = glowTextureCache[key] { return cached }

        let pixelSize = size * 2
        let renderer = UIGraphicsImageRenderer(size: CGSize(width: pixelSize, height: pixelSize))

        let image = renderer.image { ctx in
            let gc = ctx.cgContext
            let center = CGPoint(x: pixelSize / 2, y: pixelSize / 2)
            let outerR = pixelSize * 0.45
            let innerR = pixelSize * 0.12

            // 4-pointed star
            let starPath = CGMutablePath()
            for i in 0..<8 {
                let angle = CGFloat(i) / 8.0 * .pi * 2 - .pi / 2
                let r = i % 2 == 0 ? outerR : innerR
                let point = CGPoint(x: center.x + cos(angle) * r, y: center.y + sin(angle) * r)
                if i == 0 { starPath.move(to: point) }
                else { starPath.addLine(to: point) }
            }
            starPath.closeSubpath()

            gc.addPath(starPath)
            gc.setFillColor(UIColor.white.cgColor)
            gc.fillPath()

            // Soft glow around star
            let colorSpace = CGColorSpaceCreateDeviceRGB()
            let glowColors = [
                UIColor(white: 1.0, alpha: 0.5).cgColor,
                UIColor(white: 1.0, alpha: 0.0).cgColor
            ] as CFArray
            if let glowGrad = CGGradient(colorsSpace: colorSpace, colors: glowColors, locations: [0.0, 1.0]) {
                gc.drawRadialGradient(glowGrad,
                                      startCenter: center, startRadius: innerR,
                                      endCenter: center, endRadius: outerR * 1.2,
                                      options: [])
            }
        }

        let texture = SKTexture(image: image)
        texture.filteringMode = .linear
        glowTextureCache[key] = texture
        return texture
    }

    // MARK: - Board Frame Texture

    func boardFrameTexture(size: CGSize, frameWidth: CGFloat = 8) -> SKTexture {
        let scale: CGFloat = 2.0
        let pixelW = size.width * scale
        let pixelH = size.height * scale
        let fw = frameWidth * scale
        let renderer = UIGraphicsImageRenderer(size: CGSize(width: pixelW, height: pixelH))

        let image = renderer.image { ctx in
            let gc = ctx.cgContext
            let outerRect = CGRect(x: 0, y: 0, width: pixelW, height: pixelH)
            let innerRect = outerRect.insetBy(dx: fw, dy: fw)
            let cornerR = fw * 1.5

            // Outer frame path (outer rect minus inner rect)
            let outerPath = UIBezierPath(roundedRect: outerRect, cornerRadius: cornerR)
            let innerPath = UIBezierPath(roundedRect: innerRect, cornerRadius: cornerR * 0.6)

            // Fill frame with golden gradient
            gc.saveGState()
            outerPath.append(innerPath.reversing())
            gc.addPath(outerPath.cgPath)
            gc.clip()

            let colorSpace = CGColorSpaceCreateDeviceRGB()
            let goldTop = UIColor(red: 0.95, green: 0.78, blue: 0.35, alpha: 1.0)
            let goldMid = UIColor(red: 0.85, green: 0.65, blue: 0.2, alpha: 1.0)
            let goldBot = UIColor(red: 0.6, green: 0.45, blue: 0.15, alpha: 1.0)
            let frameColors = [goldTop.cgColor, goldMid.cgColor, goldBot.cgColor] as CFArray
            if let frameGrad = CGGradient(colorsSpace: colorSpace, colors: frameColors, locations: [0.0, 0.5, 1.0]) {
                gc.drawLinearGradient(frameGrad,
                                      start: CGPoint(x: pixelW / 2, y: 0),
                                      end: CGPoint(x: pixelW / 2, y: pixelH),
                                      options: [])
            }
            gc.restoreGState()

            // Bevel highlight (top-left inner edge)
            gc.setStrokeColor(UIColor(white: 1.0, alpha: 0.3).cgColor)
            gc.setLineWidth(1.5)
            gc.addPath(UIBezierPath(roundedRect: innerRect.insetBy(dx: -1, dy: -1), cornerRadius: cornerR * 0.6).cgPath)
            gc.strokePath()

            // Outer dark edge
            gc.setStrokeColor(UIColor(red: 0.4, green: 0.3, blue: 0.1, alpha: 0.8).cgColor)
            gc.setLineWidth(2.0)
            gc.addPath(UIBezierPath(roundedRect: outerRect.insetBy(dx: 1, dy: 1), cornerRadius: cornerR).cgPath)
            gc.strokePath()
        }

        let texture = SKTexture(image: image)
        texture.filteringMode = .linear
        return texture
    }

    // MARK: - HUD Panel Texture

    func hudPanelTexture(size: CGSize) -> SKTexture {
        let scale: CGFloat = 2.0
        let pixelW = size.width * scale
        let pixelH = size.height * scale
        let renderer = UIGraphicsImageRenderer(size: CGSize(width: pixelW, height: pixelH))

        let image = renderer.image { ctx in
            let gc = ctx.cgContext
            let rect = CGRect(x: 0, y: 0, width: pixelW, height: pixelH)
            let cornerR: CGFloat = 16 * scale
            let path = UIBezierPath(roundedRect: rect.insetBy(dx: 2, dy: 2), cornerRadius: cornerR).cgPath

            // Dark panel fill with gradient
            gc.saveGState()
            gc.addPath(path)
            gc.clip()

            let colorSpace = CGColorSpaceCreateDeviceRGB()
            let panelTop = UIColor(red: 0.2, green: 0.12, blue: 0.08, alpha: 0.92)
            let panelBot = UIColor(red: 0.14, green: 0.08, blue: 0.04, alpha: 0.92)
            let panelColors = [panelTop.cgColor, panelBot.cgColor] as CFArray
            if let panelGrad = CGGradient(colorsSpace: colorSpace, colors: panelColors, locations: [0.0, 1.0]) {
                gc.drawLinearGradient(panelGrad,
                                      start: CGPoint(x: pixelW / 2, y: 0),
                                      end: CGPoint(x: pixelW / 2, y: pixelH),
                                      options: [])
            }
            gc.restoreGState()

            // Golden border
            gc.setStrokeColor(UIColor(red: 0.85, green: 0.65, blue: 0.2, alpha: 0.7).cgColor)
            gc.setLineWidth(3.0)
            gc.addPath(path)
            gc.strokePath()

            // Inner highlight edge (top)
            gc.setStrokeColor(UIColor(white: 1.0, alpha: 0.08).cgColor)
            gc.setLineWidth(1.5)
            let innerPath = UIBezierPath(roundedRect: rect.insetBy(dx: 5, dy: 5), cornerRadius: cornerR - 3).cgPath
            gc.addPath(innerPath)
            gc.strokePath()
        }

        let texture = SKTexture(image: image)
        texture.filteringMode = .linear
        return texture
    }

    // MARK: - Helpers

    private func createOctagonPath(center: CGPoint, radius: CGFloat) -> CGPath {
        let path = CGMutablePath()
        let sides = 8
        let angleOffset = CGFloat.pi / CGFloat(sides)

        for i in 0..<sides {
            let angle = CGFloat(i) / CGFloat(sides) * .pi * 2 + angleOffset
            let point = CGPoint(x: center.x + cos(angle) * radius, y: center.y + sin(angle) * radius)
            if i == 0 { path.move(to: point) }
            else { path.addLine(to: point) }
        }
        path.closeSubpath()
        return path
    }

    /// Clear all caches (call on memory warning)
    func clearCaches() {
        gemTextureCache.removeAll()
        tileTextureCache.removeAll()
        glowTextureCache.removeAll()
    }
}
