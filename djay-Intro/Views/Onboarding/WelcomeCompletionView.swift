//
//  WelcomeCongratsView.swift
//  djay-Intro
//
//  Created by David James on 16/02/2026.
//

import UIKit
import Combine
import SpriteKit

/// The fourth and final step of onboarding
final class WelcomeCompletionView: UIView, OnboardingStateful {
    
    let onboardingState: CurrentValueSubject<OnboardingState, Never>
    
    private var portraitConstraints: [NSLayoutConstraint] = []
    private var landscapeConstraints: [NSLayoutConstraint] = []
    // guide ensures text and logo remain vertically centered in landscape
    private var landscapeCenterGuide = UILayoutGuide()
    
    // for the animated views
    private var animatedPortraitConstraints: [NSLayoutConstraint] = []
    private var animatedLandscapeConstraints: [NSLayoutConstraint] = []
    
    // above or left of center
    private var introContainer: UIView!
    private var introStack: UIStackView!
    
    // below or right of center
    private var upgradeContainer: UIView!
    private var upgradeStack: UIStackView!
    
    // centered logo
    private var logo: UIImageView!
    private var wordmarkPro: UIImageView!
    
    private var continueButton: UIButton!
    
    // close, restore, continue, terms, privacy
    // are faded in after a period of time
    private var chromeElements: [UIView] = []
    
    private var textElements: [UILabel] = []
    private var ctaText: UILabel!
    
    // SpriteKit stuff
    private var backgroundView: SKView!
    private var scene: SKScene!
    private var sparkles: OnboardingSparkles! 
    private var glowEffect: SKEffectNode!
    private var horizonLine: SKShapeNode!

