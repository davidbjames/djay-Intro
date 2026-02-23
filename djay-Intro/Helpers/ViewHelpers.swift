//
//  ViewHelpers.swift
//  djay-Intro
//
//  Created by David James on 22/02/2026.
//

import UIKit

extension UIView {
    
    /// Is this view being used on a very small screen size?
    ///
    /// Caution: this method may not work correctly with iPad split
    /// screen or slide over. Since this exercise is iPhone-only then
    /// we use this to have more precise control of layouts on small screens.
    var isVerySmallScreen: Bool {
        window.map { max($0.bounds.size.width, $0.bounds.size.height) < 600 } ?? false
    }
    
    /// Is this view "compact" vertically?
    ///
    /// This can be used to presume landscape orientation on iPhone,
    /// but should not be relied on for the same purpose on iPad.
    var isCompactVerticalSize: Bool {
        traitCollection.verticalSizeClass == .compact
    }
}
