//
//  TutorialCanvasView.swift
//  ARDrawing
//
//  The drawing surface: the light blue guide artwork for the current step

import SwiftUI

struct TutorialCanvasView: View {
    let step: TutorialStep
    let strokes: [DrawnStroke]
    let activeStroke: DrawnStroke?
    let onDrag: (CGPoint) -> Void
    let onDragEnded: () -> Void

    /// How far the guide fades in from its edges, as a fraction of the
    /// artwork's shorter side.
    private let fadeFraction: CGFloat = 0.02

    var body: some View {
        GeometryReader { geo in
            let guide = step.guide
            let visible = guide.frame(fitting: geo.size)
            let master = guide.masterFrame(fitting: geo.size)

            ZStack {
                Image(app: guide.image)
                    .resizable()
                    .scaledToFit()
                    .frame(width: visible.width, height: visible.height)
                    .edgeFade(
                        length: guide.isCropped
                            ? fadeFraction * min(visible.width, visible.height)
                            : 0,
                        size: visible.size
                    )
                    .position(x: visible.midX, y: visible.midY)

                SketchCanvas(
                    strokes: strokes,
                    activeStroke: activeStroke,
                    masterFrame: master
                )
            }
            .frame(width: geo.size.width, height: geo.size.height)
            .contentShape(Rectangle())
            .gesture(
                DragGesture(minimumDistance: 0)
                    .onChanged { value in
                        onDrag(masterPoint(from: value.location, frame: master))
                    }
                    .onEnded { _ in onDragEnded() }
            )
        }
    }

    // MARK: Geometry

    private func masterPoint(from location: CGPoint, frame: CGRect) -> CGPoint {
        guard frame.width > 0, frame.height > 0 else { return .zero }
        return CGPoint(
            x: (location.x - frame.minX) / frame.width,
            y: (location.y - frame.minY) / frame.height
        )
    }
}
