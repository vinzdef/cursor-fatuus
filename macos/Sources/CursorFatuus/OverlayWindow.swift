import AppKit

/// Transparent, click-through window covering one screen. Sits above regular
/// windows; the hardware cursor is always drawn on top of it.
final class OverlayWindow: NSWindow {
    /// Moved to the cursor each frame; holds the backdrop and the tint.
    let halo = CALayer()
    private let spotlight = CAGradientLayer()
    private let backdrop = Backdrop.makeLayer()
    private let backdropMask = CAGradientLayer()

    init(screen: NSScreen) {
        super.init(contentRect: screen.frame, styleMask: .borderless, backing: .buffered, defer: false)
        isOpaque = false
        backgroundColor = .clear
        hasShadow = false
        ignoresMouseEvents = true
        level = .screenSaver
        collectionBehavior = [.canJoinAllSpaces, .stationary, .fullScreenAuxiliary, .ignoresCycle]

        spotlight.contentsScale = screen.backingScaleFactor
        backdropMask.contentsScale = screen.backingScaleFactor
        if let backdrop {
            backdrop.mask = backdropMask
            backdrop.masksToBounds = true
            halo.addSublayer(backdrop)
        }
        halo.addSublayer(spotlight)

        let view = NSView()
        view.wantsLayer = true
        view.layer?.addSublayer(halo)
        contentView = view
    }

    func setRadius(_ radius: CGFloat) {
        let bounds = CGRect(x: 0, y: 0, width: radius * 2, height: radius * 2)
        halo.bounds = bounds
        spotlight.frame = bounds
        backdrop?.frame = bounds
        // The mask alone leaves the square's corners showing with invert on.
        backdrop?.cornerRadius = radius
        backdropMask.frame = bounds
    }

    func setEffects(blurRadius: Double, invert: Bool) {
        backdrop?.filters = Backdrop.filters(blurRadius: blurRadius, invert: invert)
        backdrop?.isHidden = !(blurRadius > 0 || invert)
    }

    /// nil color hides the tint, leaving blur and invert unobstructed.
    /// Opacity goes into the gradients rather than `halo.opacity`: group opacity
    /// renders the halo offscreen, where the backdrop sees nothing behind it.
    func setFade(color: RGB?, softness: Double, opacity: Double) {
        spotlight.isHidden = color == nil
        if let color { Falloff.apply(to: spotlight, color: color, softness: softness, opacity: opacity) }
        Falloff.apply(to: backdropMask, color: .white, softness: softness, opacity: opacity)
    }
}

/// Solid disk whose outer `softness` fraction of the radius fades to
/// transparent: 0 is a hard-edged circle, 1 a single fade from the center.
/// The fade follows 1 - smoothstep, since a linear ramp shows a visible ring
/// where it starts, sampled into enough stops to look continuous.
enum Falloff {
    private static let steps = 32
    /// Keeps a hard edge antialiased.
    private static let minFade = 0.02

    static func apply(to layer: CAGradientLayer, color: RGB, softness: Double, opacity: Double) {
        let fade = max(softness, minFade)
        let fractions = (0...steps).map { Double($0) / Double(steps) }
        let positions = [0] + fractions.map { 1 - fade + fade * $0 }
        let alphas = [1] + fractions.map { 1 - $0 * $0 * (3 - 2 * $0) }
        layer.type = .radial
        layer.startPoint = CGPoint(x: 0.5, y: 0.5)
        layer.endPoint = CGPoint(x: 1, y: 1)
        layer.locations = positions.map { NSNumber(value: $0) }
        layer.colors = alphas.map { color.cgColor(alpha: $0 * opacity) }
    }
}
