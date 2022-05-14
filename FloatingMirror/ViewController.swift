//
//  ViewController.swift
//  FloatingMirror
//
//  Created by Chiwon Song on 2022/05/10.
//

import AVFoundation
import Cocoa
import RxSwift

class ViewController: NSViewController {
    private weak var runtimeData: RuntimeData!
    private let disposeBag = DisposeBag()

    private let cameraSession = AVCaptureSession()
    private var previewLayer: AVCaptureVideoPreviewLayer?

    override func viewDidLoad() {
        super.viewDidLoad()

        runtimeData = (NSApplication.shared.delegate as? AppDelegate)?.runtimeData

        view.wantsLayer = true
        view.layer?.backgroundColor = NSColor.black.cgColor

        requestPermission()
            .filter { $0 }
            .subscribe(onNext: { [weak self] _ in
                self?.setupCameraPreview()
            })
            .disposed(by: disposeBag)

        binding()
    }

    private func binding() {
        runtimeData.windowSize
            .subscribe(onNext: { [weak self] size in
                guard let self = self else { return }
                self.previewLayer?.frame = CGRect(x: 0, y: 0, width: size, height: size)
                self.view.layer?.cornerRadius = size / 2
            })
            .disposed(by: disposeBag)
    }

    private func setupCameraPreview() {
        guard let device = AVCaptureDevice.default(for: .video),
        let input = try? AVCaptureDeviceInput(device: device) else { return }
        
        cameraSession.sessionPreset = .high
        cameraSession.addInput(input)

        previewLayer = AVCaptureVideoPreviewLayer(session: cameraSession)
        if let preview = previewLayer {
            view.layer?.addSublayer(preview)
            preview.videoGravity = .resizeAspectFill
            preview.frame = view.bounds
        }
        
        if let connection = previewLayer?.connection, connection.isVideoMirroringSupported {
            connection.automaticallyAdjustsVideoMirroring = false
            connection.isVideoMirrored = true
        }
    }
    
    override func viewDidAppear() {
        cameraSession.startRunning()
    }
    
    override func viewWillDisappear() {
        cameraSession.stopRunning()
    }

    private func requestPermission() -> Observable<Bool> {
        return Observable.create { emitter in
            switch AVCaptureDevice.authorizationStatus(for: .video) {
            case .authorized: // The user has previously granted access to the camera.
                emitter.onNext(true)
                emitter.onCompleted()

            case .notDetermined: // The user has not yet been asked for camera access.
                AVCaptureDevice.requestAccess(for: .video) { granted in
                    emitter.onNext(granted)
                    emitter.onCompleted()
                }

            case .denied: // The user has previously denied access.
                emitter.onNext(false)
                emitter.onCompleted()

            case .restricted: // The user can't grant access due to restrictions.
                emitter.onNext(false)
                emitter.onCompleted()

            default:
                emitter.onCompleted()
                break
            }

            return Disposables.create()
        }
    }

    override func mouseDown(with event: NSEvent) {
        guard let window = view.window else { return }

        let startingPoint = event.locationInWindow

        window.trackEvents(matching: [.leftMouseDragged, .leftMouseUp], timeout: .infinity, mode: .default) { event, stop in
            guard let event = event else { return }
            switch event.type {
            case .leftMouseUp:
                NSApp.postEvent(event, atStart: false)
                stop.pointee = true

            case .leftMouseDragged:
                let currentPoint = event.locationInWindow
                if abs(currentPoint.x - startingPoint.x) >= 5 || abs(currentPoint.y - startingPoint.y) >= 5 {
                    stop.pointee = true
                    window.performDrag(with: event)
                }

            default:
                break
            }
        }
    }
}
