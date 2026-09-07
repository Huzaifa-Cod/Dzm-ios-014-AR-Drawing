//
//  SplashViewModel.swift
//  ARDrawing
//

import Combine
import SwiftUI

@MainActor
final class SplashViewModel: ObservableObject {
    @Published var isLogoVisible = false

    /// How long the splash stays on screen before handing off.
    private let displayDuration: UInt64 = 1_500_000_000

    func start(onFinished: @escaping () -> Void) {
        withAnimation(.easeOut(duration: 0.5)) {
            isLogoVisible = true
        }
        Task {
            try? await Task.sleep(nanoseconds: displayDuration)
            onFinished()
        }
    }
}
