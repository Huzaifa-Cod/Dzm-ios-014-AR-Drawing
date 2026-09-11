//
//  TemplatesView.swift
//  ARDrawing
//
//  Browse screen: search, category filter chips, and a grid of templates
//  fetched from Firebase Storage via `TemplateCatalogStore`.
//

import SwiftUI

struct TemplatesView: View {
    @EnvironmentObject private var router: AppRouter
    @EnvironmentObject private var templateCatalog: TemplateCatalogStore
    @State private var searchText = ""
    @State private var selectedCategory: TemplateCategoryData?

    private let pageMargin: CGFloat = 20
    private let gridSpacing: CGFloat = 12
    private let tileRadius: CGFloat = 16

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

    private var activeCategory: TemplateCategoryData? {
        selectedCategory ?? templateCatalog.categories.first
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
                if let category = activeCategory, category.imageCount > 0 {
                    LazyVGrid(columns: columns, spacing: gridSpacing.h) {
                        ForEach(1...category.imageCount, id: \.self) { index in
                            Button {
                                selectTemplate(category: category, index: index)
                            } label: {
                                tile(category: category, index: index)
                            }
                            .buttonStyle(.plain)
                        }
                    }
                    .padding(.horizontal, pageMargin.w)
                    .padding(.top, 16.h)
                    .padding(.bottom, 16.h)
                    // A fresh identity per category, not just fresh data —
                    // without this, switching categories reuses the same
                    // grid-cell views (both categories fill the same
                    // 1...imageCount indices), so the old thumbnails'
                    // already-resolved URLs kept showing while the new
                    // ones raced to load in underneath, which is exactly
                    // the "mixed templates for a moment" glitch. Forcing
                    // a new identity throws the old grid away outright —
                    // the crossfade below then swaps it cleanly for an
                    // entirely fresh one.
                    .id(category.id)
                    .transition(.opacity)
                }
            }
            .animation(.easeInOut(duration: 0.22), value: activeCategory?.id)
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity)
        .background(Color(app: .homeBackground).ignoresSafeArea())
        .onAppear { templateCatalog.loadIfNeeded() }
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
                ForEach(templateCatalog.categories) { category in
                    chip(for: category)
                }
            }
            .padding(.horizontal, pageMargin.w)
        }
    }

    private func chip(for category: TemplateCategoryData) -> some View {
        let isSelected = activeCategory?.id == category.id

        return Button {
            selectedCategory = category
        } label: {
            Text(category.categoryName)
                .font(.app(.semiBold, size: 15))
                .foregroundStyle(isSelected ? Color(app: .white) : Color(app: .dark))
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

    private func tile(category: TemplateCategoryData, index: Int) -> some View {
        TemplateThumbnailView(category: category, index: index, cornerRadius: tileRadius)
            .aspectRatio(1, contentMode: .fit)
    }

    /// By the time a thumbnail is visible to tap, it has already
    /// resolved (and cached) its URL — this is a synchronous lookup,
    /// not a fresh Storage round trip.
    private func selectTemplate(category: TemplateCategoryData, index: Int) {
        guard let url = templateCatalog.cachedImageURL(category: category, index: index) else {
            print("[TemplatesView] No resolved URL yet for \(category.folderName) #\(index) — ignoring tap.")
            return
        }
        router.push(.drawModeSelection(templateURL: url))
    }
}

//#Preview {
//    TemplatesView()
//}
