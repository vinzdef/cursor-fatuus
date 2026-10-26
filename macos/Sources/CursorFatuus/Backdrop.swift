import QuartzCore

/// Private Core Animation API: `CABackdropLayer` renders whatever the window
/// server composites behind the window, through `CAFilter`s. This is what
/// NSVisualEffectView uses internally. It needs no Screen Recording permission,
/// but may break on any macOS update.
enum Backdrop {
    static func makeLayer() -> CALayer? {
        guard let type = NSClassFromString("CABackdropLayer") as? CALayer.Type else { return nil }
        let layer = type.init()
        // Without this the layer only sees content inside its own window.
        layer.setValue(true, forKey: "windowServerAware")
        return layer
    }

    static func filters(blurRadius: Double, invert: Bool) -> [Any] {
        var result: [Any] = []
        if blurRadius > 0, let filter = filter("gaussianBlur") {
            filter.setValue(blurRadius, forKey: "inputRadius")
            result.append(filter)
        }
        if invert, let filter = filter("colorInvert") {
            result.append(filter)
        }
        return result
    }

    private static func filter(_ type: String) -> NSObject? {
        let selector = NSSelectorFromString("filterWithType:")
        guard let cls = NSClassFromString("CAFilter") as? NSObject.Type, cls.responds(to: selector) else { return nil }
        return cls.perform(selector, with: type)?.takeUnretainedValue() as? NSObject
    }
}
