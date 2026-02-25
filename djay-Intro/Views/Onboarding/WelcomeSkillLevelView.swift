//
//  WelcomeSkillLevelView.swift
//  djay-Intro
//
//  Created by David James on 16/02/2026.
//

import UIKit
import Combine

/// The third onboarding step view.
final class WelcomeSkillLevelView: WelcomeBaseView, SnapshotTestable {
    
    private var stackView: UIStackView!
    private var headerStack: UIStackView!
    private var smiley: UIImageView!
    private var introWords: UILabel!
    
    private var selectionButtons: [UIButton] = []
    
    override func setupUI(prompt: String) {
        
        super.setupUI(prompt: "Let’s go")
        
        // disabled until user selects their level
        proceedButton.isEnabled = false
        
        guard
            let smileyImage = UIImage(named: "HeadphoneSmiley")
        else {
            assertionFailure("Art missing")
            return
        }
        
        // Main stack
        
        stackView = UIStackView()
        stackView.axis = .vertical
        stackView.alignment = .center
        stackView.translatesAutoresizingMaskIntoConstraints = false
        container.addSubview(stackView)
        portraitConstraints += [
            stackView.leadingAnchor.constraint(equalTo: container.safeAreaLayoutGuide.leadingAnchor),
            stackView.trailingAnchor.constraint(equalTo: container.safeAreaLayoutGuide.trailingAnchor),
            stackView.centerYAnchor.constraint(equalTo: container.centerYAnchor, constant: 10.0),
        ]
        landscapeConstraints += [
            stackView.leadingAnchor.constraint(equalTo: container.safeAreaLayoutGuide.leadingAnchor, constant: 16.0),
            stackView.trailingAnchor.constraint(equalTo: container.safeAreaLayoutGuide.trailingAnchor, constant: -16.0),
            stackView.centerYAnchor.constraint(equalTo: container.centerYAnchor),
        ]
        
        headerStack = UIStackView()
        headerStack.axis = .vertical
        headerStack.alignment = .center
        headerStack.translatesAutoresizingMaskIntoConstraints = false
        stackView.addArrangedSubview(headerStack)
        
        // 1. Icon
        
        smiley = UIImageView(image: smileyImage)
        smiley.setContentCompressionResistancePriority(.required, for: .horizontal)
        headerStack.addArrangedSubview(smiley)
        
        // 2. Intro text
        
        let introStack = UIStackView()
        introStack.axis = .vertical
        introStack.alignment = .center
        introStack.distribution = .fillEqually
        introStack.translatesAutoresizingMaskIntoConstraints = false
        headerStack.addArrangedSubview(introStack)
        
        let introTitle = UILabel()
        introTitle.text = "Welcome DJ"
        if let boldDescriptor = UIFontDescriptor.preferredFontDescriptor(withTextStyle: .largeTitle).withSymbolicTraits(.traitBold) {
            introTitle.font = UIFont(descriptor: boldDescriptor, size: 0)
        } else {
            introTitle.font = .preferredFont(forTextStyle: .largeTitle)
        }
        introTitle.textColor = .white
        introStack.addArrangedSubview(introTitle)
        introWords = UILabel()
        introWords.text = "What’s your DJ skill level?"
        introWords.textAlignment = .center
        introWords.font = .preferredFont(forTextStyle: .title2)
        introWords.textColor = .systemGray
        introStack.addArrangedSubview(introWords)
        
        // 3. Form
        
        let formStack = UIStackView()
        formStack.axis = .vertical
        formStack.alignment = .leading
        formStack.spacing = StyleConstant.verticalSpacingSmall
        formStack.distribution = .equalSpacing
        formStack.translatesAutoresizingMaskIntoConstraints = false
        stackView.addArrangedSubview(formStack)
        formStack.widthAnchor.constraint(equalTo: proceedButton.widthAnchor).isActive = true

        for buttonTitle in [
            "I’m new to DJing",
            "I’ve used DJ apps before",
            "I’m a professional DJ"
        ] {
            let skillLevelButton = UIButton()
            skillLevelButton.translatesAutoresizingMaskIntoConstraints = false
            skillLevelButton.contentHorizontalAlignment = .leading
            skillLevelButton.addAction(.init { [weak self] action in
                guard let self, let tappedButton = action.sender as? UIButton else {
                    return
                }
                // update button selection
                for (index, button) in selectionButtons.enumerated() {
                    if button === tappedButton {
                        button.isSelected.toggle()
                        var state = onboardingState.value
                        if button.isSelected {
                            state.model.skillLevel = .init(rawValue: index)
                            proceedButton.isEnabled = true
                        } else {
                            state.model.skillLevel = nil
                            proceedButton.isEnabled = false
                        }
                        // save the user's preference
                        onboardingState.send(state)
                    } else {
                        button.isSelected = false
                    }
                }
            }, for: .touchUpInside)
            // update style for selected state
            skillLevelButton.configurationUpdateHandler = { button in
                var config = UIButton.Configuration.gray()
                config.cornerStyle = .large
                config.imagePadding = StyleConstant.horizontalSpacing
                config.imagePlacement = .leading
                config.titleAlignment = .leading
                config.contentInsets = NSDirectionalEdgeInsets(
                    top: StyleConstant.verticalSpacingSmall,
                    leading: StyleConstant.horizontalSpacing,
                    bottom: StyleConstant.verticalSpacingSmall,
                    trailing: StyleConstant.horizontalSpacing
                )
                config.attributedTitle = AttributedString(
                    buttonTitle,
                    attributes: AttributeContainer([
                        .font: UIFont.preferredFont(forTextStyle: .body),
                        .foregroundColor: UIColor.white
                    ])
                )
                if button.isSelected {
                    let colorConfig = UIImage.SymbolConfiguration(paletteColors: [.white, .systemBlue])
                    let boldConfig = UIImage.SymbolConfiguration(weight: .bold)
                    let combinedConfig = colorConfig.applying(boldConfig)
                    config.image = UIImage(systemName: "checkmark.circle.fill", withConfiguration: combinedConfig)
                    config.background.strokeColor = .systemBlue
                    config.background.strokeWidth = 2.0
                } else {
                    config.image = UIImage(systemName: "circle")?.withTintColor(.systemGray, renderingMode: .alwaysOriginal)
                    config.background.strokeColor = .clear
                    config.background.strokeWidth = 0.0
                }
                // maintain the grey background
                config.background.backgroundColor = .white.withAlphaComponent(0.1)
                // note: config.baseBackgroundColor does not provide equivalent behaviour
                // you must change the configuration's background
                
                button.configuration = config
            }
            formStack.addArrangedSubview(skillLevelButton)
            NSLayoutConstraint.activate([
                skillLevelButton.heightAnchor.constraint(equalToConstant: StyleConstant.buttonHeightLarge * 1.1),
                skillLevelButton.widthAnchor.constraint(equalTo: proceedButton.widthAnchor)
            ])

            selectionButtons.append(skillLevelButton)
        }
        
        setupPreTransitionState()
        
        updateViewForTraits()
    }
    
    override func updateOnboarding() {
        super.updateOnboarding()
    }
    
    override func updateViewForTraits() {
        
        super.updateViewForTraits()
        
        if isCompactVerticalSize {
            stackView.axis = .horizontal
            stackView.spacing = StyleConstant.horizontalSpacing
            headerStack.spacing = StyleConstant.verticalSpacingSmall
            introWords.numberOfLines = 0
        } else {
            stackView.axis = .vertical
            stackView.spacing = StyleConstant.verticalSpacingLarge
            headerStack.spacing = StyleConstant.verticalSpacing
            introWords.numberOfLines = 1
        }
    }
}

