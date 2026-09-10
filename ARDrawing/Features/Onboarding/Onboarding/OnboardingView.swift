//
//  OnboardingView.swift
//  ARDrawing
//
//  Onboarding carousel. The page indicator and the Continue button are
//  fixed chrome — they never move between pages; only the artwork and
//  the copy cross-fade as the page changes. Pages come from
//  `OnboardingPage` in AppEnums.swift.
//

import SwiftUI

struct OnboardingView: View {
    @EnvironmentObject private var router: AppRouter
    @StateObject private var viewModel = OnboardingViewModel()

    /// Fixed height of the artwork band. Keeping it fixed is what holds
    /// the page indicator in the same spot on every page.
    private let artworkHeight: CGFloat = 505

    /// Room kept free at the bottom for the floating Continue button.
    private let buttonReserve: CGFloat = 90

    var body: some View {
        ZStack(alignment: .bottom) {
            if viewModel.currentPage.layout == .titleFirst {
                communityLayout
            } else {
                standardLayout
            }

            PrimaryButton(title: LocalizedKey.onboardingContinueButton.localized) {
                withAnimation(.easeInOut(duration: 0.3)) {
                    viewModel.continueTapped(router: router)
                }
            }
            .padding(.horizontal, 20.w)
            .padding(.bottom, 12.h)
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity)
        .background(Color(app: .white).ignoresSafeArea())
        .contentShape(Rectangle())
        .gesture(swipeGesture)
        .navigationBarBackButtonHidden(true)
    }

    // MARK: Pages 1–4

    private var standardLayout: some View {
        VStack(spacing: 0) {
            OnboardingArtworkView(page: viewModel.currentPage, height: artworkHeight.h)
                .id(viewModel.currentPage)
                .transition(.opacity)

            PageIndicator(
                count: OnboardingPage.indicatorPages.count,
                currentIndex: viewModel.currentPage.rawValue
            )
            .padding(.top, 16.h)

            copy
                .id(viewModel.currentPage)
                .transition(.opacity)

            Spacer(minLength: buttonReserve.h)
        }
    }

    private var copy: some View {
        VStack(spacing: 12.h) {
            Text(viewModel.currentPage.titleKey.localized)
                .font(.app(.bold, size: 26))
                .foregroundStyle(Color(app: .dark))
                .multilineTextAlignment(.center)
                .lineSpacing(2.h)
                .padding(.horizontal, 24.w)

            if let descriptionKey = viewModel.currentPage.descriptionKey {
                Text(descriptionKey.localized)
                    .font(.app(.regular, size: 14))
                    .foregroundStyle(Color(app: .textSecondary))
                    .multilineTextAlignment(.center)
                    .lineSpacing(2.h)
                    .padding(.horizontal, 28.w)
            }
        }
        .padding(.top, 14.h)
    }

    // MARK: Page 5

    /// This artwork is exported on the full 390x844 design frame with its
    /// top left transparent for the avatars and headline, so it runs from
    /// the very top of the screen and the copy is overlaid on it.
    private var communityLayout: some View {
        // The avatars sit between the headline's shoulders in the design,
        // so the headline is pulled up into that row.
        VStack(spacing: -30.h) {
            if let topImage = viewModel.currentPage.topImage {
                Image(app: topImage)
                    .resizable()
                    .scaledToFit()
                    .frame(width: 330.w)
            }

            Text(viewModel.currentPage.titleKey.localized)
                .font(.app(.bold, size: 26))
                .foregroundStyle(Color(app: .dark))
                .multilineTextAlignment(.center)
                .lineSpacing(2.h)
                // Narrower than the other pages so the headline wraps
                // onto two lines the way the design does, keeping the
                // short first line clear of the avatar beside it.
                .frame(maxWidth: 250.w)
        }
        .padding(.top, 44.h)
        .frame(maxWidth: .infinity, maxHeight: .infinity, alignment: .top)
        .background(alignment: .top) {
            Image(app: viewModel.currentPage.image)
                .resizable()
                .aspectRatio(contentMode: .fit)
                .frame(maxWidth: .infinity)
                // Nudged down so the cards clear the headline: this screen
                // is taller than the 844pt frame the artwork was drawn on.
                .padding(.top, 20.h)
        }
        // This page is one composition laid out on the full 390x844 design
        // frame, so it starts at the very top of the screen. Only the top
        // edge is ignored, leaving the Continue button in the safe area.
        .ignoresSafeArea(edges: .top)
        .transition(.opacity)
    }

    // MARK: Swiping

    private var swipeGesture: some Gesture {
        DragGesture(minimumDistance: 20)
            .onEnded { value in
                guard abs(value.translation.width) > 50 else { return }
                withAnimation(.easeInOut(duration: 0.3)) {
                    if value.translation.width < 0 {
                        viewModel.goToNextPage()
                    } else {
                        viewModel.goToPreviousPage()
                    }
                }
            }
    }
}

//#Preview {
//    NavigationStack {
//        OnboardingView()
//    }
//    .environmentObject(AppRouter())
//}