    init(onboardingState: CurrentValueSubject<OnboardingState, Never>) {
        self.onboardingState = onboardingState
        super.init(frame: .zero)
        setupUI()
    }
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    func setupUI() {
        
        // setup SpriteKit nodes first as they will be below the rest of the views
        setupNodes()
                
        // there are two equal size containers for content above/below
        // or left/right of center where the sparkle effect emenates from
        
        introContainer = UIView()
        introContainer.clipsToBounds = true
        introContainer.translatesAutoresizingMaskIntoConstraints = false
        addSubview(introContainer)
        
        // (layout guide used to tweak intro stack alignment in landscape)
        introContainer.addLayoutGuide(landscapeCenterGuide)
        
        upgradeContainer = UIView()
        upgradeContainer.clipsToBounds = true
        upgradeContainer.translatesAutoresizingMaskIntoConstraints = false
        addSubview(upgradeContainer)
        
        portraitConstraints += [
            introContainer.topAnchor.constraint(equalTo: safeAreaLayoutGuide.topAnchor),
            introContainer.bottomAnchor.constraint(equalTo: centerYAnchor),
            introContainer.leadingAnchor.constraint(equalTo: leadingAnchor),
            introContainer.trailingAnchor.constraint(equalTo: trailingAnchor),
            
            upgradeContainer.topAnchor.constraint(equalTo: centerYAnchor),
            upgradeContainer.bottomAnchor.constraint(equalTo: safeAreaLayoutGuide.bottomAnchor),
            upgradeContainer.leadingAnchor.constraint(equalTo: leadingAnchor),
            upgradeContainer.trailingAnchor.constraint(equalTo: trailingAnchor),
        ]
        landscapeConstraints += [
            introContainer.topAnchor.constraint(equalTo: topAnchor),
            introContainer.bottomAnchor.constraint(equalTo: bottomAnchor),
            introContainer.leadingAnchor.constraint(equalTo: safeAreaLayoutGuide.leadingAnchor),
            introContainer.trailingAnchor.constraint(equalTo: centerXAnchor),
            
            upgradeContainer.topAnchor.constraint(equalTo: topAnchor),
            upgradeContainer.bottomAnchor.constraint(equalTo: bottomAnchor),
            upgradeContainer.leadingAnchor.constraint(equalTo: centerXAnchor),
            upgradeContainer.trailingAnchor.constraint(equalTo: safeAreaLayoutGuide.trailingAnchor),
            
            landscapeCenterGuide.centerYAnchor.constraint(equalTo: introContainer.centerYAnchor),
            landscapeCenterGuide.leadingAnchor.constraint(equalTo: introContainer.leadingAnchor),
            landscapeCenterGuide.trailingAnchor.constraint(equalTo: introContainer.trailingAnchor),
        ]
        
        // Top (or left) content
        
        introStack = UIStackView()
        introStack.axis = .vertical
        introStack.alignment = .center
        introStack.spacing = StyleConstant.verticalSpacingSmall
        introStack.distribution = .fill
        introStack.translatesAutoresizingMaskIntoConstraints = false
        
        //firstStack.backgroundColor = .yellow.withAlphaComponent(0.3)
        introContainer.addSubview(introStack)

        // Note: "animated" constraints support autolayout-based animation of
        // the content areas in both portrait and landscape. See showPortraitContent()
        // and showLandscape() content below which update the constraints to bring
        // the content into view (animation in layoutSubviews()).
        // This is kept up-to-date on orientation changes in updateViewForTraits(),
        // including seamless animating if the user quickly changes orientation mid-flight.
        animatedPortraitConstraints += [
            introStack.leadingAnchor.constraint(equalTo: introContainer.safeAreaLayoutGuide.leadingAnchor, constant: StyleConstant.horizontalMargins),
            introStack.trailingAnchor.constraint(equalTo: introContainer.safeAreaLayoutGuide.trailingAnchor, constant: -StyleConstant.horizontalMargins),
            introStack.topAnchor.constraint(equalTo: introContainer.bottomAnchor, constant: 20.0), // start below container
        ]
        animatedLandscapeConstraints += [
            introStack.leadingAnchor.constraint(equalTo: introContainer.trailingAnchor, constant: 20.0), // start to right of container
            introStack.trailingAnchor.constraint(equalTo: upgradeContainer.trailingAnchor),
            // note: vertical constraints in landscape handled by landscapeCenterGuide
        ]
        
        // Dark tinted background with rounded corners for text
        
        let introStackBackground = UIView()
        introStackBackground.backgroundColor = .black.withAlphaComponent(0.3)
        introStackBackground.layer.cornerRadius = 18.0
        introStackBackground.translatesAutoresizingMaskIntoConstraints = false
        introContainer.addSubview(introStackBackground)
        NSLayoutConstraint.activate([
            introStackBackground.topAnchor.constraint(equalTo: introStack.topAnchor, constant: -StyleConstant.verticalSpacingSmall),
            introStackBackground.bottomAnchor.constraint(equalTo: introStack.bottomAnchor, constant: StyleConstant.verticalSpacingSmall),
            // TODO: fix this, in landscape on *small device* it touches the screen edge
            introStackBackground.leadingAnchor.constraint(equalTo: introStack.leadingAnchor, constant: -StyleConstant.horizontalMargins / 2.0),
            introStackBackground.trailingAnchor.constraint(equalTo: introStack.trailingAnchor, constant: StyleConstant.horizontalMargins / 2.0),
        ])
        
        // Logo disc and wordmark
        
        wordmarkPro = UIImageView(image: UIImage(named: "djay-pro"))
        wordmarkPro.contentMode = .scaleAspectFit
        wordmarkPro.alpha = 0.0
        wordmarkPro.transform = .init(scaleX: 0.0, y: 0.0)
        wordmarkPro.translatesAutoresizingMaskIntoConstraints = false
        wordmarkPro.layer.zPosition = 1.0
        addSubview(wordmarkPro)
        
        logo = UIImageView(image: UIImage(named: "djay-logo"))
        logo.contentMode = .scaleAspectFit
        logo.transform = .init(scaleX: 0.0, y: 0.0)
        logo.translatesAutoresizingMaskIntoConstraints = false
        addSubview(logo)

        portraitConstraints += [
            wordmarkPro.centerXAnchor.constraint(equalTo: centerXAnchor),
            wordmarkPro.widthAnchor.constraint(equalTo: introContainer.widthAnchor, constant: -StyleConstant.horizontalMargins * 2.0),
            wordmarkPro.centerYAnchor.constraint(equalTo: centerYAnchor),
            logo.centerXAnchor.constraint(equalTo: centerXAnchor),
            logo.centerYAnchor.constraint(equalTo: centerYAnchor),
        ]
        landscapeConstraints += [
            introStack.topAnchor.constraint(equalTo: landscapeCenterGuide.topAnchor),
            wordmarkPro.centerXAnchor.constraint(equalTo: introContainer.centerXAnchor),
            wordmarkPro.widthAnchor.constraint(equalTo: introContainer.widthAnchor, constant: -StyleConstant.horizontalMargins * 2.0),
            wordmarkPro.topAnchor.constraint(greaterThanOrEqualTo: introStack.bottomAnchor, constant: StyleConstant.verticalSpacingSmall),
            wordmarkPro.bottomAnchor.constraint(equalTo: landscapeCenterGuide.bottomAnchor),
            logo.centerXAnchor.constraint(equalTo: upgradeContainer.centerXAnchor),
            logo.topAnchor.constraint(equalTo: upgradeContainer.safeAreaLayoutGuide.topAnchor, constant: StyleConstant.verticalSpacingSmall)
        ]

        // Top (or left) content
        
        let closeButton = UIButton() // no action in this exercise
        closeButton.translatesAutoresizingMaskIntoConstraints = false
        var buttonConfig = UIButton.Configuration.borderless()
        buttonConfig.image = UIImage(
            systemName: "xmark",
            withConfiguration: UIImage.SymbolConfiguration(pointSize: 16, weight: .bold)
        )
        closeButton.configuration = buttonConfig
        closeButton.tintColor = .white
        introContainer.addSubview(closeButton)
        NSLayoutConstraint.activate([
            closeButton.topAnchor.constraint(equalTo: introContainer.safeAreaLayoutGuide.topAnchor),
        ])
        portraitConstraints += [
            closeButton.leadingAnchor.constraint(equalTo: introContainer.leadingAnchor, constant: StyleConstant.horizontalMargins)
        ]
        landscapeConstraints += [
            closeButton.leadingAnchor.constraint(equalTo: introContainer.leadingAnchor)
        ]
        
        let title = UILabel()
        title.numberOfLines = 0
        title.textColor = .white
        let titleSize = UIFontDescriptor.preferredFontDescriptor(withTextStyle: .title1).pointSize
        let titleDescriptor = UIFont.systemFont(ofSize: titleSize, weight: .thin).fontDescriptor.addingAttributes([.traits: [UIFontDescriptor.TraitKey.width: 0.2]])
        title.font = UIFont(descriptor: titleDescriptor, size: 0)
        title.textAlignment = .center
        title.text = switch onboardingState.value.model.skillLevel {
        case .beginner:
            "Welcome Beginner !".uppercased() // << uses "thin space" (U+2009) for better typography
        case .intermediate, nil:
            "Welcome DJ !".uppercased()
        case .professional:
            "Welcome Pro DJ !".uppercased()
        }
        introStack.addArrangedSubview(title)
        
        let mainText = UILabel()
        let textDescriptor = UIFont.systemFont(ofSize: titleSize, weight: .regular).fontDescriptor.addingAttributes([.traits: [UIFontDescriptor.TraitKey.width: 0.2]])
        let bodySize = UIFontDescriptor.preferredFontDescriptor(withTextStyle: .body).pointSize
        mainText.font = UIFont(descriptor: textDescriptor, size: bodySize)
        mainText.textAlignment = .justified
        mainText.textColor = .systemGray
        mainText.numberOfLines = 0
        mainText.text = switch onboardingState.value.model.skillLevel {
        case .beginner:
            "Your DJ journey begins here. The app is easy to use, there are many tutorials at algoriddim.com and an active community to help."
        case .intermediate, nil:
            "Your DJ journey continues here. You made a good choice. djay is the award winning and most used DJ app in the world! You’ll soon discover why."
        case .professional:
            "As a pro DJ, you’ve landed in the right place. Integrate with industry leading gear and let djay Pro features — such as Neural Mix — take you to the next level."
        }
        introStack.addArrangedSubview(mainText)
        
        
        // Bottom (or right) content
                
        // Bottom buttons
        
        let buttonStack = UIStackView()
        buttonStack.axis = .vertical
        buttonStack.alignment = .center
        buttonStack.spacing = StyleConstant.verticalSpacingSmall / 2.0
        buttonStack.translatesAutoresizingMaskIntoConstraints = false
        upgradeContainer.addSubview(buttonStack)
        NSLayoutConstraint.activate([
            buttonStack.centerXAnchor.constraint(equalTo: upgradeContainer.centerXAnchor),
            buttonStack.bottomAnchor.constraint(equalTo: upgradeContainer.safeAreaLayoutGuide.bottomAnchor)
        ])
        
        // Upgrade info
        
        upgradeStack = UIStackView()
        upgradeStack.axis = .vertical
        upgradeStack.alignment = .center
        upgradeStack.spacing = StyleConstant.verticalSpacingSmall
        upgradeStack.distribution = .equalSpacing
        upgradeStack.translatesAutoresizingMaskIntoConstraints = false
        //secondStack.backgroundColor = .green.withAlphaComponent(0.3)
        upgradeContainer.addSubview(upgradeStack)
        
        portraitConstraints += [
            upgradeStack.leadingAnchor.constraint(equalTo: upgradeContainer.safeAreaLayoutGuide.leadingAnchor, constant: StyleConstant.horizontalMargins),
            upgradeStack.trailingAnchor.constraint(equalTo: upgradeContainer.safeAreaLayoutGuide.trailingAnchor, constant: -StyleConstant.horizontalMargins),
            upgradeStack.bottomAnchor.constraint(equalTo: buttonStack.topAnchor)
        ]
        landscapeConstraints += [
            upgradeStack.leadingAnchor.constraint(equalTo: upgradeContainer.leadingAnchor, constant: StyleConstant.horizontalSpacingSmall),
            upgradeStack.trailingAnchor.constraint(equalTo: upgradeContainer.safeAreaLayoutGuide.trailingAnchor),
            upgradeStack.topAnchor.constraint(lessThanOrEqualTo: upgradeContainer.safeAreaLayoutGuide.topAnchor, constant: StyleConstant.verticalSpacingSmall),
            upgradeStack.bottomAnchor.constraint(equalTo: buttonStack.topAnchor, constant: -StyleConstant.verticalSpacing),
        ]
        
        // Call To Action (CTA)
        
        let ctaTitle = UILabel()
        ctaTitle.numberOfLines = 0
        ctaTitle.text = "Unlock PRO Features"
        if let boldDescriptor = UIFontDescriptor.preferredFontDescriptor(withTextStyle: .title2).withSymbolicTraits(.traitBold) {
            ctaTitle.font = UIFont(descriptor: boldDescriptor, size: 0)
        } else {
            ctaTitle.font = .preferredFont(forTextStyle: .title2)
        }
        ctaTitle.textColor = .white
        upgradeStack.addArrangedSubview(ctaTitle)
        
        ctaText = UILabel()
        ctaText.numberOfLines = 0
        ctaText.text = """
        · 1000s of loops, FX and visuals
        · Neural Mix, Automix with AI
        · iPhone, iPad and Mac
        """
        ctaText.textAlignment = .left
        ctaText.font = .preferredFont(forTextStyle: .title3)
        ctaText.textColor = .systemGray
        upgradeStack.addArrangedSubview(ctaText)

        // Upgrade button (toggle)
        
        let upgradeButton = UIButton()
        upgradeButton.translatesAutoresizingMaskIntoConstraints = false
        upgradeButton.contentHorizontalAlignment = .leading
        upgradeButton.addAction(.init { [weak self] action in
            guard let self, let tappedButton = action.sender as? UIButton else {
                return
            }
            tappedButton.isSelected.toggle()
            continueButton.isEnabled = tappedButton.isSelected
        }, for: .touchUpInside)
        upgradeButton.configurationUpdateHandler = { button in
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
                "€29.99/year or €2.50/month",
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
            config.background.backgroundColor = .white.withAlphaComponent(0.1)
            
            button.configuration = config
        }
        upgradeStack.addArrangedSubview(upgradeButton)

        portraitConstraints += [
            upgradeButton.widthAnchor.constraint(equalTo: upgradeContainer.widthAnchor, constant: -StyleConstant.horizontalMargins * 2.0)
        ]
        landscapeConstraints += [
            upgradeButton.widthAnchor.constraint(equalTo: upgradeContainer.widthAnchor, constant: -StyleConstant.horizontalMargins)
        ]
        
        // Restore purhases
        
        let restoreButton = UIButton() // no action
        restoreButton.translatesAutoresizingMaskIntoConstraints = false
        var restoreConfig = UIButton.Configuration.borderless()
        let restoreDescriptor = UIFontDescriptor.preferredFontDescriptor(withTextStyle: .body).withSymbolicTraits(.traitBold) ?? UIFontDescriptor.preferredFontDescriptor(withTextStyle: .body)
        restoreConfig.attributedTitle = AttributedString(
            "Restore Purchases",
            attributes: AttributeContainer([
                .font: UIFont(descriptor: restoreDescriptor, size: 0),
                .foregroundColor: UIColor.systemBlue
            ])
        )
        restoreConfig.baseForegroundColor = .white
        restoreButton.configuration = restoreConfig
        buttonStack.addArrangedSubview(restoreButton)

        // Continue (to buy)
        
        continueButton = UIButton(primaryAction: .init { action in
            // not handled for this exercise
        })
        continueButton.isEnabled = false
        continueButton.translatesAutoresizingMaskIntoConstraints = false
        continueButton.configurationUpdateHandler = { button in
            var config = UIButton.Configuration.borderedProminent()
            config.cornerStyle = .large
            config.attributedTitle = AttributedString(
                "Continue",
                attributes: AttributeContainer([
                    .font: UIFont.systemFont(ofSize: StyleConstant.buttonFontSizeLarge, weight: .semibold),
                    .foregroundColor: UIColor.white
                ])
            )
            config.background.backgroundColor = .systemBlue
            button.alpha = button.isEnabled ? 1.0 : 0.3
            button.configuration = config
        }
        buttonStack.addArrangedSubview(continueButton)
        NSLayoutConstraint.activate([
            continueButton.heightAnchor.constraint(equalToConstant: StyleConstant.buttonHeightLarge),
            continueButton.widthAnchor.constraint(equalTo: upgradeContainer.widthAnchor, constant: -StyleConstant.horizontalMargins * 2.0)
        ])

        // Terms
        
        let termsStack = UIStackView()
        termsStack.axis = .horizontal
        termsStack.alignment = .center
        termsStack.spacing = StyleConstant.horizontalSpacingSmall
        buttonStack.addArrangedSubview(termsStack)
        
        let privacyButton = UIButton() // no action
        var privacyConfig = UIButton.Configuration.borderless()
        let privacyDescriptor = UIFontDescriptor.preferredFontDescriptor(withTextStyle: .footnote).withSymbolicTraits(.traitBold) ?? UIFontDescriptor.preferredFontDescriptor(withTextStyle: .footnote)
        privacyConfig.attributedTitle = AttributedString(
            "Privacy Policy",
            attributes: AttributeContainer([
                .font: UIFont(descriptor: privacyDescriptor, size: 0),
                .foregroundColor: UIColor.systemGray
            ])
        )
        privacyConfig.baseForegroundColor = .white
        privacyButton.configuration = privacyConfig
        termsStack.addArrangedSubview(privacyButton)
        
        let termsButton = UIButton() // no action
        var termsConfig = UIButton.Configuration.borderless()
        let termsDescriptor = UIFontDescriptor.preferredFontDescriptor(withTextStyle: .footnote).withSymbolicTraits(.traitBold) ?? UIFontDescriptor.preferredFontDescriptor(withTextStyle: .footnote)
        termsConfig.attributedTitle = AttributedString(
            "Terms of Service",
            attributes: AttributeContainer([
                .font: UIFont(descriptor: termsDescriptor, size: 0),
                .foregroundColor: UIColor.systemGray
            ])
        )
        termsConfig.baseForegroundColor = .white
        termsButton.configuration = termsConfig
        termsStack.addArrangedSubview(termsButton)

        // these are hidden initially
        chromeElements = [
            closeButton,
            buttonStack,
            upgradeStack
        ].map { $0.alpha = 0.0; return $0 }

        textElements = [mainText, ctaText]
    }
    
