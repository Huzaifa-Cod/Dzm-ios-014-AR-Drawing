//
//  TutorialDrawingView.swift
//  ARDrawing
//

import SwiftUI

struct TutorialDrawingView: View {
    @EnvironmentObject private var router: AppRouter
    @StateObject private var viewModel = TutorialDrawingViewModel()

    private let controlSize: CGFloat = 52
    private let controlRadius: CGFloat = 18

    var body: some View {
        VStack(spacing: 0) {
            header

            Text(LocalizedKey.tutorialLessonTitle.localized)
                .font(.app(.extraBold, size: 17))
                .foregroundStyle(Color(app: .dark))
                .padding(.top, 18.h)

            TutorialCanvasView(
                step: viewModel.currentStep,
                strokes: viewModel.strokes,
                activeStroke: viewModel.activeStroke,
                onDrag: viewModel.handleDrag,
                onDragEnded: viewModel.endStroke
            )
            .clipped()
            .padding(.top, 12.h)

            controls
                .padding(.top, 12.h)
        }
        .padding(.horizontal, 24.w)
        .padding(.bottom, 16.h)
        .frame(maxWidth: .infinity, maxHeight: .infinity)
        .background {
            Image(app: .tutorialOnboardBgImg)
                .resizable()
                .scaledToFill()
                .ignoresSafeArea()
        }
        .navigationBarBackButtonHidden(true)
    }

    // MARK: Header

    private var header: some View {
        ZStack {
            StepProgressBar(
                total: TutorialStep.progressTotal,
                completed: viewModel.currentStep.progressIndex
            )

            Button {
                viewModel.close(router: router)
            } label: {
                Image(systemName: "xmark")
                    .font(.system(size: 16.s, weight: .medium))
                    .foregroundStyle(Color(app: .textSecondary))
            }
            .frame(maxWidth: .infinity, alignment: .trailing)
        }
        .padding(.top, 12.h)
    }

    // MARK: Bottom controls

    private var controls: some View {
        HStack(spacing: 16.w) {
            Button {
                viewModel.undo()
            } label: {
                Image(systemName: "arrow.counterclockwise")
                    .font(.system(size: 22.s, weight: .heavy))
                    .foregroundStyle(Color(app: .dark))
                    .frame(width: controlSize.s, height: controlSize.s)
                    .background(
                        RoundedRectangle(cornerRadius: controlRadius.s, style: .continuous)
                            .fill(Color(app: .dark).opacity(0.04))
                    )
                    .overlay(
                        RoundedRectangle(cornerRadius: controlRadius.s, style: .continuous)
                            .stroke(Color(app: .dark).opacity(0.02), lineWidth: 1)
                    )
            }
            .opacity(viewModel.canUndo ? 1 : 0.4)
            .disabled(!viewModel.canUndo)

            if viewModel.isLastStep {
                Button {
                    viewModel.complete(router: router)
                } label: {
                    Text(LocalizedKey.tutorialCompleteButton.localized)
                        .font(.app(.semiBold, size: 16))
                        .frame(maxWidth: .infinity)
                        .frame(height: controlSize.s)
                        // Overlaid rather than sat in an HStack so the tick
                        // pins to the leading edge without shifting the
                        // label off the button's centre.
                        .overlay(alignment: .leading) {
                            Image(systemName: "checkmark")
                                .font(.system(size: 17.s, weight: .heavy))
                                .padding(.leading, 20.w)
                        }
                        .foregroundStyle(Color(app: .white))
                        .background(
                            RoundedRectangle(cornerRadius: controlRadius.s, style: .continuous)
                                .fill(Color(app: .successGreen))
                        )
                }
            } else {
                Button {
                    withAnimation(.easeInOut(duration: 0.3)) {
                        viewModel.goToNextStep()
                    }
                } label: {
                    Image(systemName: "arrow.right")
                        .font(.system(size: 22.s, weight: .heavy))
                        .foregroundStyle(Color(app: .white))
                        .frame(width: controlSize.s, height: controlSize.s)
                        .background(
                            RoundedRectangle(cornerRadius: controlRadius.s, style: .continuous)
                                .fill(Color(app: .accent))
                        )
                }
            }
        }
        .frame(maxWidth: .infinity, alignment: viewModel.isLastStep ? .leading : .center)
    }
}

#Preview {
    NavigationStack {
        TutorialDrawingView()
    }
    .environmentObject(AppRouter())
}
