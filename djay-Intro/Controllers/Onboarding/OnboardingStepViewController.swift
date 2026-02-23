//
//  OnboardingStepViewController.swift
//  djay-Intro
//
//  Created by David James on 22/02/2026.
//

import UIKit
import Combine

/// Holds each of the onboarding steps / views
final class OnboardingStepViewController: UIViewController, OnboardingStateful {
    
    let onboardingState: CurrentValueSubject<OnboardingState, Never>
    
    var step: OnboardingStep {
        onboardingState.value.step
    }

    init(state: CurrentValueSubject<OnboardingState, Never>) {
        self.onboardingState = state
        super.init(nibName: nil, bundle: nil)
        setupUI()
    }
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    private func setupUI() {
        
        guard let stepView = step.createView(state: onboardingState) else {
            return
        }
        stepView.translatesAutoresizingMaskIntoConstraints = false
        view.addSubview(stepView)
        NSLayoutConstraint.activate([
            stepView.topAnchor.constraint(equalTo: view.topAnchor),
            stepView.bottomAnchor.constraint(equalTo: view.bottomAnchor),
            stepView.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            stepView.trailingAnchor.constraint(equalTo: view.trailingAnchor)
        ])
    }
    
    func updateOnboarding() {
        guard let view = view.subviews.first as? OnboardingStateful else {
            return
        }
        view.updateOnboarding()
    }
    func updateViewForTraits() {
        guard let view = view.subviews.first as? OnboardingStateful else {
            return
        }
        view.updateViewForTraits()
    }
}
