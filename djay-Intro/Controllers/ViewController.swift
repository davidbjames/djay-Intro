//
//  ViewController.swift
//  djay-Intro
//
//  Created by David James on 16/02/2026.
//

import UIKit

/// Main view controller. App enters here.
class ViewController: UIViewController {
    
    /// `onboardingState` can be set for testing purposes,
    /// but will usually be loaded from disk
    var onboardingState: OnboardingState?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setupUI()
    }

    private func setupUI() {
        
        view.applyBackgroundGradient()
        
        // don't save onboarding state for now
        Onboarding.clear()
        
        if isOnboardingRequired {
            loadOnboardingFlow()
        } else {
            loadMainAppFlow()
        }
    }
    
    private var isOnboardingRequired: Bool {
        if let onboardingState {
            !onboardingState.model.hasCompletedOnboarding
        } else {
            Onboarding.load()?.hasCompletedOnboarding != true
        }
    }
    private func loadOnboardingFlow() {
        let onboardingViewController = OnboardingViewController(
            state: onboardingState ?? .init(
                step: .welcome,
                model: Onboarding.load() ?? .init()
            )
        )
        addChild(onboardingViewController)
        onboardingViewController.didMove(toParent: self)
        view.addSubview(onboardingViewController.view)
        NSLayoutConstraint.activate([
            onboardingViewController.view.topAnchor.constraint(equalTo: view.topAnchor),
            onboardingViewController.view.bottomAnchor.constraint(equalTo: view.bottomAnchor),
            onboardingViewController.view.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            onboardingViewController.view.trailingAnchor.constraint(equalTo: view.trailingAnchor)
        ])
        
        // TODO: handle removing onboarding view controller from hierarchy/memory
    }
    
    private func loadMainAppFlow() {
        
    }
}

