//
//  VideoLoopView.swift
//  ARDrawing



import AVFoundation
import SwiftUI

struct VideoLoopView: UIViewRepresentable {
    /// Bundle resource name, without the extension.
    let resource: String
    var fileExtension: String = "mp4"

    func makeUIView(context: Context) -> LoopingVideoView {
        LoopingVideoView(resource: resource, fileExtension: fileExtension)
    }

    func updateUIView(_ uiView: LoopingVideoView, context: Context) {}

    static func dismantleUIView(_ uiView: LoopingVideoView, coordinator: ()) {
        uiView.stop()
    }
}

/// Same loop, for a clip that isn't in the bundle — a Firebase Storage
/// download URL, for instance. `url` is `Equatable`, so SwiftUI recreates
/// the underlying player when it changes (a resolved clip replacing a
/// placeholder, say) rather than reusing a player that's already playing
/// something else.
struct RemoteVideoLoopView: UIViewRepresentable {
    let url: URL

    func makeUIView(context: Context) -> LoopingVideoView {
        LoopingVideoView(url: url)
    }

    func updateUIView(_ uiView: LoopingVideoView, context: Context) {
        uiView.replace(url: url)
    }

    static func dismantleUIView(_ uiView: LoopingVideoView, coordinator: ()) {
        uiView.stop()
    }
}

final class LoopingVideoView: UIView {
    override class var layerClass: AnyClass { AVPlayerLayer.self }

    private var player: AVQueuePlayer?
    private var looper: AVPlayerLooper?
    private var currentURL: URL?

    private var playerLayer: AVPlayerLayer {
        layer as! AVPlayerLayer
    }

    convenience init(resource: String, fileExtension: String) {
        let url = Bundle.main.url(forResource: resource, withExtension: fileExtension)
        assert(url != nil, "Missing \(resource).\(fileExtension) in the app bundle")
        self.init(url: url)
    }

    convenience init(url: URL) {
        self.init(url: Optional(url))
    }

    /// The true designated initializer. `url` is optional only so the
    /// bundle-resource convenience initializer above still produces a
    /// (blank) view when the asset is missing, rather than crashing
    /// outside of debug builds.
    private init(url: URL?) {
        super.init(frame: .zero)
        backgroundColor = .clear

        playerLayer.videoGravity = .resizeAspectFill

        NotificationCenter.default.addObserver(
            self,
            selector: #selector(resume),
            name: UIApplication.didBecomeActiveNotification,
            object: nil
        )

        if let url {
            start(url: url)
        }
    }

    required init?(coder: NSCoder) { fatalError("init(coder:) has not been implemented") }

    /// Swaps the playing clip. No-ops if it's already showing this URL, so
    /// SwiftUI re-rendering the wrapper doesn't restart playback from the
    /// beginning on every body evaluation.
    func replace(url: URL) {
        guard url != currentURL else { return }
        start(url: url)
    }

    private func start(url: URL) {
        currentURL = url

        let item = AVPlayerItem(url: url)
        let player = AVQueuePlayer(playerItem: item)
        player.isMuted = true
        // Nothing here should interrupt the user's own audio.
        player.preventsDisplaySleepDuringVideoPlayback = false

        self.looper = AVPlayerLooper(player: player, templateItem: item)
        self.player = player
        playerLayer.player = player
        player.play()
    }

    /// Playback stops when the app is backgrounded, so it needs restarting
    /// when the user comes back.
    @objc private func resume() {
        player?.play()
    }

    func stop() {
        player?.pause()
        NotificationCenter.default.removeObserver(self)
    }

    deinit {
        NotificationCenter.default.removeObserver(self)
    }
}
