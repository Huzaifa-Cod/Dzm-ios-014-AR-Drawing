//
//  TutorialDrawingViewModel.swift
//  ARDrawing
//
//  Owns the tutorial's drawing state: which step we're on, every stroke
//  the user has drawn, and the per-step stroke limit.
//

import Combine
import CoreGraphics
import Foundation

@MainActor
final class TutorialDrawingViewModel: ObservableObject {
    /// The step being drawn right now.
    @Published private(set) var currentStep: TutorialStep = .face

    /// Every committed stroke across every step, in draw order.
    @Published private(set) var strokes: [DrawnStroke] = []
    /// The stroke currently under the user's finger, if any.
    @Published private(set) var activeStroke: DrawnStroke?

    /// Points closer together than this (in master space) are dropped, so
    /// a slow finger doesn't pile up hundreds of near-identical points.
    private let minimumPointDistance: CGFloat = 0.004

    // MARK: Drawing rules

    private var completedStrokesInCurrentStep: Int {
        strokes.filter { $0.step == currentStep }.count
    }

    /// False once the step's stroke budget is spent — the user has to undo
    /// before they can draw again.
    var canDraw: Bool {
        !currentStep.isResult && completedStrokesInCurrentStep < currentStep.maxStrokes
    }

    var canUndo: Bool {
        completedStrokesInCurrentStep > 0
    }

    var isLastStep: Bool {
        currentStep == .result
    }

    // MARK: Stroke input

    /// Starts a stroke on the first drag event and extends it thereafter.
    func handleDrag(at point: CGPoint) {
        if activeStroke == nil {
            guard canDraw else { return }
            activeStroke = DrawnStroke(step: currentStep, points: [point])
            return
        }
        extendActiveStroke(to: point)
    }

    /// Commits the stroke. Lifting the finger ends it for good — that is
    /// what enforces "one touch" on the single-stroke steps.
    func endStroke() {
        guard let stroke = activeStroke else { return }
        activeStroke = nil
        strokes.append(stroke)
    }

    private func extendActiveStroke(to point: CGPoint) {
        guard var stroke = activeStroke, let last = stroke.points.last else { return }
        let dx = point.x - last.x
        let dy = point.y - last.y
        guard (dx * dx + dy * dy).squareRoot() >= minimumPointDistance else { return }
        stroke.points.append(point)
        activeStroke = stroke
    }

    // MARK: Actions

    /// Removes the most recent stroke of the current step, which also
    /// unlocks drawing again once the limit had been reached.
    func undo() {
        guard let index = strokes.lastIndex(where: { $0.step == currentStep }) else { return }
        strokes.remove(at: index)
    }

    func goToNextStep() {
        guard let next = TutorialStep(rawValue: currentStep.rawValue + 1) else { return }
        activeStroke = nil
        currentStep = next
    }

    /// Finishing hands the drawing on to the completion screen.
    func complete(router: AppRouter) {
        UserDefaultsManager.shared.hasCompletedTutorial = true
        router.push(.tutorialComplete(strokes: strokes))
    }

    /// The close button skips the reveal and leaves the flow entirely.
    /// Skipping still counts as having seen the tutorial, so it does not
    /// re-run on the next launch.
    func close(router: AppRouter) {
        UserDefaultsManager.shared.hasCompletedTutorial = true
        router.replaceStack(with: .home)
    }
}
