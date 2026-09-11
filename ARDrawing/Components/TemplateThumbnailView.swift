//
//  TemplateThumbnailView.swift
//  ARDrawing
//
//  One template tile, shared by Home's category rows and the Templates
//  grid: resolves the image's real download URL from Firebase Storage
//  (auth required, extension not guaranteed — see
//  TemplateCatalogStore.resolveImageURL), showing an activity spinner
//  until the URL and then the image land. Load outcomes are logged so
//  a bad prefix/index/permissions issue is obvious in the console
//  rather than a silent blank tile.
//
//  The URL itself is cached by the store (in memory and across
//  launches), and `initialURL` seeds state straight from that cache —
//  so a cell that's already resolved once (this session or a past
//  one) never flashes the spinner again, whether that's because a
//  LazyVGrid recycled it on scroll or the app was relaunched. SDWebImage
//  then serves the actual bytes from its own disk cache just as fast.
//

import SDWebImageSwiftUI
import SwiftUI

struct TemplateThumbnailView: View {
    let category: TemplateCategoryData
    let index: Int
    var cornerRadius: CGFloat = 16

    @EnvironmentObject private var templateCatalog: TemplateCatalogStore
    @State private var resolvedURL: URL?
    @State private var didFailToResolve = false
    /// Bumped to force a fresh `.task` run after invalidating a stale
    /// cached URL — see `onFailure` below.
    @State private var retryToken = 0

    private var initialURL: URL? {
        templateCatalog.cachedImageURL(category: category, index: index)
    }

    var body: some View {
        Group {
            if let resolvedURL {
                WebImage(url: resolvedURL) { image in
                    image
                        .resizable()
                        .scaledToFill()
                } placeholder: {
                    Color(app: .homeBackground)
                }
                .onSuccess { _, _, _ in
                    print("[TemplateThumbnailView] Loaded \(category.folderName)/\(resolvedURL.lastPathComponent)")
                }
                .onFailure { error in
                    print("[TemplateThumbnailView] FAILED to download \(resolvedURL.absoluteString) — \(error.localizedDescription); invalidating cached URL and retrying once")
                    templateCatalog.invalidateResolvedURL(category: category, index: index)
                    self.resolvedURL = nil
                    retryToken += 1
                }
                .indicator(.activity)
                .transition(.fade(duration: 0.2))
            } else {
                Color(app: .homeBackground)
                    .overlay {
                        if didFailToResolve {
                            Image(systemName: "photo")
                                .foregroundStyle(Color(app: .textSecondary))
                        } else {
                            ProgressView()
                        }
                    }
            }
        }
        .background(Color(app: .white))
        .clipShape(RoundedRectangle(cornerRadius: cornerRadius.s, style: .continuous))
        .onAppear {
            // Seeds instantly, before `.task` even runs, on every cache
            // hit — the whole point being that a repeat appearance
            // never shows the spinner it showed the first time.
            if resolvedURL == nil, let initialURL {
                resolvedURL = initialURL
            }
        }
        .task(id: "\(category.folderName)-\(index)-\(retryToken)") {
            guard resolvedURL == nil else { return }
            resolvedURL = await templateCatalog.resolveImageURL(category: category, index: index)
            didFailToResolve = resolvedURL == nil
        }
    }
}
