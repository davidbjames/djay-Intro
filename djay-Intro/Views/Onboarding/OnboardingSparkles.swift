//
//  Sparkles.swift
//  djay-Intro
//
//  Created by David James on 22/02/2026.
//

import SpriteKit

/// Thin wrapper to a node that has two emitters that emit
/// some kind of sparkles effect. See the `Sparks.sks` file
/// for the base setup of the sparkles, which are tweaked here
/// as well as additional attached SpriteKit actions.
final class OnboardingSparkles: SKNode {
    override init() {
        super.init()
        setupNode()
    }
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    private func setupNode() {
        addChild(generateSparkles(directionUp: true))
        addChild(generateSparkles(directionUp: false))
    }
    
    private func generateSparkles(directionUp: Bool) -> SKEmitterNode {
        let sparkles = SKEmitterNode(fileNamed: "Sparks.sks")!
        sparkles.emissionAngle = directionUp ? .pi / 2 : 3 * .pi / 2
        sparkles.emissionAngleRange = 0.0
        sparkles.particleColorSequence = .init(
            keyframeValues: [
                StyleConstant.yellowColor.withAlphaComponent(0.5),
                StyleConstant.yellowColor.withAlphaComponent(0.4),
                StyleConstant.yellowColor.withAlphaComponent(0.2),
                // UIColor(red: 1.0, green: 0.63, blue: 0.1, alpha: 1.0), // 0.2
                // UIColor(red: 1.0, green: 0.75, blue: 0.3, alpha: 1.0), // 0.1
                UIColor(white: 1.0, alpha: 0.0)
            ],
            times: [
                0.0,
                0.2,
                0.4,
                1.0
            ]
        )
        // this makes sparkles above the line fly up then
        // fall down with gravity, and sparkles below the line
        // to fly down with additional force of gravity
        sparkles.yAcceleration = -1000.0
        sparkles.name = "sparkles\(directionUp ? "Up" : "Down")"
        return sparkles
    }
    
    /// Start or restart a "pulse" animation.
    ///
    /// Every time the device size changes on orientation change
    /// we need to update the amount of particles and the width,
    /// which is why `size` is passed.
    func pulse(size: CGSize) {
        
        let isLandscape = size.width > size.height
        let lowParticleRate = isLandscape ? 1000.0 : 500.0
        let highParticleRate = lowParticleRate * 4.0
        
        let pulseUp = SKAction.customAction(withDuration: 0.2) { node, elapsedTime in
            guard let emitter = node as? SKEmitterNode else {
                return
            }
            emitter.particlePositionRange = CGVector(dx: size.width, dy: 0.0)
            emitter.particleBirthRate = highParticleRate
        }
        pulseUp.timingMode = .easeOut
        
        let pulseDown = SKAction.customAction(withDuration: 0.2) { node, elapsedTime in
            guard let emitter = node as? SKEmitterNode else {
                return
            }
            emitter.particlePositionRange = CGVector(dx: size.width, dy: 0.0)
            emitter.particleBirthRate = lowParticleRate
        }
        pulseDown.timingMode = .linear
        
        let wait = SKAction.wait(forDuration: 0.0)
        let pulse = SKAction.sequence([pulseUp, pulseDown, wait])
        let repeated = SKAction.repeatForever(pulse)
        
        for emitter in children {
            emitter.removeAction(forKey: "pulse")
            // this runs both custom actions specified above, for each emitter
            emitter.run(repeated, withKey: "pulse")
        }
    }
}
