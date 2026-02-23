//
//  ViewController.swift
//  djay-Intro
//
//  Created by David James on 16/02/2026.
//

import UIKit

/// Main view controller. App enters here.
class ViewController: UIViewController {

    override func viewDidLoad() {
        super.viewDidLoad()
        
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
        Onboarding.load()?.hasCompletedOnboarding != true
    }
    private func loadOnboardingFlow() {
        let onboardingViewController = OnboardingViewController(
            onboarding: Onboarding.load() ?? .init()
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

