//
//  WelcomeBaseView.swift
//  djay-Intro
//
//  Created by David James on 18/02/2026.
//

import UIKit
import Combine

/// Common view for onboarding pages with the button
/// and a basic container that is above that button.
class WelcomeBaseView: UIView, OnboardingStateful {
    
    let onboardingState: CurrentValueSubject<OnboardingState, Never>
    
    // Note: onboarding views manage two sets of constraints, one for portrait and one for landscape
    var portraitConstraints: [NSLayoutConstraint] = []
    var landscapeConstraints: [NSLayoutConstraint] = []
    
    var proceedButton: UIButton!
    var container: UIView!

    init(onboardingState: CurrentValueSubject<OnboardingState, Never>) {
        self.onboardingState = onboardingState
        super.init(frame: .zero)
        setupUI(prompt: "") // subclasses to specify
    }
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    func setupUI(prompt: String) {
        
        // Common elements
        
        // Button
        
        proceedButton = UIButton(primaryAction: .init { [weak self] action in
            guard let self, let nextState = onboardingState.value.nextStep() else {
                return
            }
            onboardingState.send(nextState)
        })
        proceedButton.translatesAutoresizingMaskIntoConstraints = false
        proceedButton.configurationUpdateHandler = { button in
            var config = UIButton.Configuration.borderedProminent()
            config.cornerStyle = .large
            config.attributedTitle = AttributedString(
                prompt,
                attributes: AttributeContainer([
                    .font: UIFont.systemFont(ofSize: StyleConstant.buttonFontSizeLarge, weight: .semibold),
                    .foregroundColor: UIColor.white
                ])
            )
            config.background.backgroundColor = .systemBlue
            button.alpha = button.isEnabled ? 1.0 : 0.3
            button.configuration = config
        }
        
        portraitConstraints += [
            // Stretch button to fit on portrait
            proceedButton.leadingAnchor.constraint(equalTo: leadingAnchor, constant: StyleConstant.horizontalMargins),
            proceedButton.trailingAnchor.constraint(equalTo: trailingAnchor, constant: -StyleConstant.horizontalMargins)
        ]
        landscapeConstraints += [
            // Center button with fixed width on landscape
            proceedButton.centerXAnchor.constraint(equalTo: centerXAnchor),
            proceedButton.widthAnchor.constraint(equalToConstant: 300)
        ]
        addSubview(proceedButton)
        NSLayoutConstraint.activate([
            proceedButton.heightAnchor.constraint(equalToConstant: StyleConstant.buttonHeightLarge),
            proceedButton.bottomAnchor.constraint(equalTo: safeAreaLayoutGuide.bottomAnchor)
        ])
        
        // Content container (above button)
        
        container = UIView()
        container.translatesAutoresizingMaskIntoConstraints = false
        container.clipsToBounds = true
        // container.backgroundColor = .green.withAlphaComponent(0.3)
        addSubview(container)
        NSLayoutConstraint.activate([
            container.topAnchor.constraint(equalTo: topAnchor),
            container.bottomAnchor.constraint(equalTo: proceedButton.topAnchor),
            container.leadingAnchor.constraint(equalTo: leadingAnchor),
            container.trailingAnchor.constraint(equalTo: trailingAnchor)
        ])
    }
    
    func updateOnboarding() {
        updateViewForTraits()
    }
    
    func updateViewForTraits() {
        
        // update constraints
        if isCompactVerticalSize {
            // Landscape
            NSLayoutConstraint.deactivate(portraitConstraints)
            NSLayoutConstraint.activate(landscapeConstraints)
        } else {
            // Portrait
            NSLayoutConstraint.deactivate(landscapeConstraints)
            NSLayoutConstraint.activate(portraitConstraints)
        }
    }
    
    override func traitCollectionDidChange(_ previousTraitCollection: UITraitCollection?) {
        super.traitCollectionDidChange(previousTraitCollection)
        guard traitCollection.verticalSizeClass != previousTraitCollection?.verticalSizeClass else {
            return
        }
        updateViewForTraits()
    }
}
