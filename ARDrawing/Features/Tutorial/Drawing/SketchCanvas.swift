//
//  SketchCanvas.swift
//  ARDrawing
//


import SwiftUI

struct SketchCanvas: View {
    let strokes: [DrawnStroke]
    var activeStroke: DrawnStroke?

    /// Where the whole cat artwork sits. Stroke points are normalised
    /// against this rect, so it is the only thing that has to be right.
    let masterFrame: CGRect

    var body: some View {
        Canvas { context, _ in
            // Weight is tied to the artwork, not the canvas, so a line drawn
            // on a tightly framed step keeps its proportion when the whole
            // cat is shown again.
            let lineWidth = DrawnStroke.widthRatio * masterFrame.width
            for stroke in strokes {
                draw(stroke, in: context, lineWidth: lineWidth)
            }
            if let activeStroke {
                draw(activeStroke, in: context, lineWidth: lineWidth)
            }
        }
    }

    private func screenPoint(_ point: CGPoint) -> CGPoint {
        CGPoint(
            x: masterFrame.minX + point.x * masterFrame.width,
            y: masterFrame.minY + point.y * masterFrame.height
        )
    }

    private func draw(_ stroke: DrawnStroke, in context: GraphicsContext, lineWidth: CGFloat) {
        let points = stroke.points.map(screenPoint)
        guard let first = points.first else { return }

        // A tap with no movement still deserves a dot.
        guard points.count > 1 else {
            let dot = CGRect(
                x: first.x - lineWidth / 2,
                y: first.y - lineWidth / 2,
                width: lineWidth,
                height: lineWidth
            )
            context.fill(Path(ellipseIn: dot), with: .color(Color(app: .black)))
            return
        }

        // Curve through the midpoints so the line reads as hand drawn
        // instead of a chain of straight segments.
        var path = Path()
        path.move(to: first)
        for index in 1..<points.count {
            let previous = points[index - 1]
            let current = points[index]
            let midpoint = CGPoint(x: (previous.x + current.x) / 2, y: (previous.y + current.y) / 2)
            path.addQuadCurve(to: midpoint, control: previous)
        }
        path.addLine(to: points[points.count - 1])

        context.stroke(
            path,
            with: .color(Color(app: .black)),
            style: StrokeStyle(lineWidth: lineWidth, lineCap: .round, lineJoin: .round)
        )
    }
}
