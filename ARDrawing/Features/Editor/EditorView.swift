//  EditorView.swift
//  ARDrawing

import Combine
import SDWebImage
import SDWebImageSwiftUI
import SwiftUI

private struct CanvasFrameKey: PreferenceKey {
    static var defaultValue: CGRect = .zero
    static func reduce(value: inout CGRect, nextValue: () -> CGRect) {
        value = nextValue()
    }
}

private struct EditorStroke {
    var points: [CGPoint]
    let width: CGFloat
    var isEraser = false

    var path: Path {
        var path = Path()
        guard let first = points.first else { return path }
        path.move(to: first)
        guard points.count > 1 else {
            path.addLine(to: first)
            return path
        }
        for index in 1..<points.count {
            let previous = points[index - 1]
            let current = points[index]
            let mid = CGPoint(x: (previous.x + current.x) / 2, y: (previous.y + current.y) / 2)
            path.addQuadCurve(to: mid, control: previous)
        }
        path.addLine(to: points[points.count - 1])
        return path
    }
}

/// The strokes themselves — on screen inside the card, and again off
/// screen when Finish renders them to an image.
private struct StrokePainting: View {
    let strokes: [EditorStroke]
    var cursor: EditorStroke?

    var body: some View {
        Canvas { context, _ in
            let visible = cursor.map { strokes + [$0] } ?? strokes
            for stroke in visible {
                var layer = context
                // `.clear` only punches through this Canvas's own pixels —
                // the template is a separate view underneath, so it survives.
                layer.blendMode = stroke.isEraser ? .clear : .normal
                layer.stroke(
                    stroke.path,
                    with: .color(Color(app: .dark)),
                    style: StrokeStyle(lineWidth: stroke.width, lineCap: .round, lineJoin: .round)
                )
            }

            if let stroke = cursor, stroke.isEraser, let point = stroke.points.last {
                let size = stroke.width
                let ring = Path(ellipseIn: CGRect(x: point.x - size / 2, y: point.y - size / 2, width: size, height: size))
                context.stroke(ring, with: .color(Color(app: .dark).opacity(0.35)), lineWidth: 1)
            }
        }
    }
}

struct EditorView: View {
    @Environment(\.dismiss) private var dismiss
    @Environment(\.managedObjectContext) private var moc
    @EnvironmentObject private var router: AppRouter

    let mode: DrawMode
    let templateURL: URL

    @State private var isLocked = true
    @State private var zoom: EditorZoom = .one

    @State private var canvasOffset: CGSize = .zero
    @State private var dragStartOffset: CGSize = .zero

    /// Last opacity the user confirmed with the checkmark.
    @State private var templateOpacity: Double = 1

    @State private var draftOpacity: Double = 1
    @State private var isOpacityToolActive = false

    /// Last stroke width the user confirmed with the checkmark. Phone
    /// draw mode only — this is what the flash slot becomes there.
    @State private var strokeWidth: Double = 0.6

    @State private var draftStrokeWidth: Double = 0.6
    @State private var isStrokeToolActive = false

    @State private var strokes: [EditorStroke] = []
    @State private var redoStack: [EditorStroke] = []
    @State private var currentStroke: EditorStroke?

    /// Stays on after confirming the Eraser sheet, until the sheet's X or
    /// confirming the Stroke sheet switches back to the pen.
    @State private var isEraserOn = false
    @State private var eraserWidth: Double = 0.5
    @State private var draftEraserWidth: Double = 0.5
    @State private var isEraserToolActive = false

    @State private var isFlipped = false
    @State private var isFlashOn = false

    @StateObject private var cameraController = CameraController()

    @State private var canvasFrame: CGRect = .zero
    @State private var canvasSide: CGFloat = 0
    @State private var isSavedToastVisible = false

    @State private var isPhotoSheetActive = false

    @State private var isRecordSheetActive = false
    @Namespace private var recordModeAnimation
    @State private var recordMode: EditorRecordMode = .video
    @State private var isRecordingActive = false
    @State private var elapsedSeconds = 0

    @State private var shouldDiscardCurrentRecording = false

    @State private var ringSpinDegrees: Double = 0

    private let canvasRadius: CGFloat = 24

