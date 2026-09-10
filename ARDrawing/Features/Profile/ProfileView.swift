//
//  ProfileView.swift
//  ARDrawing
//


import SwiftUI

struct ProfileView: View {
    
    @EnvironmentObject private var router: AppRouter
    
    private let summary = ProfileSummary.placeholder

    private let pageMargin: CGFloat = 20
    private let cardRadius: CGFloat = 20

    private let levelCardHeight: CGFloat = 70
    private let thumbnailSize: CGFloat = 78
    private let lessonTile = CGSize(width: 118, height: 106)

    var body: some View {
        ReportingScrollView {
            VStack(spacing: 14.h) {
                header
                levelCard
                statsCard
                albumCard
                lessonsCard
            }
            .padding(.horizontal, pageMargin.w)
            .padding(.top, 8.h)
            .padding(.bottom, 16.h)
        }
        .background(Color(app: .homeBackground).ignoresSafeArea())
    }

    // MARK: Header

    private var header: some View {
        HStack(spacing: 8.w) {
            Text(LocalizedKey.profileTitle.localized)
                .font(.app(.paytoneOne, size: 24))
                .foregroundStyle(Color(app: .dark))

            Spacer(minLength: 8.w)

            StreakPill()
            ProPill()
        }
    }

    // MARK: Level

    private var levelCard: some View {
        HStack(spacing: 12.w) {
            Image(app: .levelBadge)
                .resizable()
                .scaledToFit()
                .frame(width: 50.s, height: 50.s)

            VStack(alignment: .leading, spacing: 1.h) {
                Text(LocalizedKey.profileCurrentLevel.localized)
                    .font(.app(.regular, size: 12))
                    .foregroundStyle(Color(app: .white).opacity(0.75))

                Text(summary.levelName)
                    .font(.app(.bold, size: 18))
                    .foregroundStyle(Color(app: .white))
            }

            Spacer(minLength: 8.w)

            seeMoreButton
        }
        .padding(.horizontal, 14.w)
        .frame(height: levelCardHeight.h)
        .background {
            Image(app: .topViewBackView)
                .resizable()
                .scaledToFill()
        }
        .clipShape(RoundedRectangle(cornerRadius: 16.s, style: .continuous))
    }

    private var seeMoreButton: some View {
        Button {
            // Level detail lands with the lessons work.
        } label: {
            HStack(spacing: 4.w) {
                Text(LocalizedKey.profileSeeMore.localized)
                    .font(.app(.semiBold, size: 13))

                Image(systemName: "chevron.right")
                    .font(.system(size: 10.s, weight: .bold))
            }
            .foregroundStyle(Color(app: .white))
            .padding(.horizontal, 12.w)
            .frame(height: 30.h)
            .background(Capsule().fill(Color(app: .white).opacity(0.22)))
        }
        .buttonStyle(.plain)
    }

    // MARK: Stats

