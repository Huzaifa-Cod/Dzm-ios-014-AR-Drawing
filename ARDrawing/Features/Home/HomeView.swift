//
//  HomeView.swift
//  ARDrawing
//

import SwiftUI

struct HomeView: View {
    @EnvironmentObject private var router: AppRouter
    @EnvironmentObject private var templateCatalog: TemplateCatalogStore

    private let pageMargin: CGFloat = 20
    private let featureCardHeight: CGFloat = 220
    private let cardRadius: CGFloat = 20
    private let tileSize: CGFloat = 140
    /// Home shows a taste of each category, not the whole thing — the
    /// full set is what the Templates tab's grid is for.
    private let rowPreviewCount = 8

    var body: some View {
        ReportingScrollView {
            VStack(alignment: .leading, spacing: 0) {
                header
                    .padding(.horizontal, pageMargin.w)
                    .padding(.top, 8.h)

                HStack(spacing: 15.w) {
                    photoReferenceCard
                    captureCard
                }
                .padding(.horizontal, pageMargin.w)
                .padding(.top, 18.h)

                stepByStepCard
                    .padding(.horizontal, pageMargin.w)
                    .padding(.top, 14.h)

                ForEach(templateCatalog.categories) { category in
                    categoryRow(category)
                        .padding(.top, 22.h)
                }
            }
            .padding(.bottom, 16.h)
        }
        .background(Color(app: .homeBackground).ignoresSafeArea())
        .onAppear { templateCatalog.loadIfNeeded() }
    }

    // MARK: Header

    private var header: some View {
        HStack(spacing: 8.w) {
            Text(LocalizedKey.appName.localized)
                .font(.app(.paytoneOne, size: 24))
                .foregroundStyle(Color(app: .dark))

            Spacer(minLength: 8.w)

            StreakPill()
            ProPill()
        }
    }

    // MARK: Feature cards

    private var photoReferenceCard: some View {
        featureCardShell(background: .photoRefBgImg) {
            VStack(alignment: .leading, spacing: 0) {
                Text(LocalizedKey.homePhotoReferenceTitle.localized)
                    .font(.app(.bold, size: 16))
                    .foregroundStyle(Color(app: .white))
                    .multilineTextAlignment(.leading)
                    .padding(.horizontal, 14.w)
                    .padding(.top, 14.h)

                Spacer(minLength: 0)

                Image(app: .photoRefImg)
                    .resizable()
                    .scaledToFit()
                    .frame(width: 139.w)
                    .frame(maxWidth: .infinity, alignment: .center)
                    .padding(.bottom, 18.h)
            }
        }
    }

    private var captureCard: some View {
        featureCardShell(background: .capBgImg) {
            VStack(alignment: .leading, spacing: 0) {
                Text(LocalizedKey.homeCaptureTitle.localized)
                    .font(.app(.bold, size: 16))
                    .foregroundStyle(Color(app: .dark))
                    .padding(.horizontal, 14.w)
                    .padding(.top, 14.h)

                Spacer(minLength: 0)

                Image(app: .capImg)
                    .resizable()
                    .scaledToFit()
                    .frame(width: 113.w)
                    .frame(maxWidth: .infinity, alignment: .center)
                    .padding(.bottom, 10.h)
            }
        }
    }

    /// Both top cards are the same box with a full-bleed artwork behind
    /// whatever sits on top. Width is flexible — the enclosing HStack
    /// splits the row evenly between the two — so they fill the row edge
    /// to edge on any screen instead of sitting at a fixed phone width
    /// with space left over on a tablet.
    private func featureCardShell<Content: View>(
        background: AppImage,
        @ViewBuilder content: () -> Content
    ) -> some View {
        content()
            .frame(maxWidth: .infinity)
            .frame(height: featureCardHeight.h)
            .background {
                Image(app: background)
                    .resizable()
                    .scaledToFill()
            }
            .clipShape(RoundedRectangle(cornerRadius: cardRadius.s, style: .continuous))
    }

    // MARK: Step by step

    private var stepByStepCard: some View {
        HStack(spacing: 0) {
            VStack(alignment: .leading, spacing: 4.h) {
                Text(LocalizedKey.homeStepByStepTitle.localized)
                    .font(.app(.bold, size: 16))
                    .foregroundStyle(Color(app: .dark))

                Text(LocalizedKey.homeStepByStepSubtitle.localized)
                    .font(.app(.regular, size: 13))
                    .foregroundStyle(Color(app: .textSecondary))
            }
            .padding(.leading, 18.w)

            Spacer(minLength: 8.w)

            // Bleeds to the card's trailing edge, as in the design.
            VideoLoopView(resource: "sketching")
                .frame(width: 112.w)
        }
        .frame(height: 92.h)
        .background(Color(app: .white))
        .clipShape(RoundedRectangle(cornerRadius: cardRadius.s, style: .continuous))
    }

    // MARK: Artwork rows

    private func categoryRow(_ category: TemplateCategoryData) -> some View {
        VStack(alignment: .leading, spacing: 12.h) {
            HStack {
                Text(category.categoryName)
                    .font(.app(.paytoneOne, size: 18))
                    .foregroundStyle(Color(app: .dark))

                Spacer()

                Button {
                    // Destination lands with the templates screen.
                } label: {
                    Text(LocalizedKey.homeSeeAll.localized)
                        .font(.app(.medium, size: 14))
                        .foregroundStyle(Color(app: .accent))
                }
            }
            .padding(.horizontal, pageMargin.w)

            if category.imageCount > 0 {
                ScrollView(.horizontal, showsIndicators: false) {
                    HStack(spacing: 12.w) {
                        ForEach(1...min(category.imageCount, rowPreviewCount), id: \.self) { index in
                            Button {
                                selectTemplate(category: category, index: index)
                            } label: {
                                tile(category: category, index: index)
                            }
                            .buttonStyle(.plain)
                        }
                    }
                    .padding(.horizontal, pageMargin.w)
                }
            }
        }
    }

    private func tile(category: TemplateCategoryData, index: Int) -> some View {
        TemplateThumbnailView(category: category, index: index, cornerRadius: cardRadius)
            .frame(width: tileSize.w, height: tileSize.w)
    }

    /// By the time a thumbnail is visible to tap, it has already
    /// resolved (and cached) its URL — this is a synchronous lookup,
    /// not a fresh Storage round trip.
    private func selectTemplate(category: TemplateCategoryData, index: Int) {
        guard let url = templateCatalog.cachedImageURL(category: category, index: index) else {
            print("[HomeView] No resolved URL yet for \(category.folderName) #\(index) — ignoring tap.")
            return
        }
        router.push(.drawModeSelection(templateURL: url))
    }
}

#Preview {
    HomeView()
}