    private func setupNodes() {
        
        guard let logoImage = UIImage(named: "djay-logo") else {
            assertionFailure("Art missing")
            return
        }
        
        // Nodes:
        
        // Glow effect
        
        glowEffect = SKEffectNode()
        glowEffect.shouldRasterize = true
        glowEffect.filter = CIFilter(
            name: "CIGaussianBlur",
            parameters: ["inputRadius": 15.0]
        )
        glowEffect.setScale(0.0)
        glowEffect.alpha = 0.0
        glowEffect.addChild({
            // blur in the shape of the logo
            let logo = SKSpriteNode(texture: .init(image: logoImage))
            logo.color = .white
            logo.colorBlendFactor = 1.0 // full color
            return logo
        }())

        // Horizon line
        
        let path = CGMutablePath()
        path.move(to: CGPoint(x: 0.0, y: 0.0))
        
        horizonLine = SKShapeNode(path: path)
        horizonLine.strokeColor = StyleConstant.lightYellowColor
        horizonLine.lineWidth = 1.0
        horizonLine.glowWidth = 4.0
        horizonLine.alpha = 0.6
        horizonLine.xScale = 0.0

        // Sparkles
        
        sparkles = OnboardingSparkles()
        sparkles.alpha = 0.0
        sparkles.zPosition = -1.0 // behind logo
        
        // Scene:
        
        scene = SKScene(size: .zero)
        scene.backgroundColor = .clear
        scene.scaleMode = .resizeFill
        
        scene.addChild(glowEffect)
        scene.addChild(horizonLine)
        scene.addChild(sparkles)
        
        // View:
        
        backgroundView = SKView(frame: .zero)
        backgroundView.backgroundColor = .clear
        addSubview(backgroundView)
        
        backgroundView.presentScene(scene)
    }
    
