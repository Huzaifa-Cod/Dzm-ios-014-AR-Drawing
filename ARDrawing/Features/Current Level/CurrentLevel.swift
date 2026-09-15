//
//  CurrentLevel.swift
//  ARDrawing

import Foundation
import SwiftUI


enum LevelStageStatus: Equatable {
    case completed
    case inProgress(percent: Int)
    case locked
}

/// One of the four rungs in the ladder row.
struct LevelStage: Identifiable {
    let id: Int
    let titleKey: LocalizedKey
    let status: LevelStageStatus
}

/// Everything the Learning Level screen needs. Placeholder until levels
/// are computed from real usage data.
struct LearningLevelSummary {
    let levelNumber: Int
    let levelName: String
    let stages: [LevelStage]
    
    static let placeholder = LearningLevelSummary(
        levelNumber: 1,
        levelName: "New Learner",
        stages: [
            LevelStage(id: 0, titleKey: .learningLevelStageNewLearner, status: .completed),
            LevelStage(id: 1, titleKey: .learningLevelStageSketchBeginner, status: .inProgress(percent: 25)),
            LevelStage(id: 2, titleKey: .learningLevelStageCreativeExplorer, status: .locked),
            LevelStage(id: 3, titleKey: .learningLevelStageSketchEnthusiast, status: .locked)
        ]
    )
}


struct LearningLevelView: View {
    
    @EnvironmentObject private var router: AppRouter
    @Environment(\.dismiss) private var dismiss
    
    
    private let summary = LearningLevelSummary.placeholder
    private let profileSummary = ProfileSummary.placeholder
    
    private let pageMargin: CGFloat = 20
    private let cardRadius: CGFloat = 30
    private let badgeSize: CGFloat = 120
    private let stageCircleSize: CGFloat = 56
    private let levelCardMinHeight: CGFloat = 420
    
    var body: some View {
         VStack(spacing: 0) {
             header

             ScrollView {
                 VStack(spacing: 16.h) {
                     levelCard
                     statsCard
                     levelUpBanner
                 }
                 .padding(.horizontal, pageMargin.w)
                 .padding(.top, 12.h)
                 .padding(.bottom, 24.h)
             }
         }
         .background(Color(app: .homeBackground).ignoresSafeArea())
         .navigationBarHidden(true)
     }
    
    private var header: some View {
        HStack(spacing: 8.w) {
            Button {
                dismiss()
            } label: {
                HStack(spacing: 8.w) {
                    Image(systemName: "chevron.left")
                        .font(.system(size: 15.s, weight: .bold))

                    Text(LocalizedKey.learningLevelNavTitle.localized)
                        .font(.app(.paytoneOne, size: 24))
                }
                .foregroundStyle(Color(app: .dark))
            }
            .buttonStyle(.plain)

            Spacer(minLength: 8.w)
        }
        .padding(.horizontal, pageMargin.w)
        .padding(.top, 14.h)
        .padding(.bottom, 16.h)
        .frame(maxWidth: .infinity)
        .background(
            UnevenRoundedRectangle(
                topLeadingRadius: 0,
                bottomLeadingRadius: 22.s,
                bottomTrailingRadius: 22.s,
                topTrailingRadius: 0,
                style: .continuous
            )
            .fill(Color(app: .white))
            .ignoresSafeArea(edges: .top)
        )
    }

    
    // MARK: Level card
    
    private var levelCard: some View {
           VStack(spacing: 18.h) {
               VStack(spacing: 2.h) {
                   Text(LocalizedKey.profileCurrentLevel.localized)
                       .font(.app(.regular, size: 13))
                       .foregroundStyle(Color(app: .white).opacity(0.75))
                   
                   Text(summary.levelName)
                       .font(.app(.paytoneOne, size: 22))
                       .foregroundStyle(Color(app: .white))
               }
               .padding(.top, 28.h)
               
               badge

               Spacer(minLength: 0)
               stageRow
           }
           .padding(.bottom, 28.h)
           .frame(maxWidth: .infinity, minHeight: levelCardMinHeight.h)
           .background {
               ZStack {
                   Color(app: .accent)
                   Image(app: .currentLevelBg)
                       .resizable()
                       .scaledToFill()
                       .opacity(1.0)
               }
           }
           .clipShape(RoundedRectangle(cornerRadius: cardRadius.s, style: .continuous))
       }
    
    private var badge: some View {
        ZStack {
            Circle()
                .fill(Color(app: .white).opacity(0.12))
                .frame(width: (badgeSize + 40).s, height: (badgeSize + 40).s)

            Circle()
                .fill(Color(app: .white).opacity(0.14))
                .frame(width: (badgeSize + 18).s, height: (badgeSize + 18).s)

            Image(app: .levelBadgeIcon)
                .resizable()
                .scaledToFit()
                .frame(width: badgeSize.s, height: badgeSize.s)

            // Sits right on the outer glow's bottom edge, like a tag
            // clipped onto the badge rather than floating below it.
            levelPill
                .offset(y: ((badgeSize + 40) / 2).s)
        }
    }

    private var levelPill: some View {
        Text("Lvl \(summary.levelNumber)")
            .font(.app(.fredoka, size: 18))
            .foregroundStyle(Color(app: .accent))
            .padding(.horizontal, 22.w)
            .frame(height: 38.h)
            .background(Capsule().fill(Color(app: .white)))
            .shadow(color: .black.opacity(0.18), radius: 8.s, y: 3.h)
    }
    
