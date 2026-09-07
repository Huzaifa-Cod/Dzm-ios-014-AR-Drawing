//
//  UserDefaultsManager.swift
//  ARDrawing
//


import Foundation

final class UserDefaultsManager {
    static let shared = UserDefaultsManager()

    private let defaults = UserDefaults.standard

    private init() {}

    var hasAgreedToTerms: Bool {
        get { defaults.bool(forKey: UserDefaultsKey.hasAgreedToTerms.rawValue) }
        set { defaults.set(newValue, forKey: UserDefaultsKey.hasAgreedToTerms.rawValue) }
    }

    var hasCompletedOnboarding: Bool {
        get { defaults.bool(forKey: UserDefaultsKey.hasCompletedOnboarding.rawValue) }
        set { defaults.set(newValue, forKey: UserDefaultsKey.hasCompletedOnboarding.rawValue) }
    }

    var lastOnboardingPage: Int {
        get { defaults.integer(forKey: UserDefaultsKey.lastOnboardingPage.rawValue) }
        set { defaults.set(newValue, forKey: UserDefaultsKey.lastOnboardingPage.rawValue) }
    }
}
