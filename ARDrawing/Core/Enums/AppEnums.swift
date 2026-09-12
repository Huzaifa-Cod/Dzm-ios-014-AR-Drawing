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
    /// Bottom stop of the screen gradient (white FFFFFF → this F7F8FA).
    /// See `View.screenGradientBackground()`.
    case gradientEnd = "kGradientEnd"
    case successGreen = "kSuccessGreen"
    case surfaceLight = "kSurfaceLight"
    case redAccent = "kRed"
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

    /// Profile
    case topViewBackView, levelBadge
    case pencilIcon, timeSpentIcon, lessonCountIcon
    case uploadIcon
    
    /// Profile — Album
    /// Selection state on a thumbnail; both are pre-coloured in the asset,
    /// so like the tab icons above they are drawn untinted.
    case checkIcon, uncheckIcon
    case selectAllIcon, deselectAllIcon, deleteIcon

    /// Settings
    case restorePurchaseIcon = "Group"
    case languageIcon, rateIcon, contactIcon, shareIcon, privacyIcon, termsIcon

    /// Draw mode
    case phoneIcon, paperIcon, arDrawIcon

    /// Editor
    case undoIcon, redoIcon, lockImageIcon, unlockImageIcon
    case opacityIcon, flipImgIcon, eraserIcon, recordIcon, imageCameraIcon, flashIcon, resetIcon
    case strokeIcon
    /// Buttons inside the Photo/Record sheets — shown exactly as
    /// exported, no extra background or shadow drawn on top.
    case capturePhotoIconBtn, recordBtn, stopRecordingBtnIcon
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

// MARK: - Profile
/// The three figures in the stats card. All three icons were exported at
/// the same 33pt height with differing widths, so they are pinned by height
/// and keep their natural proportions.
enum ProfileStat: Int, CaseIterable, Identifiable {
    case drawn = 0
    case timeSpent
    case lessons

    var id: Int { rawValue }

    static let iconHeight: CGFloat = 33

    var icon: AppImage {
        switch self {
        case .drawn: return .pencilIcon
        case .timeSpent: return .timeSpentIcon
        case .lessons: return .lessonCountIcon
        }
    }

    var labelKey: LocalizedKey {
        switch self {
        case .drawn: return .profileStatDrawn
        case .timeSpent: return .profileStatTimeSpent
        case .lessons: return .profileStatLessons
        }
    }
}



// MARK: - Profile — Album
/// The two segmented tabs at the top of the Album screen.
enum AlbumTab: Int, CaseIterable, Identifiable {
   case drawn = 0
   case recorded

   var id: Int { rawValue }

   var titleKey: LocalizedKey {
       switch self {
       case .drawn: return .albumTabDrawn
       case .recorded: return .albumTabRecorded
       }
   }

   /// Matches `SavedSketch.kind`, so a tab filters straight on the stored value.
   var storageKind: String {
       switch self {
       case .drawn: return SketchKind.drawn.rawValue
       case .recorded: return SketchKind.recorded.rawValue
       }
   }
}


// MARK: - Draw Mode
/// The three ways a template can be drawn, offered as a carousel right
/// after picking one. Each page gets a looping usage clip once that
/// exists — see `DrawModeSelectionView`.
enum DrawMode: Int, CaseIterable, Identifiable {
    case phone = 0
    case arDraw
    case paper

    var id: Int { rawValue }

    var icon: AppImage {
        switch self {
        case .phone: return .phoneIcon
        case .arDraw: return .arDrawIcon
        case .paper: return .paperIcon
        }
    }

    var titleKey: LocalizedKey {
        switch self {
        case .phone: return .drawModePhoneTitle
        case .arDraw: return .drawModeARTitle
        case .paper: return .drawModePaperTitle
        }
    }
}

// MARK: - Editor
/// One button in the editor's bottom toolbar. The second slot is
/// `flip` for AR/paper modes and `eraser` while drawing on the phone
/// screen itself, where there is nothing behind the canvas to flip.
enum EditorTool: Int, CaseIterable, Identifiable {
    case opacity = 0
    case secondary
    case record
    case photo
    case flash

    var id: Int { rawValue }

    func icon(for mode: DrawMode) -> AppImage {
        switch self {
        case .opacity: return .opacityIcon
        case .secondary: return mode == .phone ? .eraserIcon : .flipImgIcon
        case .record: return .recordIcon
        case .photo: return .imageCameraIcon
        case .flash: return mode == .phone ? .strokeIcon : .flashIcon
        }
    }

