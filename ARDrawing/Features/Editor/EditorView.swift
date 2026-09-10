//
//  EditorView.swift
//  ARDrawing
//
//  First screen of the tracing editor: the template floats, lockable
//  and draggable, over the live camera feed, with the opacity/
//  flip-or-eraser/record/photo/flash toolbar underneath. Each tool is a
//  stub here — this pass is the layout and the camera/lock/drag
//  mechanics, pixel-matched to the reference; the tool sheets are
//  follow-up work.
//

import SwiftUI

struct EditorView: View {
    @Environment(\.dismiss) private var dismiss

    let mode: DrawMode
    /// Template the user picked — reused as the floating art until real
    /// template data flows through.
    var template: AppImage = .sample1

    /// Locked keeps the template pinned in place, exactly like a locked
    /// layer — dragging is disabled while it's on.
    @State private var isLocked = true
    @State private var zoom: EditorZoom = .one

    /// Where the canvas sits, relative to centre. Only free to change
    /// while unlocked.
    @State private var canvasOffset: CGSize = .zero
    @State private var dragStartOffset: CGSize = .zero

    /// Last opacity the user confirmed with the checkmark.
    @State private var templateOpacity: Double = 1
    /// Live value while the slider is open — previewed on the canvas
    /// immediately, but only written back to `templateOpacity` on
    /// confirm. Cancelling just closes the sheet, which reverts the
    /// canvas to `templateOpacity` on its own.
    @State private var draftOpacity: Double = 1
    @State private var isOpacityToolActive = false
    /// Mirrors the template horizontally. Not offered in phone mode —
    /// the toolbar shows Eraser in that slot instead.
    @State private var isFlipped = false

    private let canvasRadius: CGFloat = 24

    var body: some View {
        ZStack {
            CameraPreviewView()
                .ignoresSafeArea()

            VStack(spacing: 0) {
                topBar
                    .padding(.horizontal, 20.w)
                    .padding(.top, 14.h)

                Spacer(minLength: 0)

                canvas
                    .padding(.horizontal, 28.w)

                Spacer(minLength: 0)

                zoomPills
                    .padding(.bottom, 16.h)

                if isOpacityToolActive {
                    opacitySheet
                        .transition(.move(edge: .bottom))
                } else {
                    toolbar
                        .transition(.identity)
                }
            }
            .animation(.easeInOut(duration: 0.22), value: isOpacityToolActive)
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity)
        .background(Color(app: .dark).ignoresSafeArea())
        .navigationBarHidden(true)
    }

    // MARK: Top bar
    /// Undo/redo/reset are shown at their native size — the circular
    /// white plate behind each glyph is already baked into the asset,
    /// so nothing here draws a second one on top.

    private var topBar: some View {
        HStack {
            Button {
                dismiss()
            } label: {
                Text(LocalizedKey.editorCancel.localized)
                    .font(.app(.semiBold, size: 15))
                    .foregroundStyle(Color(app: .white))
            }
            .buttonStyle(.plain)

            Spacer(minLength: 0)

            HStack(spacing: 10.w) {
                topBarIconButton(.undoIcon) {}
                topBarIconButton(.redoIcon) {}
                topBarIconButton(.resetIcon) {
                    withAnimation(.easeOut(duration: 0.2)) {
                        canvasOffset = .zero
                        zoom = .one
                    }
                }
            }

            Spacer(minLength: 0)

            Button {
                // Hands the drawing off to the next stage of the editor.
            } label: {
                HStack(spacing: 4.w) {
                    Text(LocalizedKey.editorFinish.localized)
                        .font(.app(.semiBold, size: 15))
                    Image(systemName: "chevron.right")
                        .font(.system(size: 11.s, weight: .bold))
                }
                .foregroundStyle(Color(app: .dark))
                .padding(.horizontal, 16.w)
                .frame(height: 36.h)
                .background(Capsule().fill(Color(app: .white)))
            }
            .buttonStyle(.plain)
        }
    }

    private func topBarIconButton(_ icon: AppImage, action: @escaping () -> Void) -> some View {
        Button(action: action) {
            Image(app: icon)
                .resizable()
                .scaledToFit()
                .frame(width: 36.s, height: 36.s)
        }
        .buttonStyle(.plain)
    }

    // MARK: Canvas

    private var canvas: some View {
        RoundedRectangle(cornerRadius: canvasRadius.s, style: .continuous)
            .fill(Color(app: .white).opacity(0.14))
            .aspectRatio(1, contentMode: .fit)
            .overlay {
                Image(app: template)
                    .resizable()
                    .scaledToFit()
                    .padding(18.s)
                    .opacity(isOpacityToolActive ? draftOpacity : templateOpacity)
                    .scaleEffect(x: isFlipped ? -1 : 1, y: 1)
            }
            .overlay(alignment: .topTrailing) {
                Button {
                    isLocked.toggle()
                } label: {
                    // Baked-in circular plate, same as the top bar's
                    // undo/redo/reset — no background drawn here.
                    Image(app: isLocked ? .lockImageIcon : .unlockImageIcon)
                        .resizable()
                        .scaledToFit()
                        .frame(width: 40.s, height: 40.s)
                }
                .buttonStyle(.plain)
                .padding(12.s)
            }
            .shadow(color: .black.opacity(0.25), radius: 20.s, y: 10.h)
            .scaleEffect(zoom == .half ? 0.5 : zoom == .two ? 2 : 1)
            .offset(canvasOffset)
            .gesture(
                DragGesture()
                    .onChanged { value in
                        guard !isLocked else { return }
                        canvasOffset = CGSize(
                            width: dragStartOffset.width + value.translation.width,
                            height: dragStartOffset.height + value.translation.height
                        )
                    }
                    .onEnded { _ in dragStartOffset = canvasOffset }
            )
    }

