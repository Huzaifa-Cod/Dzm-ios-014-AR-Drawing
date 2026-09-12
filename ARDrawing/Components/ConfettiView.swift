//
//  ConfettiView.swift
//  ARDrawing

import SwiftUI

/// A one-shot confetti fall. Plays once when it appears and settles —
/// no repeat, nothing to dismiss, and never in the way of a tap.
struct ConfettiView: View {
    var pieceCount: Int = 70

    @State private var pieces: [Piece] = []
    @State private var isFalling = false

    private struct Piece: Identifiable {
        let id = UUID()
        let xRatio: CGFloat
        let drift: CGFloat
        let delay: Double
        let duration: Double
        let spin: Double
        let color: Color
        let size: CGSize
        let isRound: Bool
    }

    private static let colors: [Color] = [
        Color(app: .accent),
        Color(app: .proOrange),
        Color(app: .successGreen),
        Color(app: .redAccent)
    ]

    var body: some View {
        GeometryReader { geo in
            ZStack {
                ForEach(pieces) { piece in
                    Group {
                        if piece.isRound {
                            Circle().fill(piece.color)
                        } else {
                            RoundedRectangle(cornerRadius: 1.5, style: .continuous)
                                .fill(piece.color)
                        }
                    }
                    .frame(width: piece.size.width, height: piece.size.height)
                    .rotationEffect(.degrees(isFalling ? piece.spin : 0))
                    .opacity(isFalling ? 0 : 1)
                    .position(
                        x: geo.size.width * piece.xRatio + (isFalling ? piece.drift : 0),
                        y: isFalling ? geo.size.height + 80 : -80
                    )
                    .animation(
                        .easeIn(duration: piece.duration).delay(piece.delay),
                        value: isFalling
                    )
                }
            }
        }
        .allowsHitTesting(false)
        .onAppear {
            pieces = Self.makePieces(count: pieceCount)
            // A beat after the pieces exist, so they animate in from
            // above rather than appearing mid-fall.
            DispatchQueue.main.asyncAfter(deadline: .now() + 0.05) {
                isFalling = true
            }
        }
    }

    private static func makePieces(count: Int) -> [Piece] {
        (0..<count).map { _ in
            let width = CGFloat.random(in: 6...11)
            let isRound = Bool.random()
            return Piece(
                xRatio: .random(in: 0...1),
                drift: .random(in: -60...60),
                delay: .random(in: 0...0.5),
                duration: .random(in: 1.6...2.8),
                spin: .random(in: 180...900) * (Bool.random() ? 1 : -1),
                color: colors.randomElement() ?? Color(app: .accent),
                size: CGSize(width: width, height: isRound ? width : width * 1.6),
                isRound: isRound
            )
        }
    }
}
