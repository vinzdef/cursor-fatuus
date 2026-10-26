import AppKit
import SwiftUI

final class AppDelegate: NSObject, NSApplicationDelegate {
    private let settings = Settings()
    private lazy var spotlight = SpotlightController(settings: settings)
    private let popover = NSPopover()
    private var statusItem: NSStatusItem!

    func applicationDidFinishLaunching(_ notification: Notification) {
        spotlight.apply()

        popover.behavior = .transient
        popover.contentViewController = NSHostingController(rootView: ControlPanel(settings: settings))

        statusItem = NSStatusBar.system.statusItem(withLength: NSStatusItem.squareLength)
        statusItem.button?.image = StatusIcon.make()
        statusItem.button?.target = self
        statusItem.button?.action = #selector(togglePopover)
    }

    @objc private func togglePopover() {
        guard let button = statusItem.button else { return }
        if popover.isShown {
            popover.performClose(nil)
        } else {
            NSApp.activate()
            popover.show(relativeTo: button.bounds, of: button, preferredEdge: .minY)
        }
    }
}
