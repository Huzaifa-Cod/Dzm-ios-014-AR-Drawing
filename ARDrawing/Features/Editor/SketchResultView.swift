//
//  SketchResultView.swift
//  ARDrawing

import SwiftUI

/// Where a finished drawing lands: the sketch on its own, with the ways
/// to keep it — saved to the album already, downloadable, shareable.
struct SketchResultView: View {
    @EnvironmentObject private var router: AppRouter
    @Environment(\.managedObjectContext) private var moc
    @Environment(\.dismiss) private var dismiss

    let sketchID: UUID

    @State private var image: UIImage?
    @State private var isSavedToastVisible = false

    private let cardRadius: CGFloat = 24

    var body: some View {
        VStack(spacing: 0) {
            header

            Spacer(minLength: 8.h)

            sketchCard
                .padding(.horizontal, 28.w)

            Text(LocalizedKey.resultTitle.localized)
                .font(.app(.paytoneOne, size: 24))
                .foregroundStyle(Color(app: .dark))
                .multilineTextAlignment(.center)
                .padding(.top, 26.h)

            Text(LocalizedKey.resultSubtitle.localized)
                .font(.app(.regular, size: 13))
                .foregroundStyle(Color(app: .textSecondary))
                .multilineTextAlignment(.center)
                .lineSpacing(3.h)
                .padding(.top, 8.h)
                .padding(.horizontal, 28.w)

            Spacer(minLength: 12.h)

            actions
                .padding(.horizontal, 24.w)
                .padding(.bottom, 12.h)
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity)
        .background {
            Image(app: .tutorialOnboardBgImg)
                .resizable()
                .scaledToFill()
                .ignoresSafeArea()
        }
        .overlay { ConfettiView() }
        .overlay { savedToast }
        .toolbar(.hidden, for: .navigationBar)
        .onAppear(perform: loadSketch)
    }

    // MARK: Header

    private var header: some View {
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

            Text("🎉")
                .font(.system(size: 22.s))

            Spacer(minLength: 0)

            // Balances the chevron so the emoji stays centred.
            Color.clear.frame(width: 15.s, height: 15.s)
        }
        .padding(.horizontal, 20.w)
        .padding(.top, 10.h)
    }

    // MARK: Sketch

    private var sketchCard: some View {
        Group {
            if let image {
                Image(uiImage: image)
                    .resizable()
                    .scaledToFit()
                    .padding(18.s)
            } else {
                ProgressView()
            }
        }
        .frame(maxWidth: .infinity)
        .aspectRatio(1, contentMode: .fit)
        .background(
            RoundedRectangle(cornerRadius: cardRadius.s, style: .continuous)
                .fill(Color(app: .white))
        )
        .clipShape(RoundedRectangle(cornerRadius: cardRadius.s, style: .continuous))
        .shadow(color: .black.opacity(0.12), radius: 20.s, y: 10.h)
    }

    // MARK: Actions

    private var actions: some View {
        VStack(spacing: 12.h) {
            HStack(spacing: 12.w) {
                Button(action: downloadSketch) {
                    actionLabel(
                        title: LocalizedKey.resultDownload.localized,
                        systemImage: "arrow.down.to.line",
                        isFilled: true
                    )
                }
                .buttonStyle(.plain)
                .disabled(image == nil)
                .opacity(image == nil ? 0.5 : 1)

                if let image {
                    ShareLink(
                        item: Image(uiImage: image),
                        preview: SharePreview(
                            LocalizedKey.resultTitle.localized,
                            image: Image(uiImage: image)
                        )
                    ) {
                        actionLabel(
                            title: LocalizedKey.resultShare.localized,
                            systemImage: "square.and.arrow.up",
                            isFilled: false
                        )
                    }
                    .buttonStyle(.plain)
                }
            }

            // Reads as a real button against the patterned backdrop,
            // but stays quieter than Download/Share above it.
            Button {
                router.replaceStack(with: .home)
            } label: {
                HStack(spacing: 8.w) {
                    Image(systemName: "house.fill")
                        .font(.system(size: 14.s, weight: .semibold))

                    Text(LocalizedKey.resultDone.localized)
                        .font(.app(.semiBold, size: 16))
                }
                .foregroundStyle(Color(app: .dark))
                .frame(maxWidth: .infinity)
                .frame(height: 52.h)
                .background(
                    RoundedRectangle(cornerRadius: 16.s, style: .continuous)
                        .fill(Color(app: .white).opacity(0.9))
                )
                .overlay(
                    RoundedRectangle(cornerRadius: 16.s, style: .continuous)
                        .stroke(Color(app: .dark).opacity(0.12), lineWidth: 1)
                )
            }
            .buttonStyle(.plain)
        }
    }

    private func actionLabel(title: String, systemImage: String, isFilled: Bool) -> some View {
        HStack(spacing: 8.w) {
            Image(systemName: systemImage)
                .font(.system(size: 15.s, weight: .semibold))

            Text(title)
                .font(.app(.semiBold, size: 16))
        }
        .foregroundStyle(isFilled ? Color(app: .white) : Color(app: .accent))
        .frame(maxWidth: .infinity)
        .frame(height: 56.h)
        .background(
            RoundedRectangle(cornerRadius: 16.s, style: .continuous)
                .fill(isFilled ? Color(app: .accent) : Color(app: .white))
        )
        .overlay(
            RoundedRectangle(cornerRadius: 16.s, style: .continuous)
                .stroke(Color(app: .accent).opacity(isFilled ? 0 : 0.35), lineWidth: 1)
        )
    }

    // MARK: Toast

    private var savedToast: some View {
        VStack {
            if isSavedToastVisible {
                HStack(spacing: 8.w) {
                    Text("🎉")
                        .font(.system(size: 16.s))

                    Text(LocalizedKey.editorPhotoSavedToast.localized)
                        .font(.app(.semiBold, size: 14))
                        .foregroundStyle(Color(app: .dark))
                }
                .padding(.horizontal, 16.w)
                .frame(height: 44.h)
                .background(Capsule().fill(Color(app: .white)))
                .shadow(color: .black.opacity(0.2), radius: 12.s, y: 6.h)
                .padding(.top, 8.h)
                .transition(.move(edge: .top).combined(with: .opacity))
            }

            Spacer(minLength: 0)
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity)
        .allowsHitTesting(false)
    }

    // MARK: Actions

    private func loadSketch() {
        image = SketchStore.sketch(with: sketchID, in: moc)?.uiImage
    }

    private func downloadSketch() {
        guard let image else { return }
        UIImageWriteToSavedPhotosAlbum(image, nil, nil, nil)

        withAnimation(.spring(response: 0.4, dampingFraction: 0.75)) {
            isSavedToastVisible = true
        }
        DispatchQueue.main.asyncAfter(deadline: .now() + 1.8) {
            withAnimation(.easeOut(duration: 0.25)) { isSavedToastVisible = false }
        }
    }
}
