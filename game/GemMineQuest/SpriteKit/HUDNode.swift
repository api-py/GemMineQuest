import SpriteKit

class HUDNode: SKNode {

    private var scoreLabel: SKLabelNode!
    private var scoreShadowLabel: SKLabelNode!
    private var movesLabel: SKLabelNode!
    private var movesShadowLabel: SKLabelNode!
    private var objectiveLabel: SKLabelNode!
    private var movesIcon: SKLabelNode!
    private let hudWidth: CGFloat
    private let scoreTitle: String
    private let movesTitle: String

    init(width: CGFloat, scoreTitle: String = "SCORE", movesTitle: String = "MOVES") {
        self.hudWidth = width
        self.scoreTitle = scoreTitle
        self.movesTitle = movesTitle
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
        let scoreTitleShadow = SKLabelNode(text: scoreTitle)
        scoreTitleShadow.fontName = "AvenirNext-Heavy"
        scoreTitleShadow.fontSize = 11
        scoreTitleShadow.fontColor = SKColor(white: 0, alpha: 0.6)
        scoreTitleShadow.position = CGPoint(x: -hudWidth * 0.3 + 1, y: 15 - 1)
        addChild(scoreTitleShadow)

        let scoreTitleLabel = SKLabelNode(text: scoreTitle)
        scoreTitleLabel.fontName = "AvenirNext-Heavy"
        scoreTitleLabel.fontSize = 11
        scoreTitleLabel.fontColor = ColorPalette.textSecondary
        scoreTitleLabel.position = CGPoint(x: -hudWidth * 0.3, y: 15)
        addChild(scoreTitleLabel)

        scoreShadowLabel = SKLabelNode(text: "0")
        let scoreShadow = scoreShadowLabel!
        scoreShadow.fontName = "AvenirNext-Heavy"
        scoreShadow.fontSize = 26
        scoreShadow.fontColor = SKColor(white: 0, alpha: 0.6)
        scoreShadow.position = CGPoint(x: -hudWidth * 0.3 + 1, y: -10 - 1)
        addChild(scoreShadow)

        scoreLabel = SKLabelNode(text: "0")
        scoreLabel.fontName = "AvenirNext-Heavy"
        scoreLabel.fontSize = 26
        scoreLabel.fontColor = ColorPalette.textGold
        scoreLabel.position = CGPoint(x: -hudWidth * 0.3, y: -10)
        addChild(scoreLabel)

        // Moves section (center)
        let movesTitleShadow = SKLabelNode(text: movesTitle)
        movesTitleShadow.fontName = "AvenirNext-Heavy"
        movesTitleShadow.fontSize = 11
        movesTitleShadow.fontColor = SKColor(white: 0, alpha: 0.6)
        movesTitleShadow.position = CGPoint(x: 1, y: 15 - 1)
        addChild(movesTitleShadow)

        let movesTitleLabel = SKLabelNode(text: movesTitle)
        movesTitleLabel.fontName = "AvenirNext-Heavy"
        movesTitleLabel.fontSize = 11
        movesTitleLabel.fontColor = ColorPalette.textSecondary
        movesTitleLabel.position = CGPoint(x: 0, y: 15)
        addChild(movesTitleLabel)

        movesShadowLabel = SKLabelNode(text: "20")
        let movesShadow = movesShadowLabel!
        movesShadow.fontName = "AvenirNext-Heavy"
        movesShadow.fontSize = 28
        movesShadow.fontColor = SKColor(white: 0, alpha: 0.6)
        movesShadow.position = CGPoint(x: 1, y: -12 - 1)
        addChild(movesShadow)

        movesLabel = SKLabelNode(text: "20")
        movesLabel.fontName = "AvenirNext-Heavy"
        movesLabel.fontSize = 28
        movesLabel.fontColor = ColorPalette.textPrimary
        movesLabel.position = CGPoint(x: 0, y: -12)
        addChild(movesLabel)

        // Objective section (right)
        let objectiveShadow = SKLabelNode(text: "")
        objectiveShadow.fontName = "AvenirNext-Heavy"
        objectiveShadow.fontSize = 13
        objectiveShadow.fontColor = SKColor(white: 0, alpha: 0.6)
        objectiveShadow.position = CGPoint(x: hudWidth * 0.3 + 1, y: 2 - 1)
        objectiveShadow.preferredMaxLayoutWidth = hudWidth * 0.35
        objectiveShadow.numberOfLines = 2
        objectiveShadow.verticalAlignmentMode = .center
        objectiveShadow.name = "objectiveShadow"
        addChild(objectiveShadow)

        objectiveLabel = SKLabelNode(text: "")
        objectiveLabel.fontName = "AvenirNext-Heavy"
        objectiveLabel.fontSize = 13
        objectiveLabel.fontColor = ColorPalette.textSecondary
        objectiveLabel.position = CGPoint(x: hudWidth * 0.3, y: 2)
        objectiveLabel.preferredMaxLayoutWidth = hudWidth * 0.35
        objectiveLabel.numberOfLines = 2
        objectiveLabel.verticalAlignmentMode = .center
        addChild(objectiveLabel)
    }

    func updateScore(_ score: Int) {
        let text = "\(score)"
        scoreLabel.text = text
        scoreShadowLabel?.text = text
        // Pop animation
        scoreLabel.run(SKAction.sequence([
            SKAction.scale(to: 1.2, duration: 0.1),
            SKAction.scale(to: 1.0, duration: 0.1)
        ]))
    }

    func updateMoves(_ moves: Int, godMode: Bool) {
        let text = godMode ? "\u{221E}" : "\(moves)"  // ∞ symbol
        movesLabel.text = text
        movesShadowLabel?.text = text
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
        if let shadow = childNode(withName: "objectiveShadow") as? SKLabelNode {
            shadow.text = text
        }
    }

    func showScorePopup(delta: Int, at position: CGPoint) {
        let popup = VisualEffects.createScorePopup(text: "+\(delta)", at: position)
        parent?.addChild(popup)
    }
}