    private var stageRow: some View {
        HStack(spacing: 14.w) {
            ForEach(summary.stages) { stage in
                stageItem(stage)
            }
        }
        .padding(.horizontal, 14.w)
        .padding(.vertical, 14.h)
        .background(
            RoundedRectangle(cornerRadius: 20.s, style: .continuous)
                .fill(Color(app: .white).opacity(0.08))
        )
        .padding(.horizontal, 12.w)
    }
    
    private func stageItem(_ stage: LevelStage) -> some View {
        VStack(spacing: 6.h) {
            ZStack(alignment: .topTrailing) {
                ZStack {
                    Circle()
                        .fill(circleFill(for: stage.status))
                        .frame(width: stageCircleSize.s, height: stageCircleSize.s)
                    
                    switch stage.status {
                    case .completed:
                        Image(app: .levelBadgeIcon)
                            .resizable()
                            .scaledToFit()
                            .frame(width: (stageCircleSize - 20).s, height: (stageCircleSize - 20).s)
                        
                    case .inProgress(let percent):
                        Circle()
                            .stroke(Color(app: .white).opacity(0.25), lineWidth: 3)
                            .frame(width: (stageCircleSize - 6).s, height: (stageCircleSize - 6).s)
                        
                        Circle()
                            .trim(from: 0, to: CGFloat(percent) / 100)
                            .stroke(Color(app: .white), style: StrokeStyle(lineWidth: 3, lineCap: .round))
                            .frame(width: (stageCircleSize - 6).s, height: (stageCircleSize - 6).s)
                            .rotationEffect(.degrees(-90))
                        
                        Text("\(percent)%")
                            .font(.app(.semiBold, size: 11))
                            .foregroundStyle(Color(app: .white))
                        
                    case .locked:
                        Image(app: .levelBadgeIcon)
                            .resizable()
                            .scaledToFit()
                            .frame(width: (stageCircleSize - 20).s, height: (stageCircleSize - 20).s)
                            .saturation(0)
                            .opacity(0.5)
                    }
                }
                
                if stage.status == .completed {
                    Image(app: .checkGreenIcon)
                        .resizable()
                        .scaledToFit()
                        .frame(width: 16.s, height: 16.s)
                        .background(Circle().fill(Color(app: .white)))
                        .offset(x: 4.s, y: -4.s)
                }
            }
            
            Text(stage.titleKey.localized)
                .font(.app(.medium, size: 11))
                .foregroundStyle(Color(app: .white).opacity(stage.status == .locked ? 0.55 : 0.9))
                .multilineTextAlignment(.center)
                .lineLimit(2)
                .frame(width: (stageCircleSize + 10).s)
        }
    }
    
    /// The earned stage stands out as a solid white disc; the rest stay
    /// as translucent tints against the card's blue.
    private func circleFill(for status: LevelStageStatus) -> Color {
        switch status {
        case .completed: return Color(app: .white)
        case .inProgress: return Color(app: .white).opacity(0.2)
        case .locked: return Color(app: .white).opacity(0.12)
        }
    }

    // MARK: Stats
    // Same three figures as ProfileView's statsCard — reuses ProfileStat
    // so the icons/labels/values stay in sync with the Profile screen.
    
    private var statsCard: some View {
        HStack(spacing: 0) {
            ForEach(ProfileStat.allCases) { stat in
                VStack(spacing: 8.h) {
                    Image(app: stat.icon)
                        .resizable()
                        .scaledToFit()
                        .frame(height: ProfileStat.iconHeight.s)
                    
                    Text(profileSummary.value(for: stat))
                        .font(.app(.paytoneOne, size: 18))
                        .foregroundStyle(Color(app: .dark))
                        .lineLimit(1)
                        .minimumScaleFactor(0.7)
                    
                    Text(stat.labelKey.localized)
                        .font(.app(.regular, size: 13))
                        .foregroundStyle(Color(app: .textSecondary))
                }
                .frame(maxWidth: .infinity)
                
                if stat != ProfileStat.allCases.last {
                    Rectangle()
                        .fill(Color(app: .dark).opacity(0.08))
                        .frame(width: 1, height: 58.h)
                }
            }
        }
        .padding(.vertical, 16.h)
        .frame(maxWidth: .infinity)
        .background(cardBackground)
    }
    
    // MARK: Level up banner
    private var levelUpBanner: some View {
        HStack(alignment: .top, spacing: 10.w) {
            Image(systemName: "mappin.circle.fill")
                .font(.system(size: 18.s, weight: .semibold))
                .foregroundStyle(Color(app: .accent))
            
            VStack(alignment: .leading, spacing: 2.h) {
                Text(LocalizedKey.howToLevelUpTitle.localized)
                    .font(.app(.semiBold, size: 14))
                    .foregroundStyle(Color(app: .accent))
                
                Text(LocalizedKey.howToLevelUpDescription.localized)
                    .font(.app(.regular, size: 12))
                    .foregroundStyle(Color(app: .accent).opacity(0.8))
            }
            
            Spacer(minLength: 0)
        }
        .padding(14.w)
        .frame(maxWidth: .infinity, alignment: .leading)
        .background(
            RoundedRectangle(cornerRadius: 14.s, style: .continuous)
                .fill(Color(app: .accent).opacity(0.08))
        )
    }
    
    private var cardBackground: some View {
        RoundedRectangle(cornerRadius: cardRadius.s, style: .continuous)
            .fill(Color(app: .white))
    }
}
