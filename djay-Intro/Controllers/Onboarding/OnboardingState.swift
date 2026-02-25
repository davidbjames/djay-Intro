//
//  OnboardingState.swift
//  djay-Intro
//
//  Created by David James on 17/02/2026.
//

import UIKit
import Combine

// State used to manage onboarding
// See also Onboarding model which is stored in UserDefaults

protocol OnboardingStateful {
    var onboardingState: CurrentValueSubject<OnboardingState, Never> { get }
    func updateOnboarding()
    func updateViewForTraits()
}

extension OnboardingStateful {
    var onboardingStep: OnboardingStep {
        onboardingState.value.step
    }
}

enum OnboardingStep: Int, CaseIterable {
    
    case welcome, overview, skillLevel, completion
    
    func createView(state: CurrentValueSubject<OnboardingState, Never>) -> (UIView & OnboardingStateful)? {
        switch self {
        case .welcome: WelcomeView(onboardingState: state)
        case .overview: isTestingEnvironment() ? WelcomeView(onboardingState: state) : nil
        case .skillLevel: WelcomeSkillLevelView(onboardingState: state)
        case .completion: WelcomeCompletionView(onboardingState: state)
        }
    }
    func isBefore(other: Self) -> Bool {
        switch self {
        case .welcome: false
        case .overview: other == .welcome
        case .skillLevel: other == .overview
        case .completion: other == .skillLevel
        }
    }
    var usesPageAnimation: Bool {
        switch self {
        case .welcome, .overview: false
        case .skillLevel, .completion: true
        }
    }
    var isSharedWithPrevious: Bool {
        switch self {
        // overview is a separate step, but it shares the same
        // view in order to support non-paging animation
        case .overview: true
        default: false
        }
    }
    var nextStep: Self? {
        switch self {
        case .welcome: .overview
        case .overview: .skillLevel
        case .skillLevel: .completion
        case .completion: nil
        }
    }
}

/// Used with publishers to communicate current state,
/// a combination of the current step, and any other
/// data gathered during the onboarding.
struct OnboardingState {
    var step: OnboardingStep
    var model: Onboarding
    
    /// Move to the next onboarding step with optional model
    func nextStep(with model: Onboarding? = nil) -> Self? {
        guard let nextStep = step.nextStep else {
            return nil
        }
        var _model = model ?? self.model
        if nextStep == .completion {
            _model.hasCompletedOnboarding = true
        }
        return .init(step: nextStep, model: _model)
    }
}
