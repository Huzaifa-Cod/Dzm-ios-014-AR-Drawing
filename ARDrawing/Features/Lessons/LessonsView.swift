//
//  LessonsView.swift
//  ARDrawing
//

import SwiftUI

struct LessonsView: View {
    @State private var selectedFilter: LessonDifficulty?

    private let pageMargin: CGFloat = 20
    private let cardRadius: CGFloat = 20
    private let levelCardHeight: CGFloat = 76
    private let thumbnailSize: CGFloat = 64

    /// `nil` (All) plus every difficulty, in the order the chips read.
    private let filters: [LessonDifficulty?] = [nil] + LessonDifficulty.allCases

    private var lessons: [Lesson] {
        guard let selectedFilter else { return Lesson.placeholders }
        return Lesson.placeholders.filter { $0.difficulty == selectedFilter }
    }

    var body: some View {
        ReportingScrollView {
            VStack(spacing: 14.h) {
                header
                levelCard
                filterChips
                lessonList
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
            Text(LocalizedKey.lessonsScreenTitle.localized)
                .font(.app(.paytoneOne, size: 24))
                .foregroundStyle(Color(app: .dark))

            Spacer(minLength: 8.w)

            StreakPill()
            ProPill()
        }
    }

    // MARK: Level

    /// Same banner as Profile's, with a progress pill in place of the
    /// "See more" button — Lessons is where that progress is spent.
    private var levelCard: some View {
        HStack(spacing: 12.w) {
            Image(app: .levelBadge)
                .resizable()
                .scaledToFit()
                .frame(width: 50.s, height: 50.s)

            VStack(alignment: .leading, spacing: 1.h) {
                Text(LocalizedKey.lessonsCurrentLevel.localized)
                    .font(.app(.regular, size: 12))
                    .foregroundStyle(Color(app: .white).opacity(0.75))

                Text(ProfileSummary.placeholder.levelName)
                    .font(.app(.bold, size: 18))
                    .foregroundStyle(Color(app: .white))
            }

            Spacer(minLength: 8.w)

            Text(ProfileSummary.placeholder.lessonsProgress)
                .font(.app(.semiBold, size: 14))
                .foregroundStyle(Color(app: .white))
                .padding(.horizontal, 14.w)
                .frame(height: 30.h)
                .background(Capsule().fill(Color(app: .white).opacity(0.22)))
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

    // MARK: Filters

    private var filterChips: some View {
        HStack(spacing: 8.w) {
            ForEach(filters, id: \.self) { filter in
                filterChip(filter)
            }
        }
        .frame(maxWidth: .infinity, alignment: .leading)
    }

    private func filterChip(_ filter: LessonDifficulty?) -> some View {
        let isSelected = selectedFilter == filter
        let title = filter?.titleKey.localized ?? LocalizedKey.lessonDifficultyAll.localized

        return Button {
            selectedFilter = filter
        } label: {
            Text(title)
                .font(.app(.semiBold, size: 14))
                .foregroundStyle(isSelected ? Color(app: .white) : Color(app: .dark))
                .padding(.horizontal, 16.w)
                .frame(height: 38.h)
                .background(
                    Capsule().fill(isSelected ? Color(app: .dark) : Color(app: .white))
                )
                .overlay(
                    Capsule().stroke(Color(app: .dark).opacity(0.07), lineWidth: 1)
                )
        }
        .buttonStyle(.plain)
    }

    // MARK: Lesson list

    private var lessonList: some View {
        VStack(spacing: 12.h) {
            ForEach(lessons) { lesson in
                lessonCard(lesson)
            }
        }
    }

    private func lessonCard(_ lesson: Lesson) -> some View {
        HStack(spacing: 12.w) {
            Image(app: lesson.thumbnail)
                .resizable()
                .scaledToFill()
                .frame(width: thumbnailSize.w, height: thumbnailSize.w)
                .background(Color(app: .homeBackground))
                .clipShape(RoundedRectangle(cornerRadius: 14.s, style: .continuous))

            VStack(alignment: .leading, spacing: 5.h) {
                Text(lesson.title)
                    .font(.app(.bold, size: 16))
                    .foregroundStyle(Color(app: .dark))

                HStack(spacing: 4.w) {
                    Image(systemName: "clock")
                        .font(.system(size: 11.s, weight: .medium))
                        .foregroundStyle(Color(app: .textSecondary))

                    Text(
                        String(
                            format: LocalizedKey.lessonAvgTimeFormat.localized,
                            LocalizedKey.lessonAvgTimeValue.localized
                        )
                    )
                    .font(.app(.regular, size: 12))
                    .foregroundStyle(Color(app: .textSecondary))
                }

                difficultyTag(lesson.difficulty)
            }

            Spacer(minLength: 8.w)

            statusControl(for: lesson.progress)
        }
        .padding(12.w)
        .frame(maxWidth: .infinity, alignment: .leading)
        .background(RoundedRectangle(cornerRadius: cardRadius.s, style: .continuous).fill(Color(app: .white)))
    }

    private func difficultyTag(_ difficulty: LessonDifficulty) -> some View {
        Text(difficulty.titleKey.localized)
            .font(.app(.semiBold, size: 11))
            .foregroundStyle(Color(app: difficulty.tint))
            .padding(.horizontal, 8.w)
            .frame(height: 20.h)
            .background(
                Capsule().fill(Color(app: difficulty.tint).opacity(0.12))
            )
    }

    @ViewBuilder
    private func statusControl(for progress: LessonProgress) -> some View {
        switch progress {
        case .completed:
            HStack(spacing: 4.w) {
                Image(systemName: "checkmark")
                    .font(.system(size: 11.s, weight: .bold))
                Text(LocalizedKey.lessonStatusCompleted.localized)
                    .font(.app(.semiBold, size: 13))
            }
            .foregroundStyle(Color(app: .white))
            .padding(.horizontal, 12.w)
            .frame(height: 32.h)
            .background(Capsule().fill(Color(app: .successGreen)))

        case .unlocked, .locked:
            let isUnlocked = progress == .unlocked
            HStack(spacing: 4.w) {
                Image(systemName: "play.fill")
                    .font(.system(size: 10.s, weight: .bold))
                Text(LocalizedKey.lessonStatusStart.localized)
                    .font(.app(.semiBold, size: 13))
            }
            .foregroundStyle(isUnlocked ? Color(app: .white) : Color(app: .textSecondary))
            .padding(.horizontal, 14.w)
            .frame(height: 32.h)
            .background(Capsule().fill(isUnlocked ? Color(app: .accent) : Color(app: .dotInactive)))
            .opacity(isUnlocked ? 1 : 0.6)
        }
    }
}

//#Preview {
//    LessonsView()
//}
