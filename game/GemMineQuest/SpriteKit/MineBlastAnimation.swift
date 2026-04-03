import SpriteKit

/// Handles the end-level Mine Blast bonus animation sequence
class MineBlastAnimation {

    static func createBannerNode(text: String, size: CGSize) -> SKNode {
        let container = SKNode()
        container.zPosition = 100

        // Dark overlay
        let overlay = SKShapeNode(rectOf: size)
        overlay.fillColor = SKColor(white: 0.0, alpha: 0.5)
        overlay.strokeColor = .clear
        overlay.position = CGPoint(x: size.width / 2, y: size.height / 2)
        container.addChild(overlay)

        // Banner text
        let label = SKLabelNode(text: text)
        label.fontName = "AvenirNext-Bold"
        label.fontSize = 36
        label.fontColor = ColorPalette.textGold
        label.position = CGPoint(x: size.width / 2, y: size.height / 2)
        label.verticalAlignmentMode = .center

        // Animate in
        label.setScale(0.0)
        label.run(SKAction.sequence([
            SKAction.scale(to: 1.2, duration: 0.3),
            SKAction.scale(to: 1.0, duration: 0.1),
            SKAction.wait(forDuration: 0.8),
            SKAction.fadeOut(withDuration: 0.3)
        ]))
        container.addChild(label)

        // Auto-remove
        container.run(SKAction.sequence([
            SKAction.wait(forDuration: 1.5),
            SKAction.removeFromParent()
        ]))

        return container
    }
}
