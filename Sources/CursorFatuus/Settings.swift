import Combine
import Foundation

/// User-facing options, persisted to UserDefaults on every change.
final class Settings: ObservableObject {
    static let radiusRange: ClosedRange<Double> = 1...300
    static let blurRange: ClosedRange<Double> = 0...10

    var onChange: (() -> Void)?

    @Published var enabled: Bool { didSet { save(enabled, "enabled") } }
    /// nil shows no color, leaving blur and invert unobstructed.
    @Published var color: RGB? { didSet { save(color.map { [$0.r, $0.g, $0.b] } ?? [], "color") } }
    /// Opacity of the whole halo: color, blur and invert together.
    @Published var opacity: Double { didSet { save(opacity, "opacity") } }
    /// 0 turns blur off.
    @Published var blurRadius: Double { didSet { save(blurRadius, "blurRadius") } }
    @Published var invert: Bool { didSet { save(invert, "invert") } }
    @Published var radius: Double { didSet { save(radius, "radius") } }
    /// 0 is a hard-edged circle; 1 fades all the way from the center.
    @Published var softness: Double { didSet { save(softness, "softness") } }

    private let defaults = UserDefaults.standard

    init() {
        defaults.register(defaults: [
            "enabled": true,
            "color": [1.0, 1.0, 1.0],
            "opacity": 0.85,
            "blurRadius": 0.0,
            "invert": false,
            "radius": 80.0,
            "softness": 1.0,
        ])
        enabled = defaults.bool(forKey: "enabled")
        let c = defaults.array(forKey: "color") as? [Double] ?? []
        color = c.count == 3 ? RGB(r: c[0], g: c[1], b: c[2]) : nil
        opacity = defaults.double(forKey: "opacity")
        blurRadius = defaults.double(forKey: "blurRadius")
        invert = defaults.bool(forKey: "invert")
        radius = defaults.double(forKey: "radius")
        softness = defaults.double(forKey: "softness")
    }

    private func save(_ value: Any, _ key: String) {
        defaults.set(value, forKey: key)
        onChange?()
    }
}
