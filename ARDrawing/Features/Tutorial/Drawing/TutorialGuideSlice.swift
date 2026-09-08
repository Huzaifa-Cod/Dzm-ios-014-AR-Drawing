//
//  TutorialGuideSlice.swift
//  ARDrawing
//

import CoreGraphics

struct TutorialGuideSlice {
    /// The pre-cropped artwork for this framing.
    let image: AppImage

    /// The part of the master artwork this asset shows, normalised 0...1.
    let rect: CGRect

    // MARK: Framings

    /// Width / height of the master artwork (cat1).
    static let masterAspect: CGFloat = 350.000977 / 346.365417

    /// The whole cat — used by the first step and by the final reveal.
    static let full = TutorialGuideSlice(
        image: .catFull,
        rect: CGRect(x: 0, y: 0, width: 1, height: 1)
    )

    static let leftEar = TutorialGuideSlice(
        image: .catLeftEar,
        rect: CGRect(x: 0.0000, y: 0, width: 0.5000, height: 1)
    )

    static let rightEar = TutorialGuideSlice(
        image: .catRightEar,
        rect: CGRect(x: 0.5021, y: 0, width: 0.4981, height: 1)
    )

    static let nose = TutorialGuideSlice(
        image: .catNose,
        rect: CGRect(x: 0.2029, y: 0, width: 0.5952, height: 1)
    )

    /// Left eye and, two steps later, the left whiskers.
    static let leftProfile = TutorialGuideSlice(
        image: .catLeftProfile,
        rect: CGRect(x: 0.0000, y: 0, width: 0.5688, height: 1)
    )

    /// Right eye and, two steps later, the right whiskers.
    static let rightProfile = TutorialGuideSlice(
        image: .catRightProfile,
        rect: CGRect(x: 0.4293, y: 0, width: 0.5705, height: 1)
    )

    // MARK: Geometry

    /// Whether this asset is a cut-down view of the master rather than the
    /// whole drawing. Only cropped assets have artificial borders worth
    /// hiding — the full cat ends where the drawing itself ends.
    var isCropped: Bool {
        rect != CGRect(x: 0, y: 0, width: 1, height: 1)
    }

    /// Width / height of this asset as exported.
    var aspect: CGFloat {
        Self.masterAspect * rect.width / rect.height
    }

    /// The rect this asset fills when aspect-fitted into `size`.
    ///
    /// Fitting (never filling) is what keeps the guide whole on every screen:
    /// the crop the design calls for is already baked into the asset, so
    /// nothing more needs to be cut off to make it fit a tall or short device.
    func frame(fitting size: CGSize) -> CGRect {
        guard size.width > 0, size.height > 0 else { return .zero }
        var width = size.width
        var height = width / aspect
        if height > size.height {
            height = size.height
            width = height * aspect
        }
        return CGRect(
            x: (size.width - width) / 2,
            y: (size.height - height) / 2,
            width: width,
            height: height
        )
    }

    /// Where the *whole* master artwork would sit if this slice is fitted
    /// into `size` — mostly off-screen, which is exactly the point.
    ///
    /// Strokes are stored against this frame rather than the visible one, so
    /// every step shares a single coordinate space no matter how tightly it
    /// happens to be cropped.
    func masterFrame(fitting size: CGSize) -> CGRect {
        let visible = frame(fitting: size)
        guard rect.width > 0, rect.height > 0 else { return visible }
        let width = visible.width / rect.width
        let height = visible.height / rect.height
        return CGRect(
            x: visible.minX - rect.minX * width,
            y: visible.minY - rect.minY * height,
            width: width,
            height: height
        )
    }
}
