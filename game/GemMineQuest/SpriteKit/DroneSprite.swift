import SpriteKit

class DroneSprite: SKNode {

    init(size: CGFloat) {
        super.init()
        let droneVisual = GemRenderer.createDroneNode(size: size)
        addChild(droneVisual)
        self.zPosition = 55
    }

    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) not supported")
    }

    /// Animate drone flying from start to target, then destroy target
    func flyToTarget(from start: CGPoint, to target: CGPoint, completion: @escaping () -> Void) {
        self.position = start

        let dx = target.x - start.x
        let dy = target.y - start.y
        let distance = sqrt(dx * dx + dy * dy)
        let duration = TimeInterval(distance / 300.0) // Speed: 300 pt/s

        // Arc path
        let midPoint = CGPoint(
            x: (start.x + target.x) / 2 + CGFloat.random(in: -40...40),
            y: max(start.y, target.y) + 60
        )

        let path = CGMutablePath()
        path.move(to: start)
        path.addQuadCurve(to: target, control: midPoint)

        let flyAction = SKAction.follow(path, asOffset: false, orientToPath: true, duration: duration)
        flyAction.timingMode = .easeInEaseOut

        run(SKAction.sequence([
            flyAction,
            SKAction.run(completion),
            SKAction.group([
                SKAction.scale(to: 0.0, duration: 0.15),
                SKAction.fadeOut(withDuration: 0.15)
            ]),
            SKAction.removeFromParent()
        ]))
    }
}