    private var didLayoutSubviews = false
    
    override func layoutSubviews() {
        
        super.layoutSubviews()
        
        // keep notes centered on orientation change
        let center: CGPoint = .init(x: bounds.size.width / 2, y: bounds.size.height / 2)
        
        backgroundView.frame = bounds
        scene.size = bounds.size
        sparkles.position = center
        glowEffect?.position = center // optional, as blur is removed after animation
        
        let line = CGMutablePath()
        line.move(to: CGPoint(x: 0.0, y: center.y))
        line.addLine(to: CGPoint(x: bounds.size.width, y: center.y))
        horizonLine.path = line

        guard !didLayoutSubviews else {
            // if already laid out, just restart the pulse with new orientation values
            sparkles.pulse(size: bounds.size)
            return
        }
        
        // run these only at beginning
        
        runNodeActions()
        
        runAnimations()
                    
        if isVerySmallScreen  {
            // keep it simple on tiny screens
            ctaText.isHidden = true
        }
        
        didLayoutSubviews = true
    }
    
    private func runNodeActions() {
        
        horizonLine.run(.sequence([
            .wait(forDuration: 2.0),
            .scale(to: 1.0, duration: 0.5),
        ]))
        
        glowEffect.run(.sequence([
            .wait(forDuration: 1.0),
            .group([
                .fadeAlpha(to: 1.0, duration: 2.0),
                .scale(to: 15.5, duration: 2.0)
            ]),
            .fadeAlpha(to: 0.0, duration: 1.0),
            .removeFromParent(),
            .run { [weak self] in
                self?.glowEffect = nil
            }
        ]))
        
        sparkles.run(.sequence([
            .wait(forDuration: 2.5),
            .fadeAlpha(to: 1.0, duration: 0.0),
            .run { [weak self] in
                guard let self else {
                    return
                }
                sparkles.pulse(size: bounds.size) // << start pulse
            },
        ]))
    }
    
