//  AppEnums.swift
//  ARDrawing


import CoreGraphics
import Foundation

// MARK: - Colors

enum AppColor: String {
    case black = "kBlack"
    case white = "kWhite"
    case dark = "k1A1A"
    case accent = "AccentColor"
    case textSecondary = "kTextSecondary"
    case dotInactive = "kDotInactive"
    case homeBackground = "kHomeBg"
    case proOrange = "kProOrange"
    case tutorialBorder = "kTutorialBorder"
    case successGreen = "kSuccessGreen"
    case surfaceLight = "kSurfaceLight"
}

// MARK: - Fonts
enum AppFontName: String {
    case black = "Outfit-Black"
    case bold = "Outfit-Bold"
    case semiBold = "Outfit-SemiBold"
    case medium = "Outfit-Medium"
    case regular = "Outfit-Regular"
    case light = "Outfit-Light"
    case extraBold = "Outfit-ExtraBold"

    case paytoneOne = "PaytoneOne-Regular"
}

// MARK: - Images
enum AppImage: String {
    case splash = "Splash"
    case splashIcon = "splashIcon"
    case onboard1 = "onboard1"
    case onboard2 = "onboard2"
    case onboard3 = "onboard3"
    case onboard4 = "onboard4"
    case onboard5 = "onboard5"
    case onboard6 = "onboard6"
    case onboard5TopImg = "onboard5TopImg"
    case onboardProfileIcons = "onboardProfileIcons"
    case pointedArrowIcon = "pointedArrowIcon"
    case trustedByCreators = "trustedByCreators"
    case tutorialOnboardBgImg = "tutorialOnboardBgImg"
    case previewCat = "previewCat"

    /// Pre-cropped framings of the same cat guide, one per tutorial step.
    /// See `TutorialGuideSlice` for how they line up with each other.
    case catFull = "cat1"
    case catLeftEar = "cat2"
    case catRightEar = "cat3"
    case catNose = "cat4"
    case catLeftProfile = "cat5"
    case catRightProfile = "cat6"

    /// Tab bar icons. Each tab has a filled/coloured "active" variant and
    /// an outlined "unactive" one; both are coloured in the asset itself,
    /// so they are drawn untinted.
    case homeActive, homeUnactive
    case lessonActive, lessonUnactive
    case templatesActive, templatesUnactive
    case profileActive, profileUnactive
    case settingActive, settingUnactive

    /// Home
    case photoRefBgImg, photoRefImg
    case capBgImg, capImg
    case fireIcon, starIcon
    case sample1, sample2, sample3, sample4
}

// MARK: - Tab Bar
/// The five sections of the app behind the tab bar. Order here is the
/// order they appear in, and `MainTabView` reads `allCases` to build both
/// the bar and the screen for each tab.


enum AppTab: Int, CaseIterable, Identifiable {
    case home = 0
    case lessons
    case templates
    case profile
    case settings

    var id: Int { rawValue }

    var titleKey: LocalizedKey {
        switch self {
        case .home: return .tabHome
        case .lessons: return .tabLessons
        case .templates: return .tabTemplates
        case .profile: return .tabProfile
        case .settings: return .tabSettings
        }
    }

    var iconHeight: CGFloat {
        switch self {
        case .home: return 26
        case .lessons: return 20
        case .templates: return 25
        case .profile: return 23
        case .settings: return 25
        }
    }

    /// Icon shown while this tab is selected.
    var activeImage: AppImage {
        switch self {
        case .home: return .homeActive
        case .lessons: return .lessonActive
        case .templates: return .templatesActive
        case .profile: return .profileActive
        case .settings: return .settingActive
        }
    }

    var inactiveImage: AppImage {
        switch self {
        case .home: return .homeUnactive
        case .lessons: return .lessonUnactive
        case .templates: return .templatesUnactive
        case .profile: return .profileUnactive
        case .settings: return .settingUnactive
        }
    }
}

// MARK: - Home

enum HomeCategory: Int, CaseIterable, Identifiable {
    case forKids = 0
    case cute

    var id: Int { rawValue }

    var titleKey: LocalizedKey {
        switch self {
        case .forKids: return .homeForKids
        case .cute: return .homeCute
        }
    }

