//
//  DrawModeSelectionView.swift
//  ARDrawing


import SwiftUI

struct DrawModeSelectionView: View {
    @EnvironmentObject private var router: AppRouter
    @Environment(\.dismiss) private var dismiss
    /// `nil` only in the instant SwiftUI hands back control mid-gesture;
    /// every read falls back to `.phone` via `currentMode`.
    @State private var scrolledID: DrawMode?

    private let pageMargin: CGFloat = 24
    private let cardRadius: CGFloat = 26
    /// Width : height of the card itself — tall, like a phone screen.
    private let cardAspect: CGFloat = 0.72
    /// How much of a neighbouring card peeks in at each side.
    private let peekInset: CGFloat = 30

    private var currentMode: DrawMode { scrolledID ?? .phone }

    var body: some View {
        VStack(spacing: 0) {
            header

            Spacer(minLength: 0)

            videoCarousel

            PageIndicator(count: DrawMode.allCases.count, currentIndex: currentMode.rawValue)
                .padding(.top, 22.h)

            modeSummary
                .padding(.top, 20.h)
                .padding(.horizontal, 24.w)

            Spacer(minLength: 0)

            PrimaryButton(title: LocalizedKey.drawModeContinueButton.localized) {
                router.push(.editor(mode: currentMode))
            }
            .padding(.horizontal, pageMargin.w)
            .padding(.bottom, 12.h)
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity)
        .screenGradientBackground()
        .navigationBarHidden(true)
    }

    // MARK: Header
    /// Same white plate as Album's header — reaches up under the status
    /// bar and rounds off only at the bottom — but with the title
    /// centred and the back button overlaid on top rather than sitting
    /// in the same row.

    private var header: some View {
        ZStack {
            Text(LocalizedKey.drawModeSelectTitle.localized)
                .font(.app(.paytoneOne, size: 20))
                .foregroundStyle(Color(app: .dark))
                .frame(maxWidth: .infinity)

            HStack {
                Button {
                    dismiss()
                } label: {
                    Image(systemName: "chevron.left")
                        .font(.system(size: 15.s, weight: .bold))
                        .foregroundStyle(Color(app: .dark))
                }
                .buttonStyle(.plain)

                Spacer(minLength: 0)
            }
        }
        .padding(.horizontal, 20.w)
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

    // MARK: Carousel

    /// A paged, edge-peeking carousel: the current card sits centred with
    /// its neighbours' edges visible either side (only on the trailing
    /// side for the first card, both sides in between — exactly what
    /// falls out of centring a card narrower than the row).
    private var videoCarousel: some View {
        GeometryReader { geo in
            let cardWidth = geo.size.width - peekInset.w * 2
            let cardHeight = cardWidth / cardAspect

            ScrollView(.horizontal) {
                LazyHStack(spacing: 14.w) {
                    ForEach(DrawMode.allCases) { mode in
                        videoPlaceholder(radius: cardRadius.s)
                            .frame(width: cardWidth, height: cardHeight)
                            .id(mode)
                    }
                }
                .scrollTargetLayout()
            }
            .safeAreaPadding(.horizontal, peekInset.w)
            .scrollTargetBehavior(.viewAligned)
            .scrollPosition(id: $scrolledID)
            .scrollIndicators(.hidden)
            .frame(height: cardHeight)
            .frame(maxHeight: .infinity, alignment: .center)
        }
        // Reserves the tallest the card ever gets so the chrome below
        // never moves as the available width (and so the card size)
        // changes with the device.
        .frame(height: (ScreenSize.screenWidth - peekInset.w * 2) / cardAspect)
        .onAppear { scrolledID = .phone }
    }

    /// Double border: a soft tinted halo behind a smaller white card with
    /// a solid accent outline, matching the reference exactly.
    private func videoPlaceholder(radius: CGFloat) -> some View {
        let inset: CGFloat = 8.s

        return RoundedRectangle(cornerRadius: radius + inset / 2, style: .continuous)
            .fill(Color(app: .accent).opacity(0.12))
            .overlay {
                RoundedRectangle(cornerRadius: radius, style: .continuous)
                    .fill(Color(app: .white))
                    .overlay(
                        RoundedRectangle(cornerRadius: radius, style: .continuous)
                            .stroke(Color(app: .accent), lineWidth: 2)
                    )
                    .overlay {
                        Image(systemName: "play.circle.fill")
                            .font(.system(size: 46.s, weight: .regular))
                            .foregroundStyle(Color(app: .dotInactive))
                    }
                    .padding(inset)
            }
            .shadow(color: Color(app: .dark).opacity(0.06), radius: 12.s, y: 6.h)
    }

    // MARK: Copy

    private var modeSummary: some View {
        VStack(spacing: 8.h) {
            HStack(spacing: 8.w) {
                Image(app: currentMode.icon)
                    .resizable()
                    .scaledToFit()
                    .frame(width: 20.s, height: 20.s)
                    .foregroundStyle(Color(app: .dark))

                Text(currentMode.titleKey.localized)
                    .font(.app(.paytoneOne, size: 20))
                    .foregroundStyle(Color(app: .dark))
            }

            Text(LocalizedKey.drawModeDescription.localized)
                .font(.app(.regular, size: 13))
                .foregroundStyle(Color(app: .textSecondary))
                .multilineTextAlignment(.center)
                .lineSpacing(2.h)
        }
        .id(currentMode)
        .transition(.opacity)
        .animation(.easeInOut(duration: 0.2), value: currentMode)
    }
}

//#Preview {
//    DrawModeSelectionView()
//}
