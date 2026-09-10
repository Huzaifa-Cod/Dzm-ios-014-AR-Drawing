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

final class LoopingVideoView: UIView {
    override class var layerClass: AnyClass { AVPlayerLayer.self }

    private var player: AVQueuePlayer?
    private var looper: AVPlayerLooper?

    private var playerLayer: AVPlayerLayer {
        layer as! AVPlayerLayer
    }

    init(resource: String, fileExtension: String) {
        super.init(frame: .zero)
        backgroundColor = .clear

        guard let url = Bundle.main.url(forResource: resource, withExtension: fileExtension) else {
            assertionFailure("Missing \(resource).\(fileExtension) in the app bundle")
            return
        }

        let item = AVPlayerItem(url: url)
        let player = AVQueuePlayer(playerItem: item)
        player.isMuted = true
        // Nothing here should interrupt the user's own audio.
        player.preventsDisplaySleepDuringVideoPlayback = false

        self.looper = AVPlayerLooper(player: player, templateItem: item)
        self.player = player

        playerLayer.player = player
        playerLayer.videoGravity = .resizeAspectFill

        NotificationCenter.default.addObserver(
            self,
            selector: #selector(resume),
            name: UIApplication.didBecomeActiveNotification,
            object: nil
        )
        player.play()
    }

    required init?(coder: NSCoder) { fatalError("init(coder:) has not been implemented") }

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
