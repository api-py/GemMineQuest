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
        // Background
        let bg = SKShapeNode(rectOf: CGSize(width: hudWidth - 20, height: 90), cornerRadius: 12)
        bg.fillColor = ColorPalette.hudBackground
        bg.strokeColor = SKColor(hex: 0x6B4F3A, alpha: 0.5)
        bg.lineWidth = 1
        addChild(bg)

        // Score section (left)
        let scoreTitleLabel = SKLabelNode(text: "SCORE")
        scoreTitleLabel.fontName = "AvenirNext-Medium"
        scoreTitleLabel.fontSize = 11
        scoreTitleLabel.fontColor = ColorPalette.textSecondary
        scoreTitleLabel.position = CGPoint(x: -hudWidth * 0.3, y: 15)
        addChild(scoreTitleLabel)

        scoreLabel = SKLabelNode(text: "0")
        scoreLabel.fontName = "AvenirNext-Bold"
        scoreLabel.fontSize = 22
        scoreLabel.fontColor = ColorPalette.textGold
        scoreLabel.position = CGPoint(x: -hudWidth * 0.3, y: -10)
        addChild(scoreLabel)

        // Moves section (center)
        let movesTitleLabel = SKLabelNode(text: "MOVES")
        movesTitleLabel.fontName = "AvenirNext-Medium"
        movesTitleLabel.fontSize = 11
        movesTitleLabel.fontColor = ColorPalette.textSecondary
        movesTitleLabel.position = CGPoint(x: 0, y: 15)
        addChild(movesTitleLabel)

        movesLabel = SKLabelNode(text: "20")
        movesLabel.fontName = "AvenirNext-Bold"
        movesLabel.fontSize = 28
        movesLabel.fontColor = ColorPalette.textPrimary
        movesLabel.position = CGPoint(x: 0, y: -12)
        addChild(movesLabel)

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

    func updateScore(_ score: Int) {
        scoreLabel.text = "\(score)"
        // Pop animation
        scoreLabel.run(SKAction.sequence([
            SKAction.scale(to: 1.2, duration: 0.1),
            SKAction.scale(to: 1.0, duration: 0.1)
        ]))
    }

    func updateMoves(_ moves: Int, godMode: Bool) {
        movesLabel.text = godMode ? "\u{221E}" : "\(moves)"  // ∞ symbol
        movesLabel.fontColor = moves <= 3 && !godMode ? SKColor.red : ColorPalette.textPrimary

        if moves <= 3 && !godMode {
            movesLabel.run(SKAction.sequence([
                SKAction.scale(to: 1.3, duration: 0.15),
                SKAction.scale(to: 1.0, duration: 0.15)
            ]))
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
