//
//  CameraPreviewView.swift
//  ARDrawing
//
//  Live back-camera passthrough behind the editor canvas. Read-only
//  preview — this doesn't capture stills or video itself, the toolbar's
//  Photo/Record tools do that against the same session.
//

import AVFoundation
import SwiftUI

struct CameraPreviewView: UIViewRepresentable {
    /// Torch (device flashlight) state — the Flash tool in the editor
    /// toolbar drives this.
    var isTorchOn: Bool = false

    func makeUIView(context: Context) -> PreviewView {
        PreviewView()
    }

    func updateUIView(_ uiView: PreviewView, context: Context) {
        uiView.setTorch(on: isTorchOn)
    }

    static func dismantleUIView(_ uiView: PreviewView, coordinator: ()) {
        uiView.stop()
    }
}

final class PreviewView: UIView {
    override class var layerClass: AnyClass { AVCaptureVideoPreviewLayer.self }

    private var previewLayer: AVCaptureVideoPreviewLayer {
        layer as! AVCaptureVideoPreviewLayer
    }

    private let session = AVCaptureSession()
    /// Set once the back camera input is added — the torch lives on the
    /// device itself, not the session.
    private var camera: AVCaptureDevice?

    init() {
        super.init(frame: .zero)
        backgroundColor = .black
        previewLayer.videoGravity = .resizeAspectFill
        previewLayer.session = session
        configureSession()
    }

    required init?(coder: NSCoder) { fatalError("init(coder:) has not been implemented") }

    /// Permission is asked for here rather than eagerly at launch, since
    /// the camera is only ever needed once the user reaches the editor.
    private func configureSession() {
        switch AVCaptureDevice.authorizationStatus(for: .video) {
        case .authorized:
            startSession()
        case .notDetermined:
            AVCaptureDevice.requestAccess(for: .video) { [weak self] granted in
                guard granted else { return }
                self?.startSession()
            }
        default:
            break
        }
    }

    private func startSession() {
        session.beginConfiguration()
        session.sessionPreset = .high

        if
            let device = AVCaptureDevice.default(.builtInWideAngleCamera, for: .video, position: .back),
            let input = try? AVCaptureDeviceInput(device: device),
            session.canAddInput(input)
        {
            session.addInput(input)
            camera = device
        }

        session.commitConfiguration()

        DispatchQueue.global(qos: .userInitiated).async { [session] in
            session.startRunning()
        }
    }

    /// No-ops on the Simulator (no torch hardware) and on devices whose
    /// back camera lacks one.
    func setTorch(on: Bool) {
        guard let camera, camera.hasTorch, camera.isTorchAvailable else { return }
        guard (camera.torchMode == .on) != on else { return }
        try? camera.lockForConfiguration()
        camera.torchMode = on ? .on : .off
        camera.unlockForConfiguration()
    }

    func stop() {
        guard session.isRunning else { return }
        DispatchQueue.global(qos: .userInitiated).async { [session] in
            session.stopRunning()
        }
    }
}
