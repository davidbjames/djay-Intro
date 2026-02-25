//
//  OnboardingTests.swift
//  djay-IntroTests
//
//  Created by David James on 16/02/2026.
//

import UIKit
import Testing
import SnapshotTesting
@testable import djay_Intro

@MainActor
struct OnboardingTests {

    @Test
    func testOnboardingSnapshots() async throws {
        
        var onboardingState = OnboardingState(step: .welcome, model: .init())
        for step in OnboardingStep.allCases {
            onboardingState.step = step
            if step == .completion {
                for skillLevel in OnboardingSkillLevel.allCases {
                    onboardingState.model.skillLevel = skillLevel
                    // TODO: setup snapshot testing for the finale step
                }
            } else {
                let vc = OnboardingViewController(state: onboardingState)
                if vc.setupPreTransitionState() {
                    assertSnapshot(of: vc, as: .image, named: "\(step)-portrait")
                }
                if vc.setupVisibleState() {
                    assertSnapshot(of: vc, as: .image, named: "\(step)-portrait-visible")
                }
                if vc.setupPostTransitionState() {
                    assertSnapshot(of: vc, as: .image, named: "\(step)-portrait-transitioned")
                }
            }
        }
    }
}