    var body: some View {
        VStack(spacing: 0) {
            topBar
                .padding(.horizontal, 20.w)
                .padding(.top, 10.h)

            Spacer(minLength: 0)

            canvas
                .padding(.horizontal, 28.w)

            Spacer(minLength: 0)

            zoomPills
                .padding(.bottom, 16.h)

            if isOpacityToolActive {
                opacitySheet
                    .transition(.move(edge: .bottom))
            } else if isStrokeToolActive {
                strokeSheet
                    .transition(.move(edge: .bottom))
            } else if isEraserToolActive {
                eraserSheet
                    .transition(.move(edge: .bottom))
            } else if isPhotoSheetActive {
                photoCaptureSheet
                    .transition(.move(edge: .bottom))
            } else if isRecordSheetActive {
                recordSheet
                    .transition(.move(edge: .bottom))
            } else {
                toolbar
                    .transition(.identity)
            }
        }
        .animation(.easeInOut(duration: 0.22), value: isOpacityToolActive)
        .animation(.easeInOut(duration: 0.22), value: isStrokeToolActive)
        .animation(.easeInOut(duration: 0.22), value: isEraserToolActive)
        .animation(.easeInOut(duration: 0.22), value: isPhotoSheetActive)
        .animation(.easeInOut(duration: 0.22), value: isRecordSheetActive)
        .frame(maxWidth: .infinity, maxHeight: .infinity)

        .background { backdrop }
        .background(Color(app: .dark).ignoresSafeArea())
        .overlay { savedToast }
        .onPreferenceChange(CanvasFrameKey.self) { canvasFrame = $0 }
        .toolbar(.hidden, for: .navigationBar)
        .onReceive(Timer.publish(every: 1, on: .main, in: .common).autoconnect()) { _ in
            guard isRecordingActive else { return }
            elapsedSeconds += 1
        }
    }

    // MARK: Backdrop

    @ViewBuilder
    private var backdrop: some View {
        switch mode {
        case .phone:
            Image(app: .tutorialOnboardBgImg)
                .resizable()
                .scaledToFill()
                .ignoresSafeArea()
        case .arDraw, .paper:
            CameraPreviewView(
                controller: cameraController,
                isTorchOn: isFlashOn,
                isRecording: isRecordingActive,
                onVideoFinished: handleRecordingFinished
            )
            .ignoresSafeArea()
        }
    }

    // MARK: Photo capture

    private func captureSketch() {
        let frame = canvasFrame
        let opacity = templateOpacity
        let flipped = isFlipped
        // Already sitting in SDWebImage's cache — the canvas has been
        // showing this exact URL since the screen opened.
        let cachedTemplateImage = SDImageCache.shared.imageFromCache(forKey: templateURL.absoluteString)

        cameraController.capturePhoto { [self] cameraImage in
            guard
                let cameraImage,
                let normalized = cameraController.normalizedRect(forLayerRect: frame),
                frame.width > 0
            else { return }

            let pixelRect = CGRect(
                x: normalized.origin.x * cameraImage.size.width,
                y: normalized.origin.y * cameraImage.size.height,
                width: normalized.width * cameraImage.size.width,
                height: normalized.height * cameraImage.size.height
            )
            guard pixelRect.width > 0, pixelRect.height > 0 else { return }

            let renderer = UIGraphicsImageRenderer(size: pixelRect.size)
            let composite = renderer.image { context in
                cameraImage.draw(at: CGPoint(x: -pixelRect.minX, y: -pixelRect.minY))

                guard let templateImage = cachedTemplateImage else { return }

                let insetRatio = 18.s / frame.width
                let inset = insetRatio * pixelRect.width
                var drawRect = CGRect(x: inset, y: inset, width: pixelRect.width - inset * 2, height: pixelRect.height - inset * 2)

                let imageAspect = templateImage.size.width / templateImage.size.height
                let boxAspect = drawRect.width / drawRect.height
                if imageAspect > boxAspect {
                    let fitHeight = drawRect.width / imageAspect
                    drawRect.origin.y += (drawRect.height - fitHeight) / 2
                    drawRect.size.height = fitHeight
                } else {
                    let fitWidth = drawRect.height * imageAspect
                    drawRect.origin.x += (drawRect.width - fitWidth) / 2
                    drawRect.size.width = fitWidth
                }

                context.cgContext.saveGState()
                context.cgContext.setAlpha(opacity)
                if flipped {
                    context.cgContext.translateBy(x: drawRect.midX * 2, y: 0)
                    context.cgContext.scaleBy(x: -1, y: 1)
                }
                templateImage.draw(in: drawRect)
                context.cgContext.restoreGState()
            }

            UIImageWriteToSavedPhotosAlbum(composite, nil, nil, nil)
            showSavedToast()
        }
    }

