//
//  AppGradientView.swift
//  djay-Intro
//
//  Created by David James on 16/02/2026.
//

import UIKit

/// Used for a background gradient
final class AppGradientView: UIView {
    
    override class var layerClass: AnyClass {
        // this view is "painted" with a gradient layer
        GradientLayer.self
    }
}

/// Used for a background gradient
private final class GradientLayer: CAGradientLayer {
    
    override init() {
        super.init()
        // TODO: check with design for exact gradient colors and locations - David
        // Also, verify we have a matching LaunchScreen gradient "strip" so that
        // app launch will transition nicely (I put a best guess image on launch for this).
        self.colors = [
            CGColor(gray: 0.0, alpha: 1.0),
            CGColor(red: 0.1, green: 0.1, blue: 0.16, alpha: 1.0),
            CGColor(red: 0.2, green: 0.2, blue: 0.31, alpha: 1.0),
            CGColor(red: 0.29, green: 0.29, blue: 0.43, alpha: 1.0)
        ]
        self.locations = [
            NSNumber(0.0),
            NSNumber(0.33),
            NSNumber(0.67),
            NSNumber(1.0)
        ]
        self.startPoint = CGPoint(x: 0.5, y: 0.0)
        self.endPoint = CGPoint(x: 0.5, y: 1.0)
        self.type = .axial
    }
    override init(layer: Any) {
        super.init(layer: layer)
    }
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    override func action(forKey event: String) -> (any CAAction)? {
        guard
            event == "colors",
            // grab the previous colors from presentation
            // and animate from that to the new colors
            let previousColors = presentation()?.value(forKey: event)
        else {
            return super.action(forKey: event)
        }
        // handle any color animations here
        // we used this for the transition to the finale screen
        let animation = CABasicAnimation(keyPath: event)
        animation.fromValue = previousColors
        animation.duration = 4.0
        return animation
    }
    func applyGradientColorVariant() {
        colors = [
            CGColor(gray: 0.0, alpha: 1.0),
            CGColor(red: 0.3, green: 0.13, blue: 0.0, alpha: 1.0),
            // CGColor(red: 0.4, green: 0.18, blue: 0.04, alpha: 1.0),
            CGColor(red: 0.3, green: 0.13, blue: 0.0, alpha: 1.0),
            // CGColor(red: 0.5, green: 0.22, blue: 0.1, alpha: 1.0)
            CGColor(gray: 0.0, alpha: 1.0),
        ]
    }
}

extension UIView {
    
    /// Apply a standard background gradient
    func applyBackgroundGradient() {
        let gradient = AppGradientView(frame: .zero)
        gradient.translatesAutoresizingMaskIntoConstraints = false
        addSubview(gradient)
        NSLayoutConstraint.activate([
            gradient.topAnchor.constraint(equalTo: topAnchor),
            gradient.bottomAnchor.constraint(equalTo: bottomAnchor),
            gradient.leadingAnchor.constraint(equalTo: leadingAnchor),
            gradient.trailingAnchor.constraint(equalTo: trailingAnchor)
        ])
    }
    
    /// Update to a secondary background gradient
    func applyBackgroundGradientVariant() {
        guard let gradient = (subviews.first(where: { $0 is AppGradientView }) as? AppGradientView)?.layer as? GradientLayer else {
            return
        }
        gradient.applyGradientColorVariant()
    }
}