    func titleKey(for mode: DrawMode) -> LocalizedKey {
        switch self {
        case .opacity: return .editorToolOpacity
        case .secondary: return mode == .phone ? .editorToolEraser : .editorToolFlip
        case .record: return .editorToolRecord
        case .photo: return .editorToolPhoto
            case .flash: return mode == .phone ? .editorToolStroke : .editorToolFlash
        }
    }
}

/// Zoom presets shown as a pill row above the toolbar.
enum EditorZoom: Int, CaseIterable, Identifiable {
    case half = 0
    case one
    case two

    var id: Int { rawValue }

    var label: String {
        switch self {
        case .half: return "0.5x"
        case .one: return "1x"
        case .two: return "2x"
        }
    }
}

/// The two tabs in the Record sheet — same start/stop button, a
/// differently styled progress ring around it while active.
enum EditorRecordMode: Int, CaseIterable, Identifiable {
    case video = 0
    case timelapse

    var id: Int { rawValue }

    var titleKey: LocalizedKey {
        switch self {
        case .video: return .editorRecordModeVideo
        case .timelapse: return .editorRecordModeTimelapse
        }
    }
}

// MARK: - Settings
/// One tappable row on the Settings screen.
enum SettingsRow: Int, CaseIterable, Identifiable {
    case restorePurchase = 0
    case language
    case rateUs
    case contactUs
    case shareWithFriends
    case privacyPolicy
    case termsAndConditions

    var id: Int { rawValue }

    var icon: AppImage {
        switch self {
        case .restorePurchase: return .restorePurchaseIcon
        case .language: return .languageIcon
        case .rateUs: return .rateIcon
        case .contactUs: return .contactIcon
        case .shareWithFriends: return .shareIcon
        case .privacyPolicy: return .privacyIcon
        case .termsAndConditions: return .termsIcon
        }
    }

    var titleKey: LocalizedKey {
        switch self {
        case .restorePurchase: return .settingsRestorePurchase
        case .language: return .settingsLanguage
        case .rateUs: return .settingsRateUs
        case .contactUs: return .settingsContactUs
        case .shareWithFriends: return .settingsShareWithFriends
        case .privacyPolicy: return .settingsPrivacyPolicy
        case .termsAndConditions: return .settingsTermsConditions
        }
    }
}

/// The three grouped cards on the Settings screen, in order.
enum SettingsSection: Int, CaseIterable, Identifiable {
    case manage = 0
    case other
    case about

    var id: Int { rawValue }

    var titleKey: LocalizedKey {
        switch self {
        case .manage: return .settingsSectionManage
        case .other: return .settingsSectionOther
        case .about: return .settingsSectionAbout
        }
    }

    var rows: [SettingsRow] {
        switch self {
        case .manage: return [.restorePurchase]
        case .other: return [.language, .rateUs, .contactUs, .shareWithFriends]
        case .about: return [.privacyPolicy, .termsAndConditions]
        }
    }
}

// MARK: - Lessons
/// Difficulty tag shown on a lesson card — also the four filter chips
/// (`nil` case = "All") across the top of the screen.
enum LessonDifficulty: Int, CaseIterable, Identifiable {
    case beginner = 0
    case intermediate
    case expert

    var id: Int { rawValue }

    var titleKey: LocalizedKey {
        switch self {
        case .beginner: return .lessonDifficultyBeginner
        case .intermediate: return .lessonDifficultyIntermediate
        case .expert: return .lessonDifficultyExpert
        }
    }

    /// Text/background tint for this difficulty's pill.
    var tint: AppColor {
        switch self {
        case .beginner: return .successGreen
        case .intermediate: return .proOrange
        case .expert: return .redAccent
        }
    }
}

/// Where a lesson stands for the current user, driving the trailing
/// control on its card.
enum LessonProgress {
    case completed
    /// The next lesson the user hasn't done yet — its Start button is live.
    case unlocked
    /// Not reached yet — its Start button is shown but disabled.
    case locked
}

/// One row on the Lessons screen. Placeholder data until lessons come
/// from the backend — see `Lesson.placeholders`.
struct Lesson: Identifiable {
    let id: Int
    let title: String
    let thumbnail: AppImage
    let difficulty: LessonDifficulty
    let progress: LessonProgress

