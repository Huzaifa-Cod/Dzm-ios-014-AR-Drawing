//
//  AppEnums.swift
//  ARDrawing
//
//  Single source of truth for every enum used across the app.
//

import Foundation

// MARK: - Colors
/// Maps 1:1 to color set names inside Assets.xcassets/Colors.
/// Never hardcode a hex value in a View — add the color to the asset
/// catalog first, then add its case here.
enum AppColor: String {
    case black = "kBlack"
    case white = "kWhite"
    case dark = "k1A1A"
    case primaryBlue = "kPrimaryBlue"
    case gradientStart = "kGradientStart"
    case gradientEnd = "kGradientEnd"
    case textSecondary = "kTextSecondary"
}

// MARK: - Fonts
/// Maps to the Outfit font family bundled in /Fonts.
enum AppFontName: String {
    case black = "Outfit-Black"
    case bold = "Outfit-Bold"
    case semiBold = "Outfit-SemiBold"
    case medium = "Outfit-Medium"
    case regular = "Outfit-Regular"
    case light = "Outfit-Light"
}

// MARK: - Images
/// Maps to image asset names inside Assets.xcassets.
enum AppImage: String {
    case splash = "Splash"
    case splashIcon = "splashIcon"
    case onboard1 = "onboard1"
    case onboard2 = "onboard2"
    case onboard3 = "onboard3"
    case onboard4 = "onboard4"
    case onboard5 = "onboard5"
    case onboard6 = "onboard6"
    case pointedArrowIcon = "pointedArrowIcon"
    case trustedByCreators = "trustedByCreators"
}

// MARK: - Navigation Routes
/// Every screen the app can push/present. `AppRouter` reads this enum
/// to build the destination view.
enum AppRoute: Hashable {
    case intro
    case onboarding
    case home
}

// MARK: - Onboarding
/// Ordered pages shown by the paged onboarding carousel.
enum OnboardingPage: Int, CaseIterable {
    case trace = 0

    var titleKey: LocalizedKey {
        switch self {
        case .trace: return .onboardingTraceTitle
        }
    }

    var descriptionKey: LocalizedKey {
        switch self {
        case .trace: return .onboardingTraceDescription
        }
    }

    var image: AppImage {
        switch self {
        case .trace: return .onboard2
        }
    }
}

// MARK: - UserDefaults Keys
/// Every persisted key for the app. Backed by `UserDefaultsManager`.
enum UserDefaultsKey: String {
    case hasAgreedToTerms
    case hasCompletedOnboarding
    case lastOnboardingPage
}

// MARK: - Localization Keys
/// Every localizable string key used in the app. Keeps call sites
/// typo-proof and greppable; the raw value is the key in Localizable.strings.
enum LocalizedKey: String {
    case appName = "app_name"

    // Intro screen
    case introTitle = "intro_title"
    case introSubtitle = "intro_subtitle"
    case introAgreeButton = "intro_agree_button"
    case introTermsPrefix = "intro_terms_prefix"
    case introTermsOfUse = "intro_terms_of_use"
    case introTermsAnd = "intro_terms_and"
    case introPrivacyPolicy = "intro_privacy_policy"

    // Onboarding
    case onboardingTrustedByCreators = "onboarding_trusted_by_creators"
    case onboardingTraceTitle = "onboarding_trace_title"
    case onboardingTraceDescription = "onboarding_trace_description"
    case onboardingContinueButton = "onboarding_continue_button"
}