    // MARK: Finish

    /// Eraser-only strokes leave a blank card, so Finish stays disabled
    /// until there's actual ink to keep.
    private var hasInk: Bool { strokes.contains { !$0.isEraser } }

    /// Renders the strokes on their own — no template, no camera, no
    /// chrome — at the size they were drawn, then hands the saved
    /// sketch's id to the result screen.
    private func finishSketch() {
        guard hasInk, canvasSide > 0 else { return }

        let painting = StrokePainting(strokes: strokes)
            .frame(width: canvasSide, height: canvasSide)
            .background(Color(app: .white))

        let renderer = ImageRenderer(content: painting)
        renderer.scale = 3

        guard
            let image = renderer.uiImage,
            let id = SketchStore.save(image: image, in: moc)
        else { return }

        router.push(.sketchResult(id: id))
    }

    private func showSavedToast() {
        withAnimation(.spring(response: 0.4, dampingFraction: 0.75)) {
            isSavedToastVisible = true
        }
        DispatchQueue.main.asyncAfter(deadline: .now() + 1.8) {
            withAnimation(.easeOut(duration: 0.25)) { isSavedToastVisible = false }
        }
    }

    // MARK: Video capture

    /// Called once `CameraPreviewView` finishes writing the clip — after
    /// `isRecordingActive` has already gone back to false, so this only
    /// decides what happens to the file: save it (Confirm/manual stop)
    /// or delete it (Cancel while recording).
    private func handleRecordingFinished(_ url: URL) {
        guard !shouldDiscardCurrentRecording else {
            try? FileManager.default.removeItem(at: url)
            return
        }

        UISaveVideoAtPathToSavedPhotosAlbum(url.path, nil, nil, nil)
        showSavedToast()

        // Saving copies the file asynchronously; give it a moment before
        // clearing the temp copy out from under it.
        DispatchQueue.main.asyncAfter(deadline: .now() + 3) {
            try? FileManager.default.removeItem(at: url)
        }
    }

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

    // MARK: Top bar

