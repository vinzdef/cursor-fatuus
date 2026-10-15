import AppKit

final class SpotlightController: NSObject {
    private let settings: Settings
    private var windows: [OverlayWindow] = []
    private var displayLink: CADisplayLink?
    private var screenObserver: NSObjectProtocol?

    init(settings: Settings) {
        self.settings = settings
        super.init()
        settings.onChange = { [weak self] in self?.apply() }
    }

    func apply() {
        guard settings.enabled, settings.opacity > 0, settings.color != nil || settings.blurRadius > 0 || settings.invert else {
            stop()
            return
        }
        if windows.isEmpty {
            start()
        }
        windows.forEach(configure)
    }

    private func configure(_ window: OverlayWindow) {
        CATransaction.begin()
        CATransaction.setDisableActions(true)
        window.setRadius(settings.radius)
        window.setFade(color: settings.color, softness: settings.softness, opacity: settings.opacity)
        window.setEffects(blurRadius: settings.blurRadius, invert: settings.invert)
        CATransaction.commit()
    }

    private func start() {
        rebuildWindows()
        screenObserver = NotificationCenter.default.addObserver(
            forName: NSApplication.didChangeScreenParametersNotification, object: nil, queue: .main
        ) { [weak self] _ in
            self?.rebuildWindows()
        }
    }

    private func stop() {
        if let screenObserver { NotificationCenter.default.removeObserver(screenObserver) }
        screenObserver = nil
        displayLink?.invalidate()
        displayLink = nil
        windows.forEach { $0.orderOut(nil) }
        windows = []
    }

    private func rebuildWindows() {
        windows.forEach { $0.orderOut(nil) }
        windows = NSScreen.screens.map { screen in
            let window = OverlayWindow(screen: screen)
            configure(window)
            window.orderFrontRegardless()
            return window
        }
        displayLink?.invalidate()
        displayLink = NSScreen.screens.first?.displayLink(target: self, selector: #selector(tick))
        displayLink?.add(to: .main, forMode: .common)
    }

    @objc private func tick(_ link: CADisplayLink) {
        let mouse = NSEvent.mouseLocation
        CATransaction.begin()
        CATransaction.setDisableActions(true)
        for window in windows {
            // Each screen draws the halo in its own coordinates, so it stays
            // continuous across display edges.
            window.halo.position = CGPoint(x: mouse.x - window.frame.minX, y: mouse.y - window.frame.minY)
        }
        CATransaction.commit()
    }
}
