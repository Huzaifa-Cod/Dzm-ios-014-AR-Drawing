//
//  TemplatesView.swift
//  ARDrawing
//
//  Browse screen: search, category filter chips, and a grid of templates.
//

import SwiftUI

struct TemplatesView: View {
    @EnvironmentObject private var router: AppRouter
    @State private var searchText = ""
    @State private var selectedCategory: TemplateCategory = .kids

    private let pageMargin: CGFloat = 20
    private let gridSpacing: CGFloat = 12
    private let tileRadius: CGFloat = 16

    /// Placeholder count until templates come from the backend.
    private let tileCount = 12

    /// 3 across on a phone; a wider screen gets more columns instead of
    /// the same 3 tiles just stretching wider (which is what made the
    /// grid still read as a phone layout on iPad).
    private var columnCount: Int {
        switch ScreenSize.screenWidth {
        case ..<600: return 3
        case ..<900: return 4
        default: return 5
        }
    }

    private var columns: [GridItem] {
        Array(
            repeating: GridItem(.flexible(), spacing: gridSpacing.w),
            count: columnCount
        )
    }

    /// Cycles the selected category's artwork to fill the grid.
    private var tiles: [AppImage] {
        let samples = selectedCategory.samples
        guard !samples.isEmpty else { return [] }
        return (0..<tileCount).map { samples[$0 % samples.count] }
    }

    var body: some View {
        VStack(spacing: 0) {
            header
                .padding(.horizontal, pageMargin.w)
                .padding(.top, 8.h)

            searchField
                .padding(.horizontal, pageMargin.w)
                .padding(.top, 18.h)

            categoryChips
                .padding(.top, 16.h)

            ReportingScrollView {
                LazyVGrid(columns: columns, spacing: gridSpacing.h) {
                    ForEach(Array(tiles.enumerated()), id: \.offset) { _, image in
                        Button {
                            router.push(.drawModeSelection)
                        } label: {
                            tile(image)
                        }
                        .buttonStyle(.plain)
                    }
                }
                .padding(.horizontal, pageMargin.w)
                .padding(.top, 16.h)
                .padding(.bottom, 16.h)
            }
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity)
        .background(Color(app: .homeBackground).ignoresSafeArea())
    }

    // MARK: Header

    private var header: some View {
        HStack(spacing: 8.w) {
            Text(LocalizedKey.templatesTitle.localized)
                .font(.app(.paytoneOne, size: 24))
                .foregroundStyle(Color(app: .dark))

            Spacer(minLength: 8.w)

            StreakPill()
            ProPill()
        }
    }

    // MARK: Search

    private var searchField: some View {
        HStack(spacing: 10.w) {
            Image(systemName: "magnifyingglass")
                .font(.system(size: 17.s, weight: .medium))
                .foregroundStyle(Color(app: .dark))

            TextField(
                "",
                text: $searchText,
                prompt: Text(LocalizedKey.templatesSearchPlaceholder.localized)
                    .foregroundColor(Color(app: .textSecondary))
            )
            .font(.app(.regular, size: 15))
            .foregroundStyle(Color(app: .dark))
            .submitLabel(.search)

            Button {
                searchText = ""
            } label: {
                Image(.crossBtn)
                    .font(.system(size: 10.s, weight: .bold))
                    .foregroundStyle(Color(app: .white))
                    .frame(width: 20.s, height: 20.s)
                    .background(Circle().fill(Color(app: .dotInactive)))
            }
            .opacity(searchText.isEmpty ? 0.6 : 1)
        }
        .padding(.horizontal, 16.w)
        .frame(height: 48.h)
        .background(
            Capsule()
            .fill(Color(app: .dark))
            .opacity(0.04)

        )
    }

    // MARK: Categories

    private var categoryChips: some View {
        ScrollView(.horizontal, showsIndicators: false) {
            HStack(spacing: 10.w) {
                ForEach(TemplateCategory.allCases) { category in
                    chip(for: category)
                }
            }
            .padding(.horizontal, pageMargin.w)
        }
    }

    private func chip(for category: TemplateCategory) -> some View {
        let isSelected = selectedCategory == category

        return Button {
            selectedCategory = category
        } label: {
            HStack(spacing: 7.w) {
                if let icon = category.icon {
                    Image(app: icon)
                        .resizable()
                        .scaledToFit()
                        .frame(width: 24.s, height: 24.s)
                }

                Text(category.titleKey.localized)
                    .font(.app(.semiBold, size: 15))
                    .foregroundStyle(isSelected ? Color(app: .white) : Color(app: .dark))
            }
            .padding(.horizontal, 18.w)
            .frame(height: 42.h)
            .background(
                Capsule().fill(isSelected ? Color(app: .dark) : Color(app: .white))
            )
            .overlay(
                Capsule().stroke(Color(app: .dark).opacity(0.07), lineWidth: 1)
            )
        }
        .buttonStyle(.plain)
    }

    // MARK: Grid

    /// Some sample artwork carries its own background, some is line art on
    /// transparency — the white plate underneath keeps the tiles readable
    /// against the page, the same way the home rows do it.
    private func tile(_ image: AppImage) -> some View {
        Color(app: .white)
            .aspectRatio(1, contentMode: .fit)
            .overlay {
                Image(app: image)
                    .resizable()
                    .scaledToFill()
            }
            .clipShape(RoundedRectangle(cornerRadius: tileRadius.s, style: .continuous))
    }
}

//#Preview {
//    TemplatesView()
//}
