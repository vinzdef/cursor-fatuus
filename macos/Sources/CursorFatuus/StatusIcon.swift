import AppKit

/// Will-o'-the-wisp: a solid orb inside a faint flame with a curling tip, and
/// two sparks. Template image, so the menu bar tints it for light/dark.
enum StatusIcon {
    static func make() -> NSImage {
        let image = NSImage(size: NSSize(width: 18, height: 18), flipped: true) { _ in
            NSColor.black.withAlphaComponent(0.45).setFill()
            let flame = NSBezierPath()
            flame.move(to: NSPoint(x: 7, y: 16.8))
            flame.curve(to: NSPoint(x: 2.3, y: 12), controlPoint1: NSPoint(x: 4.4, y: 16.8), controlPoint2: NSPoint(x: 2.3, y: 14.6))
            flame.curve(to: NSPoint(x: 6, y: 6.3), controlPoint1: NSPoint(x: 2.3, y: 9.4), controlPoint2: NSPoint(x: 4, y: 7.5))
            flame.curve(to: NSPoint(x: 9.6, y: 3.2), controlPoint1: NSPoint(x: 7.8, y: 5.3), controlPoint2: NSPoint(x: 8.9, y: 4.6))
            flame.curve(to: NSPoint(x: 16, y: 1), controlPoint1: NSPoint(x: 10.6, y: 1.2), controlPoint2: NSPoint(x: 13.8, y: 0.4))
            flame.curve(to: NSPoint(x: 11.9, y: 6), controlPoint1: NSPoint(x: 13.3, y: 2), controlPoint2: NSPoint(x: 11.6, y: 3.4))
            flame.curve(to: NSPoint(x: 11.7, y: 12), controlPoint1: NSPoint(x: 12.3, y: 8), controlPoint2: NSPoint(x: 11.7, y: 10))
            flame.curve(to: NSPoint(x: 7, y: 16.8), controlPoint1: NSPoint(x: 11.7, y: 14.6), controlPoint2: NSPoint(x: 9.6, y: 16.8))
            flame.close()
            flame.fill()

            NSColor.black.setFill()
            NSBezierPath(ovalIn: NSRect(x: 3.9, y: 8.9, width: 6.2, height: 6.2)).fill()
            NSBezierPath(ovalIn: NSRect(x: 14.4, y: 6.4, width: 1.7, height: 1.7)).fill()
            NSBezierPath(ovalIn: NSRect(x: 13.6, y: 11.6, width: 1.2, height: 1.2)).fill()
            return true
        }
        image.isTemplate = true
        image.accessibilityDescription = "Cursor Fatuus"
        return image
    }
}
