//
//  ViewController.swift
//  FloatingMirror
//
//  Created by Chiwon Song on 2022/05/10.
//

import Cocoa

class ViewController: NSViewController {
    override func viewDidLoad() {
        super.viewDidLoad()
    }

    override func viewDidAppear() {
        view.window?.level = .floating
    }

    override func mouseDown(with event: NSEvent) {
        guard let window = view.window else { return }

        let startingPoint = event.locationInWindow

        window.trackEvents(matching: [.leftMouseDragged, .leftMouseUp], timeout: .infinity, mode: .default) { event, stop in
            guard let event = event  else { return }
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