    private var statsCard: some View {
        HStack(spacing: 0) {
            ForEach(ProfileStat.allCases) { stat in
                VStack(spacing: 8.h) {
                    Image(app: stat.icon)
                        .resizable()
                        .scaledToFit()
                        .frame(height: ProfileStat.iconHeight.s)

                    Text(summary.value(for: stat))
                        .font(.app(.bold, size: 18))
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

    // MARK: Album

    private var albumCard: some View {
        VStack(alignment: .leading, spacing: 14.h) {
            Button {
                router.push(.album)
            } label: {
                sectionHeader(
                    title: LocalizedKey.profileAlbumTitle.localized,
                    subtitle: LocalizedKey.profileAlbumSubtitle.localized
                )
            }
            .buttonStyle(.plain)
           

            HStack(spacing: 10.w) {
                ForEach(0..<3, id: \.self) { _ in
                    Image(app: .sample1)
                        .resizable()
                        .scaledToFit()
                        .padding(6.s)
                        .frame(width: thumbnailSize.w, height: thumbnailSize.w)
                        .background(
                            RoundedRectangle(cornerRadius: 14.s, style: .continuous)
                                .fill(Color(app: .white))
                        )
                        .overlay(
                            RoundedRectangle(cornerRadius: 14.s, style: .continuous)
                                .stroke(Color(app: .dark).opacity(0.08), lineWidth: 1)
                        )
                }

                Spacer(minLength: 0)
            }

            uploadButton
        }
        .padding(16.w)
        .frame(maxWidth: .infinity, alignment: .leading)
        .background(cardBackground)
    }

    private var uploadButton: some View {
        Button {
            // Photo picker lands with the album work.
        } label: {
            HStack(spacing: 8.w) {
                Image(app: .uploadIcon)
                    .resizable()
                    .scaledToFit()
                    .frame(width: 23.s, height: 15.s)

                Text(LocalizedKey.profileUploadDrawing.localized)
                    .font(.app(.semiBold, size: 15))
                    .foregroundStyle(Color(app: .accent))
            }
            .frame(maxWidth: .infinity)
            .frame(height: 48.h)
            .background(
                RoundedRectangle(cornerRadius: 14.s, style: .continuous)
                    .fill(Color(app: .accent).opacity(0.05))
            )
            .overlay(
                RoundedRectangle(cornerRadius: 14.s, style: .continuous)
                    .strokeBorder(
                        Color(app: .accent).opacity(0.45),
                        style: StrokeStyle(lineWidth: 1.2, dash: [6, 4])
                    )
            )
        }
        .buttonStyle(.plain)
    }

    // MARK: Lessons

    private var lessonsCard: some View {
        VStack(alignment: .leading, spacing: 14.h) {
            sectionHeader(
                title: LocalizedKey.profileLessonsTitle.localized,
                subtitle: LocalizedKey.profileLessonsSubtitle.localized
            )
            .padding(.horizontal, 16.w)

            ScrollView(.horizontal, showsIndicators: false) {
                HStack(spacing: 10.w) {
                    ForEach(0..<4, id: \.self) { _ in
                        lessonTileView
                    }
                }
                .padding(.horizontal, 16.w)
            }
        }
        .padding(.vertical, 16.h)
        .frame(maxWidth: .infinity, alignment: .leading)
        .background(cardBackground)
    }

    private var lessonTileView: some View {
        Image(app: .sample1)
            .resizable()
            .scaledToFit()
            .padding(8.s)
            .frame(width: lessonTile.width.w, height: lessonTile.height.h)
            .background(
                RoundedRectangle(cornerRadius: 14.s, style: .continuous)
                    .fill(Color(app: .white))
            )
            .overlay(
                RoundedRectangle(cornerRadius: 14.s, style: .continuous)
                    .stroke(Color(app: .dark).opacity(0.08), lineWidth: 1)
            )
            .overlay(alignment: .topTrailing) {
                // Stand-in for the in-progress badge until the icon is
                // exported — see the note in the handover.
                Image(systemName: "arrow.trianglehead.clockwise")
                    .font(.system(size: 11.s, weight: .bold))
                    .foregroundStyle(Color(app: .white))
                    .frame(width: 22.s, height: 22.s)
                    .background(Circle().fill(Color(app: .proOrange)))
                    .padding(8.s)
            }
    }

    // MARK: Shared pieces

    private func sectionHeader(title: String, subtitle: String) -> some View {
        HStack(alignment: .top, spacing: 8.w) {
            VStack(alignment: .leading, spacing: 3.h) {
                Text(title)
                    .font(.app(.bold, size: 17))
                    .foregroundStyle(Color(app: .dark))

                Text(subtitle)
                    .font(.app(.regular, size: 13))
                    .foregroundStyle(Color(app: .textSecondary))
            }

            Spacer(minLength: 0)

            Image(systemName: "chevron.right")
                .font(.system(size: 13.s, weight: .semibold))
                .foregroundStyle(Color(app: .textSecondary))
                .padding(.top, 2.h)
        }
    }

    private var cardBackground: some View {
        RoundedRectangle(cornerRadius: cardRadius.s, style: .continuous)
            .fill(Color(app: .white))
    }
}
