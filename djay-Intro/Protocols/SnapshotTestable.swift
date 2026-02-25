//
//  SnapshotTestable.swift
//  djay-Intro
//
//  Created by David James on 25/02/2026.
//

import UIKit

/// To support snapshot testing, views or view controllers
/// should separate their animated states in such a way
/// that tests can check either or both states.
protocol SnapshotTestable {
    
    /// The state of the view _before_ any transitions or animations have occurred.
    ///
    /// Return `true` only if there was a change, as this will be used to
    /// determine if the snapshot test is required.
    @discardableResult
    func setupPreTransitionState() -> Bool
    
    /// The state of the view when items become visible
    ///
    /// Return `true` only if there was a change, as this will be used to
    /// determine if the snapshot test is required.
    @discardableResult
    func setupVisibleState() -> Bool
    
    /// The state of the view _after_ any transitions or animations have occurred
    ///
    /// Return `true` only if there was a change, as this will be used to
    /// determine if the snapshot test is required.
    @discardableResult
    func setupPostTransitionState() -> Bool
}

/// Convenience so that views can declare themselves as `SnapshotTestable`
/// but may not have any transitions for one or all states, so would not
/// require snapshot tests for those state(s).
/// Note: `setupPreTransitionState()` always returns true to indicate
/// that the normal state should always be tested.
extension SnapshotTestable where Self: UIView {
    
    @discardableResult
    func setupPreTransitionState() -> Bool {
        true // always test the initial state
    }
    
    // no transitions
    
    @discardableResult
    func setupVisibleState() -> Bool {
        false
    }
    
    @discardableResult
    func setupPostTransitionState() -> Bool {
        false
    }
}

/// Convenience conformance for view controllers that hold a `SnapshotTestable`
/// view in their view's subviews.
extension SnapshotTestable where Self: UIViewController {
    
    func setupPreTransitionState() -> Bool {
        snapshotTestableView?.setupPreTransitionState() ?? false
    }
    
    func setupVisibleState() -> Bool {
        snapshotTestableView?.setupVisibleState() ?? false
    }
    
    func setupPostTransitionState() -> Bool {
        snapshotTestableView?.setupPostTransitionState() ?? false
    }

    private var snapshotTestableView: (UIView & SnapshotTestable)? {
        view.subviews.first(where: { $0 is SnapshotTestable }) as? (UIView & SnapshotTestable)
    }
}