    static let placeholders: [Lesson] = [
        Lesson(id: 0, title: "Saturo Esai", thumbnail: .sample3, difficulty: .beginner, progress: .completed),
        Lesson(id: 1, title: "Cute 3", thumbnail: .sample4, difficulty: .intermediate, progress: .unlocked),
        Lesson(id: 2, title: "Cute 3", thumbnail: .sample4, difficulty: .expert, progress: .locked),
        Lesson(id: 3, title: "Cute 3", thumbnail: .sample4, difficulty: .beginner, progress: .locked),
        Lesson(id: 4, title: "Cute 3", thumbnail: .sample4, difficulty: .intermediate, progress: .locked),
        Lesson(id: 5, title: "Cute 3", thumbnail: .sample4, difficulty: .beginner, progress: .locked)
    ]
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
    case album
    /// The template the user tapped, carried forward so Editor knows
    /// what to draw — from Home's category rows or the Templates grid.
    case drawModeSelection(templateURL: URL)
    case editor(mode: DrawMode, templateURL: URL)
    /// The finished drawing, looked up from Core Data by the result screen.
    case sketchResult(id: UUID)
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

    // Profile
    case profileTitle = "profile_title"
    case profileCurrentLevel = "profile_current_level"
    case profileSeeMore = "profile_see_more"
    case profileStatDrawn = "profile_stat_drawn"
    case profileStatTimeSpent = "profile_stat_time_spent"
    case profileStatLessons = "profile_stat_lessons"
    case profileAlbumTitle = "profile_album_title"
    case profileAlbumSubtitle = "profile_album_subtitle"
    case profileUploadDrawing = "profile_upload_drawing"
    case profileLessonsTitle = "profile_lessons_title"
    case profileLessonsSubtitle = "profile_lessons_subtitle"
    
    
    // Profile — Album
    case albumNavTitle = "album_nav_title"
    case albumSelectAll = "album_select_all"
    case albumDeselectAll = "album_deselect_all"
    case albumTabDrawn = "album_tab_drawn"
    case albumTabRecorded = "album_tab_recorded"
    /// Format string, e.g. "%d items selected".
    case albumItemsSelected = "album_items_selected"
    case albumDelete = "album_delete"
    case albumEmptyTitle = "album_empty_title"

    // Lessons
    case lessonsScreenTitle = "lessons_screen_title"
    case lessonsCurrentLevel = "lessons_current_level"
    case lessonDifficultyAll = "lesson_difficulty_all"
    case lessonDifficultyBeginner = "lesson_difficulty_beginner"
    case lessonDifficultyIntermediate = "lesson_difficulty_intermediate"
    case lessonDifficultyExpert = "lesson_difficulty_expert"
    /// Format string, e.g. "Avg time: %@".
    case lessonAvgTimeFormat = "lesson_avg_time_format"
    case lessonAvgTimeValue = "lesson_avg_time_value"
    case lessonStatusCompleted = "lesson_status_completed"
    case lessonStatusStart = "lesson_status_start"

    // Settings
    case settingsTitle = "settings_title"
    case settingsSectionManage = "settings_section_manage"
    case settingsSectionOther = "settings_section_other"
    case settingsSectionAbout = "settings_section_about"
    case settingsRestorePurchase = "settings_restore_purchase"
    case settingsLanguage = "settings_language"
    case settingsRateUs = "settings_rate_us"
    case settingsContactUs = "settings_contact_us"
    case settingsShareWithFriends = "settings_share_with_friends"
    case settingsPrivacyPolicy = "settings_privacy_policy"
    case settingsTermsConditions = "settings_terms_conditions"

    // Draw mode
    case drawModeSelectTitle = "draw_mode_select_title"
    case drawModePhoneTitle = "draw_mode_phone_title"
    case drawModeARTitle = "draw_mode_ar_title"
    case drawModePaperTitle = "draw_mode_paper_title"
    case drawModeDescription = "draw_mode_description"
    case drawModeContinueButton = "draw_mode_continue_button"

    // Editor
    case editorCancel = "editor_cancel"
    case editorFinish = "editor_finish"
    case editorToolOpacity = "editor_tool_opacity"
    case editorToolFlip = "editor_tool_flip"
    case editorToolEraser = "editor_tool_eraser"
    case editorToolRecord = "editor_tool_record"
    case editorToolPhoto = "editor_tool_photo"
    case editorToolFlash = "editor_tool_flash"
    case editorToolStroke = "editor_tool_stroke"
    case editorPhotoSavedToast = "editor_photo_saved_toast"

    // Sketch result
    case resultTitle = "result_title"
    case resultSubtitle = "result_subtitle"
    case resultDownload = "result_download"
    case resultShare = "result_share"
    case resultDone = "result_done"
    case editorRecordModeVideo = "editor_record_mode_video"
    case editorRecordModeTimelapse = "editor_record_mode_timelapse"
    case editorCapturePhotoTitle = "editor_capture_photo_title"
    case editorDrawStrokeTitle = "editor_draw_stroke_title"
    
}