    var samples: [AppImage] {
        switch self {
        case .forKids: return [.sample1, .sample4, .sample2, .sample3]
        case .cute: return [.sample2, .sample3, .sample1, .sample4]
        }
    }
}

// MARK: - Templates
/// Filter chips across the top of the Templates screen.
enum TemplateCategory: Int, CaseIterable, Identifiable {
    case kids = 0
    case cute
    case animal
    case anime

    var id: Int { rawValue }

    var titleKey: LocalizedKey {
        switch self {
        case .kids: return .templateCategoryKids
        case .cute: return .templateCategoryCute
        case .animal: return .templateCategoryAnimal
        case .anime: return .templateCategoryAnime
        }
    }

    /// Artwork for the chip. Still to be supplied — the chip lays out
    /// correctly with or without one, so filling these in is the only
    /// change needed once the icons arrive.
    var icon: AppImage? {
        switch self {
        case .kids, .cute, .animal, .anime: return nil
        }
    }

    /// Placeholder artwork until templates come from the backend.
    var samples: [AppImage] {
        switch self {
        case .kids: return [.sample1, .sample4]
        case .cute: return [.sample2, .sample3]
        case .animal: return [.sample4, .sample2]
        case .anime: return [.sample3, .sample1]
        }
    }
}

// MARK: - Navigation Routes
/// Every screen the app can push/present. `AppRouter` reads this enum
/// to build the destination view.
enum AppRoute: Hashable {
    case intro
    case onboarding
    case tutorial
    case tutorialDrawing
    /// The finished lesson, carrying the sketch the user just drew.
    case tutorialComplete(strokes: [DrawnStroke])
    case home
}

// MARK: - Launch
/// Where the app opens once the splash finishes.

enum LaunchDestination {
    case intro
    case onboarding
    case tutorial
    case main

    static var current: LaunchDestination {
        let defaults = UserDefaultsManager.shared
        if defaults.hasCompletedTutorial { return .main }
        if defaults.hasCompletedOnboarding { return .tutorial }
        if defaults.hasAgreedToTerms { return .onboarding }
        return .intro
    }
}

// MARK: - Onboarding

enum OnboardingLayout {
    case imageFirst
    case titleFirst
}

enum OnboardingPage: Int, CaseIterable, Identifiable {
    case trace = 0
    case drawPhotos
    case templates
    case lessons
    case community

    var id: Int { rawValue }

    var layout: OnboardingLayout {
        switch self {
        case .community: return .titleFirst
        default: return .imageFirst
        }
    }

    var image: AppImage {
        switch self {
        case .trace: return .onboard2
        case .drawPhotos: return .onboard3
        case .templates: return .onboard4
        case .lessons: return .onboard5
        case .community: return .onboard6
        }
    }

    /// Small artwork shown above the headline (community page only).
    var topImage: AppImage? {
        switch self {
        case .community: return .onboard5TopImg
        default: return nil
        }
    }

    var titleKey: LocalizedKey {
        switch self {
        case .trace: return .onboardingTraceTitle
        case .drawPhotos: return .onboardingDrawPhotosTitle
        case .templates: return .onboardingTemplatesTitle
        case .lessons: return .onboardingLessonsTitle
        case .community: return .onboardingCommunityTitle
        }
    }

    /// The community page shows no supporting copy in the design.
    var descriptionKey: LocalizedKey? {
        switch self {
        case .trace: return .onboardingTraceDescription
        case .drawPhotos: return .onboardingDrawPhotosDescription
        case .templates: return .onboardingTemplatesDescription
        case .lessons: return .onboardingLessonsDescription
        case .community: return nil
        }
    }

    /// The "Trusted by the creatives" badge sits over the first page's artwork.
    var showsTrustBadge: Bool {
        self == .trace
    }

    /// The final page drops the pager dots in the design.
    var showsPageIndicator: Bool {
        self != .community
    }

    /// Pages counted by the dot indicator.
    static var indicatorPages: [OnboardingPage] {
        allCases.filter(\.showsPageIndicator)
    }
}


