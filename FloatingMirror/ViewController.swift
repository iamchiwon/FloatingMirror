//
//  ViewController.swift
//  FloatingMirror
//
//  Created by Chiwon Song on 2022/05/10.
//

import Cocoa
import RxSwift

class ViewController: NSViewController {
    weak var runtimeData: RuntimeData!
    let disposeBag = DisposeBag()

    override func viewDidLoad() {
        super.viewDidLoad()

        runtimeData = (NSApplication.shared.delegate as? AppDelegate)?.runtimeData

        view.wantsLayer = true
        view.layer?.backgroundColor = NSColor.black.cgColor

        binding()
    }

    private func binding() {
        runtimeData.windowSize
            .map { $0 / 2 }
            .subscribe(onNext: { [weak self] size in
                self?.view.layer?.cornerRadius = size
            })
            .disposed(by: disposeBag)
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
