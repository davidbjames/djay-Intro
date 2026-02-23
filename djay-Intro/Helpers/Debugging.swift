//
//  Debugging.swift
//  djay-Intro
//
//  Created by David James on 17/02/2026.
//

import UIKit

// this is only here for debugging purposes (the swizzle has no other effect)

extension UIView {
    
    static let swizzleDidMoveToSuperview: Void = {
        let originalSelector = #selector(UIView.didMoveToSuperview)
        let swizzledSelector = #selector(UIView.swizzled_didMoveToSuperview)
        
        guard
            let originalMethod = class_getInstanceMethod(UIView.self, originalSelector),
            let swizzledMethod = class_getInstanceMethod(UIView.self, swizzledSelector)
        else {
            return
        }
        method_exchangeImplementations(originalMethod, swizzledMethod)
    }()
    
    @objc func swizzled_didMoveToSuperview() {
        // call the original implementation of didMoveToSuperview
        self.swizzled_didMoveToSuperview()
        
#if DEBUG
        // adds a thin line around all views for debugging layout
        self.layer.borderColor = UIColor.green.cgColor
        self.layer.borderWidth = 1.0
#endif
    }
}
