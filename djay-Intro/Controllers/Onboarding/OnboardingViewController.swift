//
//  OnboardingViewController.swift
//  djay-Intro
//
//  Created by David James on 16/02/2026.
//

import UIKit
import Combine

/// Holds the paging view controller, indicator and state for all onboarding screens
final class OnboardingViewController: UIViewController, SnapshotTestable {
    
    private let pagingViewController: OnboardingPagingViewController
    let pageControl: UIPageControl
    var bottomConstraint: NSLayoutConstraint!
    
    let onboardingState: CurrentValueSubject<OnboardingState, Never>
    private var subscriptions = [AnyCancellable]()
    
    init(state: OnboardingState) {
        self.onboardingState = CurrentValueSubject(state)
        self.pagingViewController = OnboardingPagingViewController(
            startViewController: .init(state: onboardingState)
        )
        self.pageControl = UIPageControl()
        super.init(nibName: nil, bundle: nil)
        setupUI()
        setupObservers()
    }
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    private func setupUI() {
        
        view.applyBackgroundGradient()
        
        // Paging view controller
        addChild(pagingViewController)
        pagingViewController.view.translatesAutoresizingMaskIntoConstraints = false
        view.addSubview(pagingViewController.view)
        pagingViewController.didMove(toParent: self)
        
        // pagingViewController.view.layer.borderWidth = 3.0
        // pagingViewController.view.layer.borderColor = UIColor.yellow.cgColor

        // Page control (dots)
        pageControl.numberOfPages = 4
        pageControl.currentPage = 0
        pageControl.tintColor = .black
        pageControl.translatesAutoresizingMaskIntoConstraints = false
        // match designs for indicator size (normally too large)
        pageControl.preferredIndicatorImage = .init(systemName: "circle.fill")?
            .withConfiguration(UIImage.SymbolConfiguration(pointSize: 10.0))
        pageControl.transform = .init(scaleX: 0.9, y: 0.9)
        
        view.addSubview(pageControl)
        
        bottomConstraint = pagingViewController.view.bottomAnchor.constraint(equalTo: pageControl.topAnchor, constant: -16)
        NSLayoutConstraint.activate([
            pagingViewController.view.topAnchor.constraint(equalTo: view.topAnchor),
            bottomConstraint,
            pagingViewController.view.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            pagingViewController.view.trailingAnchor.constraint(equalTo: view.trailingAnchor),
            pageControl.centerXAnchor.constraint(equalTo: view.centerXAnchor),
            pageControl.bottomAnchor.constraint(equalTo: view.safeAreaLayoutGuide.bottomAnchor),
        ])

    }
    
    func setupPreTransitionState() -> Bool {
        pagingViewController.setupPreTransitionState()
    }
    
    func setupVisibleState() -> Bool {
        pagingViewController.setupVisibleState()
    }
    
    func setupPostTransitionState() -> Bool {
        pagingViewController.setupPostTransitionState()
    }
    
    private func setupObservers() {
        
        // push the next onboarding step
        onboardingState
            .dropFirst()
            .removeDuplicates { previous, current in
                // only push if step has changed, not data contained on that step
                previous.step == current.step
            }
            .sink { [unowned self] newState in
                // print("New onboarding state: \(newState)")
                if newState.step == .completion {
                    // hide paging control area and fill screen
                    bottomConstraint.isActive = false
                    bottomConstraint = pagingViewController.view.bottomAnchor.constraint(equalTo: view.bottomAnchor)
                    bottomConstraint.isActive = true
                    pageControl.isHidden = true
                    view.applyBackgroundGradientVariant()
                } else {
                    pageControl.currentPage = newState.step.rawValue
                }
                // push to next step
                pagingViewController.pushNextOnboardingStep(newState.step)
            }
            .store(in: &subscriptions)
        
        // save state (e.g. user skill level)
        onboardingState
            .dropFirst()
            .removeDuplicates { previous, current in
                // only save if model has changed
                previous.model == current.model
            }
            .sink { newState in
                newState.model.save()
            }
            .store(in: &subscriptions)
        
    }
}

