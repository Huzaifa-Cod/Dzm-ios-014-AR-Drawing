//
//  Achievement.swift
//  ARDrawing

import Foundation

/// One badge in the Achievements grid — Profile shows a preview row of
/// these, the full grid lives in `AchievementsView`.
struct Achievement: Identifiable {
    let id: Int
    let icon: AppImage
    let titleKey: LocalizedKey
    /// Whether this one's been earned yet — locked badges render dimmed.
    var isUnlocked: Bool
}

enum AchievementCatalog {
    /// Stand-in unlock state until real progress tracking lands — the
    /// same placeholder-until-wired approach `ProfileSummary` uses.
    static let all: [Achievement] = [
        Achievement(id: 0, icon: .achievementFirstSketchIcon, titleKey: .achievementFirstSketch, isUnlocked: true),
        Achievement(id: 1, icon: .achievementDailyDrawerIcon, titleKey: .achievementDailyDrawer, isUnlocked: true),
        Achievement(id: 2, icon: .achievementPhotoMasterIcon, titleKey: .achievementPhotoMaster, isUnlocked: true),
        Achievement(id: 3, icon: .achievementGalleryKeeperIcon, titleKey: .achievementGalleryKeeper, isUnlocked: true),
        Achievement(id: 4, icon: .achievementColorExplorerIcon, titleKey: .achievementColorExplorer, isUnlocked: true),
        Achievement(id: 5, icon: .achievementSketchLearnerIcon, titleKey: .achievementSketchLearner, isUnlocked: true),
        Achievement(id: 6, icon: .achievementFocusedArtistIcon, titleKey: .achievementFocusedArtist, isUnlocked: true),
        Achievement(id: 7, icon: .achievementSpeedSketcherIcon, titleKey: .achievementSpeedSketcher, isUnlocked: true),
        Achievement(id: 8, icon: .achievementPerfectTraceIcon, titleKey: .achievementPerfectTrace, isUnlocked: false),
        Achievement(id: 9, icon: .achievementCollectionMasterIcon, titleKey: .achievementCollectionMaster, isUnlocked: false),
        Achievement(id: 10, icon: .achievementLineArtistIcon, titleKey: .achievementLineArtist, isUnlocked: false),
        Achievement(id: 11, icon: .achievementSkillAchieverIcon, titleKey: .achievementSkillAchiever, isUnlocked: false),
        Achievement(id: 12, icon: .achievementDetailDetectiveIcon, titleKey: .achievementDetailDetective, isUnlocked: false),
        Achievement(id: 13, icon: .achievementTemplateCollectorIcon, titleKey: .achievementTemplateCollector, isUnlocked: false),
        Achievement(id: 14, icon: .achievementUploadProIcon, titleKey: .achievementUploadPro, isUnlocked: false),
        Achievement(id: 15, icon: .achievementTimelapseCreatorIcon, titleKey: .achievementTimelapseCreator, isUnlocked: false),
        Achievement(id: 16, icon: .achievementConsistencyKingIcon, titleKey: .achievementConsistencyKing, isUnlocked: false),
        Achievement(id: 17, icon: .achievementInspirationSeekerIcon, titleKey: .achievementInspirationSeeker, isUnlocked: false),
        Achievement(id: 18, icon: .achievementCreativeWizardIcon, titleKey: .achievementCreativeWizard, isUnlocked: false),
        Achievement(id: 19, icon: .achievementPracticeProIcon, titleKey: .achievementPractivePro, isUnlocked: false),
        Achievement(id: 20, icon: .achievementMilestoneMakerIcon, titleKey: .achievementMilestoneMaker, isUnlocked: false),
        Achievement(id: 21, icon: .achievementDrawingApprenticeIcon, titleKey: .achievementDrawingApprentice, isUnlocked: false),
        Achievement(id: 22, icon: .achievementSurpriseArtistIcon, titleKey: .achievementSurpriseArtist, isUnlocked: false),
        Achievement(id: 23, icon: .achievementMasterSketcherIcon, titleKey: .achievementMasterSketcher, isUnlocked: false)
    ]

    static var unlockedCount: Int { all.count { $0.isUnlocked } }
}
