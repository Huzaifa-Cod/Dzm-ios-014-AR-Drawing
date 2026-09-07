//
//  SplashView.swift
//  ARDrawing
//

import SwiftUI

struct SplashView: View {
    @Binding var isFinished: Bool
    @StateObject private var viewModel = SplashViewModel()

    var body: some View {
        ZStack {
            RadialGradient(
                colors: [Color(.gradientEnd), Color(.gradientStart)],
                center: .init(x: 0.5, y: 0.85),
                startRadius: 0,
                endRadius: 500.s
            )
            .ignoresSafeArea()

            VStack(spacing: 16.h) {
                Image(app: .splashIcon)
                    .resizable()
                    .scaledToFit()
                    .frame(width: 90.s, height: 90.s)
                    .clipShape(RoundedRectangle(cornerRadius: 22.s, style: .continuous))
                    .shadow(color: .black.opacity(0.15), radius: 12.s, y: 6.s)

                Text(LocalizedKey.appName.localized)
                    .font(.app(.bold, size: 22))
                    .foregroundStyle(Color(.white))
            }
            .opacity(viewModel.isLogoVisible ? 1 : 0)
            .scaleEffect(viewModel.isLogoVisible ? 1 : 0.92)
        }
        .onAppear {
            viewModel.start { isFinished = true }
        }
    }
}

#Preview {
    SplashView(isFinished: .constant(false))
}