    // MARK: Zoom

    private var zoomPills: some View {
        HStack(spacing: 4.w) {
            ForEach(EditorZoom.allCases) { level in
                let isSelected = level == zoom

                Button {
                    withAnimation(.easeOut(duration: 0.2)) { zoom = level }
                } label: {
                    Text(level.label)
                        .font(.app(.semiBold, size: 12))
                        .foregroundStyle(isSelected ? Color(app: .dark) : Color(app: .white))
                        .frame(width: 40.s, height: 28.h)
                        .background(
                            Capsule().fill(isSelected ? Color(app: .white) : Color.clear)
                        )
                }
                .buttonStyle(.plain)
            }
        }
        .padding(4.s)
        .background(Capsule().fill(Color(app: .white).opacity(0.18)))
    }

    // MARK: Opacity sheet
    /// Replaces the toolbar itself — same full-width, top-rounded,
    /// bottom-flush panel — rather than floating above it, so it reads
    /// as a bottom sheet sliding up from the edge of the screen.

    private var opacitySheet: some View {
        VStack(spacing: 16.h) {
            HStack(spacing: 12.w) {
                Text(LocalizedKey.editorToolOpacity.localized)
                    .font(.app(.semiBold, size: 13))
                    .foregroundStyle(Color(app: .dark))

                Slider(value: $draftOpacity, in: 0...1)
                    .tint(Color(app: .accent))

                Text("\(Int(draftOpacity * 100))%")
                    .font(.app(.medium, size: 13))
                    .foregroundStyle(Color(app: .dark))
                    .padding(.horizontal, 10.w)
                    .frame(height: 26.h)
                    .background(Capsule().fill(Color(app: .dotInactive).opacity(0.5)))
            }

            HStack {
                Button {
                    // Draft is discarded; the canvas falls back to
                    // `templateOpacity` on its own once the sheet closes.
                    isOpacityToolActive = false
                } label: {
                    Image(systemName: "xmark")
                        .font(.system(size: 15.s, weight: .semibold))
                        .foregroundStyle(Color(app: .dark))
                        .frame(width: 32.s, height: 32.s)
                }
                .buttonStyle(.plain)

                Spacer(minLength: 0)

                Text(LocalizedKey.editorToolOpacity.localized)
                    .font(.app(.bold, size: 15))
                    .foregroundStyle(Color(app: .dark))

                Spacer(minLength: 0)

                Button {
                    templateOpacity = draftOpacity
                    isOpacityToolActive = false
                } label: {
                    Image(systemName: "checkmark")
                        .font(.system(size: 15.s, weight: .semibold))
                        .foregroundStyle(Color(app: .successGreen))
                        .frame(width: 32.s, height: 32.s)
                }
                .buttonStyle(.plain)
            }
        }
        .padding(.horizontal, 18.w)
        .padding(.top, 16.h)
        .padding(.bottom, 20.h)
        .frame(maxWidth: .infinity)
        .background(
            UnevenRoundedRectangle(
                topLeadingRadius: 24.s,
                bottomLeadingRadius: 0,
                bottomTrailingRadius: 0,
                topTrailingRadius: 24.s,
                style: .continuous
            )
            .fill(Color(app: .white))
            .ignoresSafeArea(edges: .bottom)
        )
    }

    // MARK: Toolbar

    private var toolbar: some View {
        HStack(spacing: 0) {
            ForEach(EditorTool.allCases) { tool in
                let isActive = tool == .opacity && isOpacityToolActive

                Button {
                    switch tool {
                    case .opacity:
                        // Seed the slider from the last confirmed value.
                        draftOpacity = templateOpacity
                        isOpacityToolActive = true
                    case .secondary where mode != .phone:
                        withAnimation(.easeInOut(duration: 0.25)) { isFlipped.toggle() }
                    default:
                        break // Eraser/Record/Photo/Flash sheets follow separately.
                    }
                } label: {
                    VStack(spacing: 6.h) {
                        Image(app: tool.icon(for: mode))
                            .resizable()
                            .scaledToFit()
                            .frame(width: 22.s, height: 22.s)

                        Text(tool.titleKey(for: mode).localized)
                            .font(.app(.medium, size: 11))
                    }
                    .foregroundStyle(isActive || (tool == .secondary && isFlipped) ? Color(app: .accent) : Color(app: .dark))
                    .frame(maxWidth: .infinity)
                }
                .buttonStyle(.plain)
            }
        }
        .padding(.top, 14.h)
        .padding(.bottom, 20.h)
        .background(
            UnevenRoundedRectangle(
                topLeadingRadius: 24.s,
                bottomLeadingRadius: 0,
                bottomTrailingRadius: 0,
                topTrailingRadius: 24.s,
                style: .continuous
            )
            .fill(Color(app: .white))
            .ignoresSafeArea(edges: .bottom)
        )
    }
}

#Preview {
    EditorView(mode: .arDraw)
}