    private func runAnimations() {
    
        // animate logo
        
        UIView.animateKeyframes(withDuration: 4.0, delay: 0.0, options: .calculationModeCubic) {
            UIView.addKeyframe(withRelativeStartTime: 0.0, relativeDuration: 0.6) { [weak self] in
                guard let self else {
                    return
                }
                logo.transform = .init(scaleX: 1.8, y: 1.8)
            }
            UIView.addKeyframe(withRelativeStartTime: 0.6, relativeDuration: 0.4) { [weak self] in
                guard let self else {
                    return
                }
                logo.alpha = 0.0
                logo.transform = .init(scaleX: 4.0, y: 4.0)
                wordmarkPro.alpha = 1.0
                wordmarkPro.transform = .identity
            }
        } completion: { finished in
            
        }
        
        // animate content area into view
        
        Task { @MainActor [weak self] in
            // (delay in task so CA doesn't preemptively evaluate constraints)
            try await Task.sleep(nanoseconds: 4_000_000_000)
            UIView.animate(withDuration: 2.5, delay: 0, usingSpringWithDamping: 0.7, initialSpringVelocity: 0.0, options: .curveEaseOut) { [weak self] in
                guard let self else {
                    return
                }
                if isCompactVerticalSize {
                    showLandscapeContent()
                    backgroundView.alpha = 0.15
                } else {
                    showPortraitContent()
                    backgroundView.alpha = 0.3
                }
                didAnimateHiddenContentIntoView = true
                layoutIfNeeded() // update for new constraints
            } completion: { [weak self] _ in
                guard let self else {
                    return
                }
                introContainer.clipsToBounds = false
                upgradeContainer.clipsToBounds = false
            }
        }
        
        // fade in chrome (buttons, etc)
        
        UIView.animate(withDuration: 2.0, delay: 6.0) { [weak self] in
            self?.chromeElements.forEach { $0.alpha = 1.0 }
        }
    }
    