// MARK: - Drawing Tutorial
/// One step of the guided cat drawing. Each step zooms the shared guide
/// artwork onto the feature being traced and caps how many strokes the
/// user may draw before they have to undo.
enum TutorialStep: Int, CaseIterable, Identifiable {
    case face = 0
    case leftEar
    case rightEar
    case nose
    case leftEye
    case rightEye
    case leftWhiskers
    case rightWhiskers
    case result

    var id: Int { rawValue }

    var isResult: Bool { self == .result }

    /// How many separate strokes this step accepts. Once the user lifts
    /// their finger for the last allowed stroke, drawing is locked until
    /// they undo.
    var maxStrokes: Int {
        switch self {
        case .face, .nose, .leftEye, .rightEye: return 1
        case .leftEar, .rightEar: return 2
        case .leftWhiskers, .rightWhiskers: return 3
        case .result: return 0
        }
    }

    /// The pre-cropped artwork this step draws on. The two whisker steps
    /// deliberately reuse the framing of the eye step two places earlier,
    /// as in the design.
    var guide: TutorialGuideSlice {
        switch self {
        case .face, .result: return .full
        case .leftEar: return .leftEar
        case .rightEar: return .rightEar
        case .nose: return .nose
        case .leftEye, .leftWhiskers: return .leftProfile
        case .rightEye, .rightWhiskers: return .rightProfile
        }
    }

    /// Filled segments of the ten-step progress bar, matching the design
    /// where the first drawing step already shows two filled segments.
    var progressIndex: Int { rawValue + 2 }

    static let progressTotal = 10
}

// MARK: - UserDefaults Keys
/// Every persisted key for the app. Backed by `UserDefaultsManager`.
enum UserDefaultsKey: String {
    case hasAgreedToTerms
    case hasCompletedOnboarding
    case lastOnboardingPage
    case hasCompletedTutorial
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
    case onboardingTraceTitle = "onboarding_trace_title"
    case onboardingTraceDescription = "onboarding_trace_description"
    case onboardingDrawPhotosTitle = "onboarding_draw_photos_title"
    case onboardingDrawPhotosDescription = "onboarding_draw_photos_description"
    case onboardingTemplatesTitle = "onboarding_templates_title"
    case onboardingTemplatesDescription = "onboarding_templates_description"
    case onboardingLessonsTitle = "onboarding_lessons_title"
    case onboardingLessonsDescription = "onboarding_lessons_description"
    case onboardingCommunityTitle = "onboarding_community_title"
    case onboardingContinueButton = "onboarding_continue_button"

    // Tutorial
    case tutorialTitle = "tutorial_title"
    case tutorialBadge = "tutorial_badge"
    case tutorialCallout = "tutorial_callout"
    case tutorialStartButton = "tutorial_start_button"
    case tutorialSkipButton = "tutorial_skip_button"
    case tutorialLessonTitle = "tutorial_lesson_title"
    case tutorialCompleteButton = "tutorial_complete_button"

    // Tutorial complete
    case tutorialCompleteSocialProof = "tutorial_complete_social_proof"
    case tutorialCompleteHeadline = "tutorial_complete_headline"
    case tutorialCompleteDescription = "tutorial_complete_description"
    case tutorialCompleteContinueButton = "tutorial_complete_continue_button"

    // Tab bar
    case tabHome = "tab_home"
    case tabLessons = "tab_lessons"
    case tabTemplates = "tab_templates"
    case tabProfile = "tab_profile"
    case tabSettings = "tab_settings"

    // Home
    case homeStreakCount = "home_streak_count"
    case homeProBadge = "home_pro_badge"
    case homePhotoReferenceTitle = "home_photo_reference_title"
    case homeCaptureTitle = "home_capture_title"
    case homeStepByStepTitle = "home_step_by_step_title"
    case homeStepByStepSubtitle = "home_step_by_step_subtitle"
    case homeForKids = "home_for_kids"
    case homeCute = "home_cute"
    case homeSeeAll = "home_see_all"

    // Templates
    case templatesTitle = "templates_title"
    case templatesSearchPlaceholder = "templates_search_placeholder"
    case templateCategoryKids = "template_category_kids"
    case templateCategoryCute = "template_category_cute"
    case templateCategoryAnimal = "template_category_animal"
    case templateCategoryAnime = "template_category_anime"
}
