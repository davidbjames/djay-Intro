//
//  OnboardingPagingViewController.swift
//  djay-Intro
//
//  Created by David James on 22/02/2026.
//

import UIKit

// Note: page navigation is programmatic using a button, so we do not need to conform
// to UIPageViewControllerDatasource or UIPageViewControllerDelegate.
// As a result of this, we must provide our own UIPageControl for the dots at the bottom.

/// Manages pagination of the onboarding flow
final class OnboardingPagingViewController: UIPageViewController, SnapshotTestable {
    
    var viewControllerCache: [OnboardingStepViewController] = []
    
    var currentStepViewController: OnboardingStepViewController? {
        viewControllers?.first as? OnboardingStepViewController
    }
    
    init(startViewController: OnboardingStepViewController) {
        super.init(
            transitionStyle: .scroll,
            navigationOrientation: .horizontal,
            options: nil
        )
        setViewControllers(
            [startViewController],
            direction: .forward,
            animated: false
        )
        viewControllerCache.append(startViewController)
    }
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    /// Given a next onboarding step, push a new view controller if needed,
    /// or update the existing one if the step is shared with the previous step
    func pushNextOnboardingStep(_ step: OnboardingStep) {
        guard let currentStepViewController else {
            return
        }
        let isShared = step.isSharedWithPrevious
        guard !isShared else {
            // E.g. welcome and overview are the same VC even though they represent a different step
            currentStepViewController.updateOnboarding()
            return
        }
        let isBefore = step.isBefore(other: currentStepViewController.step)
        let usesPageAnimation = step.usesPageAnimation
        let direction: UIPageViewController.NavigationDirection = isBefore ? .reverse : .forward
        let nextStepViewController: OnboardingStepViewController
        if isBefore {
            guard
                let existingIndex = viewControllerCache.firstIndex(of: currentStepViewController),
                viewControllerCache.indices.contains(existingIndex - 1)
            else {
                assertionFailure("Attempt to move backward without existing cached onboarding view controller.")
                return
            }
            nextStepViewController = viewControllerCache[existingIndex - 1]
        } else {
            if
                let existingIndex = viewControllerCache.firstIndex(of: currentStepViewController),
                viewControllerCache.indices.contains(existingIndex + 1)
            {
                nextStepViewController = viewControllerCache[existingIndex + 1]
            } else {
                nextStepViewController = .init(state: currentStepViewController.onboardingState)
                viewControllerCache.append(nextStepViewController)
            }
        }
        setViewControllers(
            [nextStepViewController],
            direction: direction,
            animated: usesPageAnimation
        )
        nextStepViewController.updateOnboarding()
    }
    
    func setupPreTransitionState() -> Bool {
        currentStepViewController?.setupPreTransitionState() ?? false
    }
    
    func setupVisibleState() -> Bool {
        currentStepViewController?.setupVisibleState() ?? false
    }
    
    func setupPostTransitionState() -> Bool {
        currentStepViewController?.setupPostTransitionState() ?? false 
    }
}