    func updateOnboarding() {
        updateViewForTraits()
    }
    
    private var didAnimateHiddenContentIntoView = false
    private func showPortraitContent() {
        
        NSLayoutConstraint.deactivate(animatedPortraitConstraints)
        animatedPortraitConstraints = [
            introStack.leadingAnchor.constraint(equalTo: introContainer.safeAreaLayoutGuide.leadingAnchor, constant: StyleConstant.horizontalMargins), // same
            introStack.trailingAnchor.constraint(equalTo: introContainer.safeAreaLayoutGuide.trailingAnchor, constant: -StyleConstant.horizontalMargins), // same
            introStack.centerYAnchor.constraint(equalTo: introContainer.centerYAnchor), // animate to center
        ]
        NSLayoutConstraint.activate(animatedPortraitConstraints)
    }
    private func showLandscapeContent() {
        
        NSLayoutConstraint.deactivate(animatedLandscapeConstraints)
        animatedLandscapeConstraints = [
            introStack.leadingAnchor.constraint(equalTo: introContainer.safeAreaLayoutGuide.leadingAnchor, constant: StyleConstant.horizontalMargins / 2.0),
            introStack.trailingAnchor.constraint(equalTo: introContainer.trailingAnchor, constant: -StyleConstant.horizontalSpacingSmall),
            // note: vertical constraints managed by landscapeCenterGuide
        ]
        NSLayoutConstraint.activate(animatedLandscapeConstraints)
    }

