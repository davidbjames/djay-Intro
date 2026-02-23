//
//  WelcomeView.swift
//  djay-Intro
//
//  Created by David James on 16/02/2026.
//

import UIKit
import Combine

/// The first two steps of onboarding.
///
/// This onboarding step view has two states corresponding
/// to the `OnboardingStep` states of `welcome` and `overview`.
/// They are combined in one view to support transition animation.
/// (other step views are separated using page transitions)
final class WelcomeView: WelcomeBaseView {
    
    private var introWords: UILabel!
    private var stackView: UIStackView!
    private var wordmark: UIImageView!
    private var heroPic: UIImageView!
    private var welcomeText: UILabel!
    private var ada: UIImageView!
    
    private var introWordsBottomConstraint: NSLayoutConstraint!
    
    override func setupUI(prompt: String) {
        
        super.setupUI(prompt: "Continue")
        
        guard
            let wordmarkImage = UIImage(named: "djay"),
            let heroImage = UIImage(named: "Hero"),
            let adaImage = UIImage(named: "ADA")
        else {
            assertionFailure("Art missing")
            return
        }
        
        // Intro words
        
        introWords = UILabel()
        introWords.text = "Welcome to djay!"
        introWords.font = .preferredFont(forTextStyle: .title2)
        introWords.textColor = .white
        introWords.translatesAutoresizingMaskIntoConstraints = false
        container.addSubview(introWords)
        introWordsBottomConstraint = introWords.bottomAnchor.constraint(equalTo: container.bottomAnchor, constant: -StyleConstant.verticalSpacing)
        NSLayoutConstraint.activate([
            introWords.centerXAnchor.constraint(equalTo: container.centerXAnchor),
            introWordsBottomConstraint
        ])

        // Content stack
        
        stackView = UIStackView()
        stackView.axis = .vertical
        stackView.alignment = .center
        stackView.spacing = StyleConstant.verticalSpacing
        stackView.distribution = .equalSpacing // important
        stackView.translatesAutoresizingMaskIntoConstraints = false
        // stackView.backgroundColor = .yellow.withAlphaComponent(0.3)
        container.addSubview(stackView)
        portraitConstraints += [
            stackView.leadingAnchor.constraint(equalTo: container.safeAreaLayoutGuide.leadingAnchor),
            stackView.trailingAnchor.constraint(equalTo: container.safeAreaLayoutGuide.trailingAnchor),
            stackView.centerYAnchor.constraint(equalTo: container.centerYAnchor, constant: 35.0),
        ]
        landscapeConstraints += [
            stackView.leadingAnchor.constraint(equalTo: container.safeAreaLayoutGuide.leadingAnchor, constant: 16.0),
            stackView.trailingAnchor.constraint(equalTo: container.safeAreaLayoutGuide.trailingAnchor, constant: -16.0),
            stackView.centerYAnchor.constraint(equalTo: container.centerYAnchor),
        ]
        
        // Images
        
        wordmark = UIImageView(image: wordmarkImage)
        // keep images from getting squashed in landscape orientation
        wordmark.setContentCompressionResistancePriority(.required, for: .horizontal)
        stackView.addArrangedSubview(wordmark)
        
        // these pics are hidden and scaled down to begin with
        
        heroPic = UIImageView(
            // inset to compensate for large drop shadow so that everything looks balanced
            image: heroImage.withAlignmentRectInsets(.init(top: 10.0, left: 0.0, bottom: 30.0, right: 0.0))
        )
        heroPic.transform = .init(scaleX: 0.0, y: 0.0)
        heroPic.isHidden = true
        heroPic.alpha = 0.0
        heroPic.setContentCompressionResistancePriority(.required, for: .horizontal)
        stackView.addArrangedSubview(heroPic)
        
        welcomeText = UILabel()
        welcomeText.text = "Mix Your\nFavorite Music"
        if let boldDescriptor = UIFontDescriptor.preferredFontDescriptor(withTextStyle: .largeTitle).withSymbolicTraits(.traitBold) {
            welcomeText.font = UIFont(descriptor: boldDescriptor, size: 0)
        } else {
            welcomeText.font = .preferredFont(forTextStyle: .largeTitle)
        }
        welcomeText.textColor = .white
        welcomeText.textAlignment = .center
        welcomeText.numberOfLines = 0
        welcomeText.transform = .init(scaleX: 0.0, y: 0.0)
        welcomeText.isHidden = true
        welcomeText.alpha = 0.0
        stackView.addArrangedSubview(welcomeText)

        ada = UIImageView(image: adaImage)
        ada.transform = .init(scaleX: 0.0, y: 0.0)
        ada.isHidden = true
        ada.alpha = 0.0
        ada.setContentCompressionResistancePriority(.required, for: .horizontal)
        stackView.addArrangedSubview(ada)
        
        // Update constraints for current orientation (call this last)
        
        updateViewForTraits()
    }
    
    private var didLayoutSubviews = false
    override func layoutSubviews() {
        super.layoutSubviews()
        guard !didLayoutSubviews else {
            return
        }
        if isCompactVerticalSize {
            // landscape - allow text to flow
            welcomeText.text = "Mix Your Favorite Music"
        } else {
            // portrait - match design with line break
            welcomeText.text = "Mix Your\nFavorite Music"
        }
        didLayoutSubviews = true
    }
    
    override func updateOnboarding() {
        
        super.updateOnboarding()
        
        switch onboardingStep {
        case .welcome:
            break
        case .overview:
            heroPic.isHidden = false
            welcomeText.isHidden = false
            // for this exercise I hide the ADA in landscape..
            ada.isHidden = isCompactVerticalSize || isVerySmallScreen
            UIView.animate(withDuration: 0.35, delay: 0.0, options: .curveEaseOut) { [weak self] in
                guard let self else {
                    return
                }
                // bring in the images
                heroPic.transform = .identity
                heroPic.alpha = 1.0
                welcomeText.transform = .identity
                welcomeText.alpha = 1.0
                ada.transform = .identity
                ada.alpha = 1.0
                // hide the intro words
                introWordsBottomConstraint.constant = 50
                layoutIfNeeded() // needed for the constraint change
            } completion: { [weak self] finished in
                if let self, finished {
                    introWords.isHidden = true
                }
            }
        default:
            break
        }
    }
    
    override func updateViewForTraits() {
        
        super.updateViewForTraits()
        
        if isCompactVerticalSize {
            ada.isHidden = true
            ada.alpha = 0.0
            if isVerySmallScreen && onboardingStep == .overview {
                wordmark.isHidden = true
                wordmark.alpha = 0.0
            }
            welcomeText.text = "Mix Your Favorite Music"
            stackView.spacing = StyleConstant.horizontalSpacing
            if onboardingStep == .welcome {
                stackView.axis = .vertical
            } else {
                stackView.axis = .horizontal
            }
        } else {
            if isVerySmallScreen && onboardingStep == .overview {
                ada.isHidden = true
                ada.alpha = 0.0
                wordmark.isHidden = false
                wordmark.alpha = 1.0
                stackView.spacing = StyleConstant.verticalSpacingSmall
            } else {
                if onboardingStep == .welcome {
                    ada.isHidden = true
                } else {
                    ada.isHidden = false
                    ada.alpha = 1.0
                }
                stackView.spacing = StyleConstant.verticalSpacing
            }
            welcomeText.text = "Mix Your\nFavorite Music"
            stackView.axis = .vertical
        }
    }
}

