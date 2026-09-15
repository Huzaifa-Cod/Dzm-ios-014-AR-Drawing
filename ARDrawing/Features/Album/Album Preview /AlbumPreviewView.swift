//
//  AlbumPreviewView.swift
//  ARDrawing
//

import CoreData
import SwiftUI

struct AlbumPreviewView: View {
    @Environment(\.dismiss) private var dismiss
    @Environment(\.managedObjectContext) private var moc

    let sketch: SavedSketch

    /// Lets `AlbumView` drop this sketch out of its own selection state
    /// if it happened to be mid-selection when this was deleted.
    var onDelete: (() -> Void)?

    @State private var isConfirmingDelete = false

    private let pageMargin: CGFloat = 20

    var body: some View {
        VStack(spacing: 0) {
            header

            Spacer(minLength: 0)

            artwork
                .padding(.horizontal, 28.w)

            Spacer(minLength: 0)

            actions
                .padding(.horizontal, pageMargin.w)
                .padding(.bottom, 24.h)
        }
        .background(Color(app: .homeBackground).ignoresSafeArea())
        .navigationBarHidden(true)
        .confirmationDialog(
            LocalizedKey.albumDeleteConfirmTitle.localized,
            isPresented: $isConfirmingDelete,
            titleVisibility: .visible
        ) {
            Button(LocalizedKey.albumDelete.localized, role: .destructive) {
                delete()
            }
            Button(LocalizedKey.editorCancel.localized, role: .cancel) {}
        }
    }

    // MARK: Header
    /// Same white plate as `AlbumView`'s header — reaches up under the
    /// status bar and rounds off only at the bottom.

    private var header: some View {
        HStack {
            Button {
                dismiss()
            } label: {
                Image(systemName: "xmark")
                    .font(.system(size: 16.s, weight: .semibold))
                    .foregroundStyle(Color(app: .dark))
                    .frame(width: 32.s, height: 32.s)
            }
            .buttonStyle(.plain)

            Spacer(minLength: 0)

            Text(LocalizedKey.albumPreviewTitle.localized)
                .font(.app(.paytoneOne, size: 20))
                .foregroundStyle(Color(app: .dark))

            Spacer(minLength: 0)

            Color.clear.frame(width: 32.s, height: 32.s)
        }
        .padding(.horizontal, pageMargin.w)
        .padding(.top, 14.h)
        .padding(.bottom, 12.h)
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

    // MARK: Artwork
    

    private var artwork: some View {
        RoundedRectangle(cornerRadius: 28.s, style: .continuous)
            .fill(Color(app: .white))
            .frame(maxWidth: .infinity)
            .frame(height: 440.h)
            .overlay {
                sketchImage
                    .resizable()
                    .scaledToFit()
                    .padding(28.s)
            }
            .shadow(color: Color(app: .dark).opacity(0.08), radius: 20, y: 8)
    }

    private var sketchImage: Image {
        guard let uiImage = sketch.uiImage else { return Image(app: .sample1) }
        return Image(uiImage: uiImage)
    }

    // MARK: Actions

    private var actions: some View {
        VStack(spacing: 14.h) {
            Button {
                shareArtwork()
            } label: {
                HStack(spacing: 8.w) {
                    Image(.shareWhiteIcon)
                        .font(.system(size: 15.s, weight: .semibold))

                    Text(LocalizedKey.albumShareArtwork.localized)
                        .font(.app(.bold, size: 16))
                }
                .foregroundStyle(Color(app: .white))
                .frame(maxWidth: .infinity)
                .frame(height: 52.h)
                .background(Capsule().fill(Color(app: .accent)))
            }
            .buttonStyle(.plain)

            Button {
                isConfirmingDelete = true
            } label: {
                HStack(spacing: 6.w) {
                    Image(.deleteRedIcon)
                        .resizable()
                        .scaledToFit()
                        .frame(width: 15.s, height: 15.s)

                    Text(LocalizedKey.albumDelete.localized)
                        .font(.app(.bold, size: 15))
                }
                .foregroundStyle(Color(app: .redAccent))
            }
            .buttonStyle(.plain)
        }
    }

    private func shareArtwork() {
        guard let uiImage = sketch.uiImage else { return }
        let activityController = UIActivityViewController(
            activityItems: [uiImage],
            applicationActivities: nil
        )
        UIApplication.shared.connectedScenes
            .compactMap { ($0 as? UIWindowScene)?.keyWindow }
            .first?
            .rootViewController?
            .present(activityController, animated: true)
    }

    private func delete() {
        SketchStore.delete([sketch], in: moc)
        onDelete?()
        dismiss()
    }
}
