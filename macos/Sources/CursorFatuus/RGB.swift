import CoreGraphics

/// sRGB color, components in 0...1.
struct RGB: Hashable {
    let r: Double
    let g: Double
    let b: Double

    static let white = RGB(r: 1, g: 1, b: 1)

    func cgColor(alpha: Double) -> CGColor {
        CGColor(srgbRed: r, green: g, blue: b, alpha: alpha)
    }
}
