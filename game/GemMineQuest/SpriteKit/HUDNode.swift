import SpriteKit

class HUDNode: SKNode {

    private var scoreLabel: SKLabelNode!
    private var movesLabel: SKLabelNode!
    private var objectiveLabel: SKLabelNode!
    private var movesIcon: SKLabelNode!
    private let hudWidth: CGFloat

    init(width: CGFloat) {
        self.hudWidth = width
        super.init()
        setupHUD()
    }

    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) not supported")
    }

    private func setupHUD() {
        // Textured panel background with golden border
        let panelSize = CGSize(width: hudWidth - 20, height: 90)
        let panelTex = TextureFactory.shared.hudPanelTexture(size: panelSize)
        let bg = SKSpriteNode(texture: panelTex, size: panelSize)
        addChild(bg)

        // Score section (left) - with shadow for outline effect
        addOutlinedLabel(
            text: "SCORE",
            fontName: "AvenirNext-Heavy",
            fontSize: 12,
            color: ColorPalette.textSecondary,
            position: CGPoint(x: -hudWidth * 0.3, y: 15)
        )

        scoreLabel = SKLabelNode(text: "0")
        scoreLabel.fontName = "AvenirNext-Heavy"
        scoreLabel.fontSize = 26
        scoreLabel.fontColor = ColorPalette.textGold
        scoreLabel.position = CGPoint(x: -hudWidth * 0.3, y: -12)
        addChild(scoreLabel)
        addShadowLabel(for: scoreLabel)

        // Moves section (center)
        addOutlinedLabel(
            text: "MOVES",
            fontName: "AvenirNext-Heavy",
            fontSize: 12,
            color: ColorPalette.textSecondary,
            position: CGPoint(x: 0, y: 15)
        )

        movesLabel = SKLabelNode(text: "20")
        movesLabel.fontName = "AvenirNext-Heavy"
        movesLabel.fontSize = 30
        movesLabel.fontColor = ColorPalette.textPrimary
        movesLabel.position = CGPoint(x: 0, y: -14)
        addChild(movesLabel)
        addShadowLabel(for: movesLabel)

        // Objective section (right)
        objectiveLabel = SKLabelNode(text: "")
        objectiveLabel.fontName = "AvenirNext-DemiBold"
        objectiveLabel.fontSize = 13
        objectiveLabel.fontColor = ColorPalette.textSecondary
        objectiveLabel.position = CGPoint(x: hudWidth * 0.3, y: 2)
        objectiveLabel.preferredMaxLayoutWidth = hudWidth * 0.35
        objectiveLabel.numberOfLines = 2
        objectiveLabel.verticalAlignmentMode = .center
        addChild(objectiveLabel)
    }

    /// Add a shadow/outline behind a label for depth
    private func addShadowLabel(for label: SKLabelNode) {
        let shadow = SKLabelNode(text: label.text)
        shadow.fontName = label.fontName
        shadow.fontSize = label.fontSize
        shadow.fontColor = SKColor(white: 0.0, alpha: 0.7)
        shadow.position = CGPoint(x: label.position.x + 1, y: label.position.y - 1)
        shadow.zPosition = label.zPosition - 1
        insertChild(shadow, at: 0)
    }

    /// Create a label with built-in shadow outline
    @discardableResult
    private func addOutlinedLabel(text: String, fontName: String, fontSize: CGFloat, color: SKColor, position: CGPoint) -> SKLabelNode {
        // Shadow
        let shadow = SKLabelNode(text: text)
        shadow.fontName = fontName
        shadow.fontSize = fontSize
        shadow.fontColor = SKColor(white: 0.0, alpha: 0.6)
        shadow.position = CGPoint(x: position.x + 1, y: position.y - 1)
        addChild(shadow)

        // Main label
        let label = SKLabelNode(text: text)
        label.fontName = fontName
        label.fontSize = fontSize
        label.fontColor = color
        label.position = position
        addChild(label)

        return label
    }

    func updateScore(_ score: Int) {
        scoreLabel.text = "\(score)"
        // Spring pop animation
        let overshoot = SKAction.scale(to: 1.25, duration: 0.08)
        overshoot.timingMode = .easeOut
        let settle = SKAction.scale(to: 1.0, duration: 0.12)
        settle.timingMode = .easeInEaseOut
        scoreLabel.run(SKAction.sequence([overshoot, settle]))
    }

    func updateMoves(_ moves: Int, godMode: Bool) {
        movesLabel.text = godMode ? "\u{221E}" : "\(moves)"  // ∞ symbol
        movesLabel.fontColor = moves <= 3 && !godMode ? SKColor.red : ColorPalette.textPrimary

        if moves <= 3 && !godMode {
            let overshoot = SKAction.scale(to: 1.35, duration: 0.1)
            overshoot.timingMode = .easeOut
            let settle = SKAction.scale(to: 1.0, duration: 0.15)
            settle.timingMode = .easeInEaseOut
            movesLabel.run(SKAction.sequence([overshoot, settle]))
        }
    }

    func updateObjective(_ text: String) {
        objectiveLabel.text = text
    }

    func showScorePopup(delta: Int, at position: CGPoint) {
        let popup = VisualEffects.createScorePopup(text: "+\(delta)", at: position)
        parent?.addChild(popup)
    }
}
