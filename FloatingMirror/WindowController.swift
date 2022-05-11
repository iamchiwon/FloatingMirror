//
//  WindowController.swift
//  FloatingMirror
//
//  Created by iamchiwon on 2022/05/11.
//

import AppKit
import Foundation
import RxSwift

class WindowController: NSWindowController, NSWindowDelegate {
    weak var runtimeData: RuntimeData!

    override func windowDidLoad() {
        super.windowDidLoad()

        runtimeData = (NSApplication.shared.delegate as? AppDelegate)?.runtimeData

        window?.delegate = self
        window?.level = .floating
        window?.isOpaque = false
        window?.backgroundColor = NSColor.white.withAlphaComponent(0.01)
    }

    func windowWillResize(_ sender: NSWindow, to frameSize: NSSize) -> NSSize {
        runtimeData.windowSize.onNext(frameSize.width)
        return NSSize(width: frameSize.width, height: frameSize.width)
    }
}
