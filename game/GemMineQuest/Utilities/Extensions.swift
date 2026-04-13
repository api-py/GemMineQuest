import SpriteKit
import SwiftUI

// MARK: - CGPoint Arithmetic

extension CGPoint {
    static func + (lhs: CGPoint, rhs: CGPoint) -> CGPoint {
        CGPoint(x: lhs.x + rhs.x, y: lhs.y + rhs.y)
    }

    static func - (lhs: CGPoint, rhs: CGPoint) -> CGPoint {
        CGPoint(x: lhs.x - rhs.x, y: lhs.y - rhs.y)
    }

    static func * (point: CGPoint, scalar: CGFloat) -> CGPoint {
        CGPoint(x: point.x * scalar, y: point.y * scalar)
    }

    func length() -> CGFloat {
        sqrt(x * x + y * y)
    }

    func normalized() -> CGPoint {
        let len = length()
        guard len > 0 else { return .zero }
        return CGPoint(x: x / len, y: y / len)
    }
}

// MARK: - Array Safe Subscript

extension Array {
    subscript(safe index: Int) -> Element? {
        indices.contains(index) ? self[index] : nil
    }
}

// MARK: - SKColor Hex Init

extension SKColor {
    convenience init(hex: UInt32, alpha: CGFloat = 1.0) {
        let r = CGFloat((hex >> 16) & 0xFF) / 255.0
        let g = CGFloat((hex >> 8) & 0xFF) / 255.0
        let b = CGFloat(hex & 0xFF) / 255.0
        self.init(red: r, green: g, blue: b, alpha: alpha)
    }
}

// MARK: - SwiftUI Color Hex Init

extension Color {
    init(hex: UInt32) {
        let r = Double((hex >> 16) & 0xFF) / 255.0
        let g = Double((hex >> 8) & 0xFF) / 255.0
        let b = Double(hex & 0xFF) / 255.0
        self.init(red: r, green: g, blue: b)
    }
}

// MARK: - SKAction Helpers

extension SKAction {
    static func bounceIn(duration: TimeInterval = 0.3) -> SKAction {
        let scaleUp = SKAction.scale(to: 1.1, duration: duration * 0.6)
        scaleUp.timingMode = .easeOut
        let scaleDown = SKAction.scale(to: 1.0, duration: duration * 0.4)
        scaleDown.timingMode = .easeIn
        return SKAction.sequence([scaleUp, scaleDown])
    }

    static func popIn(duration: TimeInterval = 0.3) -> SKAction {
        let appear = SKAction.group([
            SKAction.sequence([
                SKAction.scale(to: 0.0, duration: 0),
                SKAction.scale(to: 1.0, duration: duration)
            ]),
            SKAction.fadeIn(withDuration: duration)
        ])
        appear.timingMode = .easeOut
        return appear
    }

    static func shrinkAndFade(duration: TimeInterval = 0.3) -> SKAction {
        let disappear = SKAction.group([
            SKAction.scale(to: 0.0, duration: duration),
            SKAction.fadeOut(withDuration: duration)
        ])
        disappear.timingMode = .easeIn
        return disappear
    }

    static func floatUp(distance: CGFloat = 40, duration: TimeInterval = 0.8) -> SKAction {
        SKAction.group([
            SKAction.moveBy(x: 0, y: distance, duration: duration),
            SKAction.sequence([
                SKAction.fadeIn(withDuration: duration * 0.2),
                SKAction.wait(forDuration: duration * 0.4),
                SKAction.fadeOut(withDuration: duration * 0.4)
            ])
        ])
    }

    static func moveWithEase(to point: CGPoint, duration: TimeInterval) -> SKAction {
        let action = SKAction.move(to: point, duration: duration)
        action.timingMode = .easeInEaseOut
        return action
    }

    static func fallWithBounce(to point: CGPoint, duration: TimeInterval) -> SKAction {
        let fall = SKAction.move(to: point, duration: duration)
        fall.timingMode = .easeIn
        let bounceDown = SKAction.moveBy(x: 0, y: -3, duration: 0.05)
        let bounceUp = SKAction.moveBy(x: 0, y: 3, duration: 0.05)
        return SKAction.sequence([fall, bounceDown, bounceUp])
    }
}

// MARK: - Seeded Random Number Generator

struct SeededRandomNumberGenerator: RandomNumberGenerator {
    private var state: UInt64

    init(seed: UInt64) {
        self.state = seed
    }

    mutating func next() -> UInt64 {
        // xorshift64
        state ^= state << 13
        state ^= state >> 7
        state ^= state << 17
        return state
    }
}
