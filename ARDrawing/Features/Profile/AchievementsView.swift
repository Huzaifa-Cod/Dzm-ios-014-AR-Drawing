//
//  AchievementsView.swift
//  ARDrawing
//
//  Every badge Profile only shows a preview row of — same white nav
//  plate as Album, a grid of badges instead of a photo grid.
//

import SwiftUI

struct AchievementsView: View {
    @Environment(\.dismiss) private var dismiss

    private let pageMargin: CGFloat = 20
    private let badgeRadius: CGFloat = 18

    private let columns = [
        GridItem(.flexible(), spacing: 14),
        GridItem(.flexible(), spacing: 14),
        GridItem(.flexible(), spacing: 14)
    ]

    var body: some View {
        VStack(spacing: 0) {
            header

            ReportingScrollView {
                LazyVGrid(columns: columns, spacing: 20.h) {
                    ForEach(AchievementCatalog.all) { achievement in
                        badge(achievement)
                    }
                }
                .padding(.horizontal, pageMargin.w)
                .padding(.top, 20.h)
                .padding(.bottom, 16.h)
            }
        }
        .background(Color(app: .homeBackground).ignoresSafeArea())
        .navigationBarHidden(true)
    }

    // MARK: Header

    private var header: some View {
        HStack(spacing: 8.w) {
            Button {
                dismiss()
            } label: {
                HStack(spacing: 8.w) {
                    Image(systemName: "chevron.left")
                        .font(.system(size: 15.s, weight: .bold))

                    Text(LocalizedKey.profileAchievementsTitle.localized)
                        .font(.app(.paytoneOne, size: 24))
                }
                .foregroundStyle(Color(app: .dark))
            }
            .buttonStyle(.plain)

            Spacer(minLength: 8.w)

            progressPill
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

    private var progressPill: some View {
        Text("\(AchievementCatalog.unlockedCount)/\(AchievementCatalog.all.count)")
            .font(.app(.bold, size: 14))
            .foregroundStyle(Color(app: .dark))
            .padding(.horizontal, 14.w)
            .frame(height: 34.h)
            .background(Capsule().fill(Color(app: .dark).opacity(0.06)))
    }

    // MARK: Grid

    private func badge(_ achievement: Achievement) -> some View {
        VStack(spacing: 10.h) {
            Image(app: achievement.icon)
                .resizable()
                .scaledToFit()
                .padding(16.s)
                .frame(width: 84.w, height: 84.w)
                .background(
                    RoundedRectangle(cornerRadius: badgeRadius.s, style: .continuous)
                        .fill(Color(app: .white))
                )
                .overlay(
                    RoundedRectangle(cornerRadius: badgeRadius.s, style: .continuous)
                        .stroke(
                            achievement.isUnlocked
                                ? Color(app: .accent).opacity(0.18)
                                : Color(app: .dark).opacity(0.08),
                            lineWidth: 1
                        )
                )
                .shadow(
                    color: achievement.isUnlocked ? Color(app: .accent).opacity(0.12) : .clear,
                    radius: 10.s, y: 4.h
                )
                .saturation(achievement.isUnlocked ? 1 : 0)
                .opacity(achievement.isUnlocked ? 1 : 0.45)

            Text(achievement.titleKey.localized)
                .font(.app(.semiBold, size: 13))
                .foregroundStyle(achievement.isUnlocked ? Color(app: .dark) : Color(app: .textSecondary))
                .multilineTextAlignment(.center)
                .lineLimit(2)
                .minimumScaleFactor(0.85)
        }
        .frame(maxWidth: .infinity)
    }
}

//#Preview {
//    NavigationStack {
//        AchievementsView()
//    }
//}