    private var topBar: some View {
        HStack {
            Button {
                dismiss()
            } label: {
                Text(LocalizedKey.editorCancel.localized)
                    .font(.app(.semiBold, size: 15))
                    .foregroundStyle(mode == .phone ? Color(app: .dark) : Color(app: .white))
            }
            .buttonStyle(.plain)

            Spacer(minLength: 0)

            HStack(spacing: 10.w) {
                topBarIconButton(.undoIcon) {
                    guard let last = strokes.popLast() else { return }
                    redoStack.append(last)
                }
                .disabled(strokes.isEmpty)
                .opacity(strokes.isEmpty ? 0.4 : 1)

                topBarIconButton(.redoIcon) {
                    guard let restored = redoStack.popLast() else { return }
                    strokes.append(restored)
                }
                .disabled(redoStack.isEmpty)
                .opacity(redoStack.isEmpty ? 0.4 : 1)
                topBarIconButton(.resetIcon) {
                    withAnimation(.easeOut(duration: 0.2)) {
                        canvasOffset = .zero
                        zoom = .one
                    }
                }
            }

            Spacer(minLength: 0)

            Button {
                finishSketch()
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
            .disabled(!hasInk)
            .opacity(hasInk ? 1 : 0.5)
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
            .fill(mode == .phone ? Color(app: .white) : Color(app: .white).opacity(0.14))
            .aspectRatio(1, contentMode: .fit)
            .overlay {
                WebImage(url: templateURL) { image in
                    image
                        .resizable()
                        .scaledToFit()
                        .clipShape(RoundedRectangle(cornerRadius: (canvasRadius - 12).s, style: .continuous))
                } placeholder: {
                    ProgressView()
                }
                .indicator(.activity)
                .padding(18.s)
                .opacity(isOpacityToolActive ? draftOpacity : templateOpacity)
                .scaleEffect(x: isFlipped ? -1 : 1, y: 1)
            }
            .overlay { drawingLayer }
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
            .clipShape(RoundedRectangle(cornerRadius: canvasRadius.s, style: .continuous))
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
            .background(
                GeometryReader { geo in
                    Color.clear
                        .preference(key: CanvasFrameKey.self, value: geo.frame(in: .global))
                        // Written straight to state: a preference set inside
                        // a background doesn't reach the enclosing view.
                        // `scaleEffect` is a render transform, so this stays
                        // the card's own side length whatever the zoom is.
                        .task(id: geo.size.width) { canvasSide = geo.size.width }
                }
            )
    }

    // MARK: Drawing

    /// Slider 0…1 → 2…16pt brush. While the stroke sheet is open the
    /// draft value applies, so the user can try a width before confirming.
    private var activeStrokeWidth: CGFloat {
        let value = isStrokeToolActive ? draftStrokeWidth : strokeWidth
        return (2 + value * 14).s
    }

    /// Slider 0…1 → 8…40pt — wider than the pen so a line clears in a pass or two.
    private var activeEraserWidth: CGFloat {
        let value = isEraserToolActive ? draftEraserWidth : eraserWidth
        return (8 + value * 32).s
    }

    /// An open sheet wins, so each slider can be tried before confirming.
    private var isErasing: Bool {
        if isEraserToolActive { return true }
        if isStrokeToolActive { return false }
        return isEraserOn
    }

    private var isDrawingEnabled: Bool { mode == .phone && isLocked }

    private var drawingLayer: some View {
        StrokePainting(strokes: strokes, cursor: currentStroke)
            .contentShape(Rectangle())
        // When unlocked the finger moves the card instead (the canvas's
        // own drag gesture), so drawing stands down.
        .gesture(drawGesture, including: isDrawingEnabled ? .all : .subviews)
    }

    private var drawGesture: some Gesture {
        DragGesture(minimumDistance: 0)
            .onChanged { value in
                if currentStroke == nil {
                    let erasing = isErasing
                    currentStroke = EditorStroke(
                        points: [value.location],
                        width: erasing ? activeEraserWidth : activeStrokeWidth,
                        isEraser: erasing
                    )
                } else {
                    currentStroke?.points.append(value.location)
                }
            }
            .onEnded { _ in
                guard let finished = currentStroke else { return }
                currentStroke = nil
                // Erasing a blank card changes nothing — don't let it
                // clutter the undo history.
                if finished.isEraser && !strokes.contains(where: { !$0.isEraser }) { return }
                strokes.append(finished)
                redoStack.removeAll()
                currentStroke = nil
            }
    }

    // MARK: Zoom

    private var zoomPills: some View {
        // Translucent glass reads fine over the camera feed, but over
        // the light paper backdrop (Phone mode) that same white-on-white
        // styling goes illegible — so unselected pills switch to a dark
        // tint and the track to a faint dark wash there instead.
        let isLightBackdrop = mode == .phone

        return HStack(spacing: 4.w) {
            ForEach(EditorZoom.allCases) { level in
                let isSelected = level == zoom

                Button {
                    withAnimation(.easeOut(duration: 0.2)) { zoom = level }
                } label: {
                    Text(level.label)
                        .font(.app(.semiBold, size: 12))
                        .foregroundStyle(
                            isSelected
                                ? Color(app: .dark)
                                : (isLightBackdrop ? Color(app: .dark).opacity(0.6) : Color(app: .white))
                        )
                        .frame(width: 40.s, height: 28.h)
                        .background(
                            Capsule().fill(isSelected ? Color(app: .white) : Color.clear)
                        )
                }
                .buttonStyle(.plain)
            }
        }
        .padding(4.s)
        .background(
            Capsule().fill(
                isLightBackdrop ? Color(app: .dark).opacity(0.08) : Color(app: .white).opacity(0.18)
            )
        )
    }

    // MARK: Sheet chrome shared by Opacity/Photo/Record
  

    private func sheetPanel<Content: View>(
        isGlass: Bool = false,
        tint: Color = .clear,
        @ViewBuilder content: () -> Content
    ) -> some View {
        let shape = UnevenRoundedRectangle(
            topLeadingRadius: 24.s,
            bottomLeadingRadius: 0,
            bottomTrailingRadius: 0,
            topTrailingRadius: 24.s,
            style: .continuous
        )

        return content()
            .padding(.horizontal, 18.w)
            .padding(.top, 16.h)
            .padding(.bottom, 20.h)
            .frame(maxWidth: .infinity)
            .background(
                Group {
                    if isGlass {
                        // Forced dark regardless of system appearance —
                        // this screen is always dark camera chrome.
                        shape.fill(.ultraThinMaterial)
                            .environment(\.colorScheme, .dark)
                    } else {
                        shape.fill(tint)
                    }
                }
                .ignoresSafeArea(edges: .bottom)
            )
            .overlay(
                Group {
                    if isGlass {
                        shape.stroke(Color.white.opacity(0.28), lineWidth: 1)
                    }
                }
                .ignoresSafeArea(edges: .bottom)
            )
    }

    /// The X — title — checkmark row every sheet ends on.
    private func sheetActionRow(
        title: String,
        textColor: Color,
        onCancel: @escaping () -> Void,
        onConfirm: @escaping () -> Void
    ) -> some View {
        HStack {
            Button(action: onCancel) {
                Image(systemName: "xmark")
                    .font(.system(size: 15.s, weight: .semibold))
                    .foregroundStyle(textColor)
                    .frame(width: 32.s, height: 32.s)
            }
            .buttonStyle(.plain)

            Spacer(minLength: 0)

            Text(title)
                .font(.app(.bold, size: 15))
                .foregroundStyle(textColor)

            Spacer(minLength: 0)

            Button(action: onConfirm) {
                Image(systemName: "checkmark")
                    .font(.system(size: 15.s, weight: .semibold))
                    .foregroundStyle(Color(app: .successGreen))
                    .frame(width: 32.s, height: 32.s)
            }
            .buttonStyle(.plain)
        }
    }

    // MARK: Opacity sheet

    private var opacitySheet: some View {
        sheetPanel(tint: Color(app: .white)) {
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

                sheetActionRow(
                    title: LocalizedKey.editorToolOpacity.localized,
                    textColor: Color(app: .dark),
                    onCancel: {
                        // Draft is discarded; the canvas falls back to
                        // `templateOpacity` on its own once the sheet closes.
                        isOpacityToolActive = false
                    },
                    onConfirm: {
                        templateOpacity = draftOpacity
                        isOpacityToolActive = false
                    }
                )
            }
        }
    }

    // MARK: Stroke sheet
    /// Same slider-plus-percentage layout as `opacitySheet`, just driving
    /// brush width instead of opacity — and closing on "Draw Stroke"
    /// rather than repeating the tool's own name.

    private var strokeSheet: some View {
        sheetPanel(tint: Color(app: .white)) {
            VStack(spacing: 16.h) {
                HStack(spacing: 12.w) {
                    Text(LocalizedKey.editorToolStroke.localized)
                        .font(.app(.semiBold, size: 13))
                        .foregroundStyle(Color(app: .dark))

                    Slider(value: $draftStrokeWidth, in: 0...1)
                        .tint(Color(app: .accent))

                    Text("\(Int(draftStrokeWidth * 100))%")
                        .font(.app(.medium, size: 13))
                        .foregroundStyle(Color(app: .dark))
                        .padding(.horizontal, 10.w)
                        .frame(height: 26.h)
                        .background(Capsule().fill(Color(app: .dotInactive).opacity(0.5)))
                }

                sheetActionRow(
                    title: LocalizedKey.editorDrawStrokeTitle.localized,
                    textColor: Color(app: .dark),
                    onCancel: {
                        // Draft is discarded; the canvas falls back to
                        // `strokeWidth` on its own once the sheet closes.
                        isStrokeToolActive = false
                    },
                    onConfirm: {
                        strokeWidth = draftStrokeWidth
                        isEraserOn = false
                        isStrokeToolActive = false
                    }
                )
            }
        }
    }

    // MARK: Eraser sheet

    private var eraserSheet: some View {
        sheetPanel(tint: Color(app: .white)) {
            VStack(spacing: 16.h) {
                HStack(spacing: 12.w) {
                    Text(LocalizedKey.editorToolEraser.localized)
                        .font(.app(.semiBold, size: 13))
                        .foregroundStyle(Color(app: .dark))

                    Slider(value: $draftEraserWidth, in: 0...1)
                        .tint(Color(app: .accent))

                    Text("\(Int(draftEraserWidth * 100))%")
                        .font(.app(.medium, size: 13))
                        .foregroundStyle(Color(app: .dark))
                        .padding(.horizontal, 10.w)
                        .frame(height: 26.h)
                        .background(Capsule().fill(Color(app: .dotInactive).opacity(0.5)))
                }

                sheetActionRow(
                    title: LocalizedKey.editorToolEraser.localized,
                    textColor: Color(app: .dark),
                    onCancel: {
                        isEraserOn = false
                        isEraserToolActive = false
                    },
                    onConfirm: {
                        eraserWidth = draftEraserWidth
                        isEraserOn = true
                        isEraserToolActive = false
                    }
                )
            }
        }
    }

    // MARK: Photo sheet

    private var photoCaptureSheet: some View {
        sheetPanel(isGlass: true) {
            VStack(spacing: 18.h) {
                Button {
                    // The sheet's job is done the instant the shutter
                    // fires — close it first so `captureSketch` only
                    // has the topBar/zoomPills/toolbar left to hide.
                    isPhotoSheetActive = false
                    captureSketch()
                } label: {
                    // Exact asset, no extra background or shadow.
                    Image(app: .capturePhotoIconBtn)
                        .resizable()
                        .scaledToFit()
                        .frame(width: 72.s, height: 72.s)
                }
                .buttonStyle(.plain)

                sheetActionRow(
                    title: LocalizedKey.editorCapturePhotoTitle.localized,
                    textColor: Color(app: .white),
                    onCancel: { isPhotoSheetActive = false },
                    onConfirm: {
                        isPhotoSheetActive = false
                        captureSketch()
                    }
                )
            }
        }
    }

    // MARK: Record sheet

    private var recordSheet: some View {
        sheetPanel(isGlass: true) {
            VStack(spacing: 16.h) {
                recordModeToggle

                recordButton

                if isRecordingActive {
                    Text(recordTimerLabel)
                        .font(.app(.semiBold, size: 13))
                        .foregroundStyle(Color(app: .white))
                }

                sheetActionRow(
                    title: LocalizedKey.editorToolRecord.localized,
                    textColor: Color(app: .white),
                    onCancel: {
                        // A recording in progress is discarded, not saved.
                        stopRecording(discard: true)
                        closeRecordSheet()
                    },
                    onConfirm: {
                        stopRecording(discard: false)
                        closeRecordSheet()
                    }
                )
            }
        }
    }

    /// Sized to its text, not the sheet's full width, with the
    /// selection sliding between the two options — same
    /// `matchedGeometryEffect` pattern as Album's Drawn/Recorded tabs.
    private var recordModeToggle: some View {
        HStack(spacing: 4.w) {
            ForEach(EditorRecordMode.allCases) { option in
                let isSelected = option == recordMode

                Button {
                    withAnimation(.spring(response: 0.32, dampingFraction: 0.85)) {
                        recordMode = option
                    }
                } label: {
                    Text(option.titleKey.localized)
                        .font(.app(.semiBold, size: 13))
                        .foregroundStyle(isSelected ? Color(app: .dark) : Color(app: .white).opacity(0.65))
                        .padding(.horizontal, 18.w)
                        .frame(height: 34.h)
                        .background {
                            if isSelected {
                                Capsule()
                                    .fill(Color(app: .white))
                                    .matchedGeometryEffect(id: "activeRecordMode", in: recordModeAnimation)
                            }
                        }
                }
                .buttonStyle(.plain)
                .disabled(isRecordingActive)
            }
        }
        .padding(3.s)
        .background(Capsule().fill(Color(app: .white).opacity(0.15)))
        .opacity(isRecordingActive ? 0.5 : 1)
    }

    /// The button itself is the plain asset, exactly as downloaded — the
    /// ring is the only thing drawn on top, and only while recording.
    private var recordButton: some View {
        ZStack {
            if isRecordingActive {
                recordProgressRing
            }

            Button {
                toggleRecording()
            } label: {
                Image(app: isRecordingActive ? .stopRecordingBtnIcon : .recordBtn)
                    .resizable()
                    .scaledToFit()
                    .frame(width: 46.s, height: 46.s)
            }
            .buttonStyle(.plain)
        }
        .frame(width: 96.s, height: 96.s)
    }

    /// Video gets a spinning near-complete arc; Timelapse gets a
    /// spinning ring of radial ticks (a sunburst, like the capture
    /// button's own decoration) — the two "different styles" around the
    /// same red square, both with clear breathing room around the
    /// button now that it's smaller.
    @ViewBuilder
    private var recordProgressRing: some View {
        switch recordMode {
        case .video:
            Circle()
                .trim(from: 0, to: 0.75)
                .stroke(Color(app: .redAccent), style: StrokeStyle(lineWidth: 4.s, lineCap: .round))
                .frame(width: 82.s, height: 82.s)
                .rotationEffect(.degrees(ringSpinDegrees))
        case .timelapse:
            ZStack {
                ForEach(0..<12, id: \.self) { tick in
                    Capsule()
                        .fill(Color(app: .redAccent))
                        .frame(width: CGFloat(2.5).s, height: 9.s)
                        .offset(y: -41.s)
                        .rotationEffect(.degrees(Double(tick) * 30))
                }
            }
            .rotationEffect(.degrees(ringSpinDegrees))
        }
    }

    private var recordTimerLabel: String {
        String(format: "%02d:%02d", elapsedSeconds / 60, elapsedSeconds % 60)
    }

    /// The button itself always saves on stop — tapping it a second
    /// time is a decisive "I'm done with this clip" action, the same
    /// one-tap immediacy as the Photo tool's shutter.
    private func toggleRecording() {
        if isRecordingActive {
            stopRecording(discard: false)
        } else {
            shouldDiscardCurrentRecording = false
            elapsedSeconds = 0
            isRecordingActive = true
            withAnimation(.linear(duration: 1.4).repeatForever(autoreverses: false)) {
                ringSpinDegrees = 360
            }
        }
    }

    private func stopRecording(discard: Bool) {
        guard isRecordingActive else { return }
        shouldDiscardCurrentRecording = discard
        isRecordingActive = false
        withAnimation(.easeOut(duration: 0.2)) { ringSpinDegrees = 0 }
    }

    private func closeRecordSheet() {
        isRecordSheetActive = false
        elapsedSeconds = 0
    }

    // MARK: Toolbar

    private var toolbar: some View {
        HStack(spacing: 0) {
            ForEach(EditorTool.allCases) { tool in
                let isActive = (tool == .opacity && isOpacityToolActive)
                    || (tool == .flash && mode == .phone && isStrokeToolActive)
                    || (tool == .secondary && mode == .phone && (isEraserToolActive || isEraserOn))

                Button {
                    switch tool {
                    case .opacity:
                        // Seed the slider from the last confirmed value.
                        draftOpacity = templateOpacity
                        isOpacityToolActive = true
                    case .secondary where mode != .phone:
                        withAnimation(.easeInOut(duration: 0.25)) { isFlipped.toggle() }
                    case .secondary:
                        draftEraserWidth = eraserWidth
                        isEraserToolActive = true
                    case .flash:
                        // No camera flash to control while drawing
                        // directly on the phone screen — this slot opens
                        // the stroke sheet there instead.
                        if mode == .phone {
                            // Seed the slider from the last confirmed value.
                            draftStrokeWidth = strokeWidth
                            isStrokeToolActive = true
                        } else {
                            isFlashOn.toggle()
                        }
                    case .photo:
                        isPhotoSheetActive = true
                    case .record:
                        isRecordSheetActive = true
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
                    .foregroundStyle(
                        isActive
                            || (tool == .secondary && isFlipped)
                            || (tool == .flash && isFlashOn && mode != .phone)
                            ? Color(app: .accent) : Color(app: .dark)
                    )
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

//#Preview {
//    EditorView(mode: .arDraw)
//}