    func updateViewForTraits() {
        
        // update constraints
        if isCompactVerticalSize {
            // Landscape
            NSLayoutConstraint.deactivate(portraitConstraints)
            NSLayoutConstraint.deactivate(animatedPortraitConstraints)
            NSLayoutConstraint.activate(landscapeConstraints)
            if didAnimateHiddenContentIntoView {
                showLandscapeContent()
            } else {
                NSLayoutConstraint.activate(animatedLandscapeConstraints)
            }
            // tweak the colors for legibility in landscape mode
            backgroundView.alpha = 0.2
            horizonLine.alpha = 0.5
            for textElement in textElements {
                textElement.textColor = .white.withAlphaComponent(0.8)
            }
            // tweak to remove extra text on very small screens
            ctaText.isHidden = isVerySmallScreen
        } else {
            // Portrait
            NSLayoutConstraint.deactivate(landscapeConstraints)
            NSLayoutConstraint.deactivate(animatedLandscapeConstraints)
            NSLayoutConstraint.activate(portraitConstraints)
            if didAnimateHiddenContentIntoView {
                showPortraitContent()
            } else {
                NSLayoutConstraint.activate(animatedPortraitConstraints)
            }
            backgroundView.alpha = 0.3
            horizonLine.alpha = 1.0
            for textElement in textElements {
                textElement.textColor = .white.withAlphaComponent(0.6)
            }
            ctaText.isHidden = isVerySmallScreen
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

