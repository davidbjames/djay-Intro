//
//  Untitled.swift
//  djay-Intro
//
//  Created by David James on 16/02/2026.
//

import Foundation

/// Onboarding model for local storage so we know if the user
/// has completed their onboarding and what skill level they have.
struct Onboarding: CodableDefaultsStorable {
    
    var skillLevel: OnboardingSkillLevel?
    var hasCompletedOnboarding: Bool = false
    
    static let storageKey = "com.djay.app.onboarding"
}

/// Adhoc DJ skill levels
enum OnboardingSkillLevel: Int, CaseIterable, Codable {
    
    case beginner
    case intermediate
    case professional
    
    var title: String {
        switch self {
        case .beginner: "Beginner"
        case .intermediate: "Intermediate"
        case .professional: "Professional"
        }
    }
}
