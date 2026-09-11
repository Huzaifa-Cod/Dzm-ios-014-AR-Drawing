//
//  CameraPreviewView.swift
//  ARDrawing
//
//  Live back-camera passthrough behind the editor canvas, the video
//  recording backing the Record tool, and still capture backing the
//  Photo tool. Stills go through `AVCapturePhotoOutput` rather than a
//  window screenshot — `AVCaptureVideoPreviewLayer`'s video content is
//  hardware-composited and simply does not show up in a
//  `drawHierarchy`/`layer.render` snapshot; it renders black. A real
//  photo is the only reliable way to get actual camera pixels.
//

import AVFoundation
import Combine
import SwiftUI

/// Thin handle the SwiftUI side holds to imperatively trigger a photo
/// capture and to map screen geometry (the canvas's on-screen frame)
/// onto the camera's actual image space — `CameraPreviewView` itself is
/// a value type recreated on every render, so this is what survives
/// across those and reaches the live `PreviewView` underneath.
final class CameraController: ObservableObject {
    fileprivate weak var previewView: PreviewView?

    /// `nil` on the Simulator, or if the camera never connected.
    func capturePhoto(completion: @escaping (UIImage?) -> Void) {
        guard let previewView else {
            completion(nil)
            return
        }
        previewView.capturePhoto(completion: completion)
    }

    /// Maps a rect in the preview's own on-screen coordinate space
    /// (e.g. the canvas's current frame, zoom/offset already applied)
    /// to a normalized (0...1) rect in the camera's full, uncropped
    /// image — accounting for the aspect-fill cropping the preview
    /// applies. This is Apple's documented technique for aligning an
    /// overlay with what the camera actually captures.
    func normalizedRect(forLayerRect rect: CGRect) -> CGRect? {
        previewView?.normalizedRect(forLayerRect: rect)
    }
}

struct CameraPreviewView: UIViewRepresentable {
    @ObservedObject var controller: CameraController
    /// Torch (device flashlight) state — the Flash tool in the editor
    /// toolbar drives this.
    var isTorchOn: Bool = false
    /// Declarative record control: flipping this true/false starts and
    /// stops `AVCaptureMovieFileOutput` on the session backing this
    /// preview. Video-only — no microphone input is attached, so
    /// recording needs no extra permission beyond the camera's.
    var isRecording: Bool = false
    /// Fires once with the finished clip's temporary file URL after
    /// `isRecording` goes back to false. The caller decides whether to
    /// save it (e.g. `UISaveVideoAtPathToSavedPhotosAlbum`) or discard
    /// it, then must delete the temp file either way.
    var onVideoFinished: ((URL) -> Void)?

    func makeUIView(context: Context) -> PreviewView {
        let view = PreviewView()
        controller.previewView = view
        return view
    }

    func updateUIView(_ uiView: PreviewView, context: Context) {
        uiView.setTorch(on: isTorchOn)
        uiView.setRecording(isRecording, onFinished: onVideoFinished)
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
    private let movieOutput = AVCaptureMovieFileOutput()
    private let photoOutput = AVCapturePhotoOutput()
    /// Set once the back camera input is added — the torch lives on the
    /// device itself, not the session.
    private var camera: AVCaptureDevice?

    private var isRecordingInternally = false
    private var onRecordingFinished: ((URL) -> Void)?
    private var photoCompletion: ((UIImage?) -> Void)?

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

        if session.canAddOutput(movieOutput) {
            session.addOutput(movieOutput)
        }
        if session.canAddOutput(photoOutput) {
            session.addOutput(photoOutput)
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

    func setRecording(_ shouldRecord: Bool, onFinished: ((URL) -> Void)?) {
        if shouldRecord, !isRecordingInternally {
            // `startRecording` raises an uncatchable NSException (not a
            // Swift error) when the output has no active video
            // connection — no camera on the Simulator, or a session
            // that never got permission on device. Guarding here is the
            // only way to avoid that taking the whole app down.
            guard movieOutput.connection(with: .video) != nil else { return }
            isRecordingInternally = true
            onRecordingFinished = onFinished
            let url = FileManager.default.temporaryDirectory
                .appendingPathComponent(UUID().uuidString)
                .appendingPathExtension("mov")
            movieOutput.startRecording(to: url, recordingDelegate: self)
        } else if !shouldRecord, isRecordingInternally {
            isRecordingInternally = false
            movieOutput.stopRecording()
        }
    }

    func capturePhoto(completion: @escaping (UIImage?) -> Void) {
        guard photoOutput.connection(with: .video) != nil else {
            completion(nil)
            return
        }
        photoCompletion = completion
        photoOutput.capturePhoto(with: AVCapturePhotoSettings(), delegate: self)
    }

    func normalizedRect(forLayerRect rect: CGRect) -> CGRect {
        previewLayer.metadataOutputRectConverted(fromLayerRect: rect)
    }

    func stop() {
        guard session.isRunning else { return }
        DispatchQueue.global(qos: .userInitiated).async { [session] in
            session.stopRunning()
        }
    }
}

extension PreviewView: AVCaptureFileOutputRecordingDelegate {
    func fileOutput(
        _ output: AVCaptureFileOutput,
        didFinishRecordingTo outputFileURL: URL,
        from connections: [AVCaptureConnection],
        error: Error?
    ) {
        guard error == nil else { return }
        onRecordingFinished?(outputFileURL)
    }
}

extension PreviewView: AVCapturePhotoCaptureDelegate {
    func photoOutput(
        _ output: AVCapturePhotoOutput,
        didFinishProcessingPhoto photo: AVCapturePhoto,
        error: Error?
    ) {
        let image: UIImage? = {
            guard error == nil, let data = photo.fileDataRepresentation() else { return nil }
            return UIImage(data: data)
        }()
        DispatchQueue.main.async { [weak self] in
            self?.photoCompletion?(image)
            self?.photoCompletion = nil
        }
    }
}
