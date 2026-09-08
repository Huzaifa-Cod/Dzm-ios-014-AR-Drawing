//
//  DrawnStroke.swift
//  ARDrawing
//
//  One continuous finger stroke.
//

import CoreGraphics
import Foundation

struct DrawnStroke: Identifiable, Hashable {
    let id = UUID()
    let step: TutorialStep
    var points: [CGPoint]

    /// Stroke thickness as a fraction of the master artwork's width, so
    /// every stroke keeps the same weight relative to the drawing no matter
    /// how tightly framed the step was when it was drawn.
    static let widthRatio: CGFloat = 0.028
}
