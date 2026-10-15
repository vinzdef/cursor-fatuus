import AppKit
import SwiftUI

/// Inline HSB picker: saturation/brightness square above a hue bar, filling
/// the available width. Lives in the panel because the system color panel
/// detaches from menu bar popovers.
struct ColorField: View {
    @Binding var color: RGB?

    // Kept separately so hue survives passing through gray or black.
    @State private var hue: Double = 0
    @State private var saturation: Double = 1
    @State private var brightness: Double = 1

    static let hues = stride(from: 0.0, through: 1.0, by: 1.0 / 6).map { Color(hue: $0, saturation: 1, brightness: 1) }
    private static let markerSize: CGFloat = 10

    var body: some View {
        VStack(spacing: 8) {
            GeometryReader { geo in
                ZStack(alignment: .topLeading) {
                    LinearGradient(colors: [.white, Color(hue: hue, saturation: 1, brightness: 1)], startPoint: .leading, endPoint: .trailing)
                        .overlay(LinearGradient(colors: [.clear, .black], startPoint: .top, endPoint: .bottom))
                        .clipShape(RoundedRectangle(cornerRadius: 4))
                    marker.position(x: saturation * geo.size.width, y: (1 - brightness) * geo.size.height)
                }
                .contentShape(Rectangle())
                .gesture(DragGesture(minimumDistance: 0).onChanged { drag in
                    saturation = clamp(drag.location.x / geo.size.width)
                    brightness = 1 - clamp(drag.location.y / geo.size.height)
                    commit()
                })
            }
            .frame(height: 120)

            GeometryReader { geo in
                ZStack(alignment: .topLeading) {
                    LinearGradient(colors: Self.hues, startPoint: .leading, endPoint: .trailing)
                        .clipShape(RoundedRectangle(cornerRadius: 4))
                    marker.position(x: hue * geo.size.width, y: geo.size.height / 2)
                }
                .contentShape(Rectangle())
                .gesture(DragGesture(minimumDistance: 0).onChanged { drag in
                    hue = clamp(drag.location.x / geo.size.width)
                    commit()
                })
            }
            .frame(height: 12)
        }
        // Room for markers sitting on the edges.
        .padding(Self.markerSize / 2)
        .onAppear(perform: load)
    }

    private var marker: some View {
        Circle()
            .stroke(Color.white, lineWidth: 2)
            .background(Circle().stroke(Color.black, lineWidth: 3))
            .frame(width: Self.markerSize, height: Self.markerSize)
    }

    private func clamp(_ value: Double) -> Double {
        min(max(value, 0), 1)
    }

    private func load() {
        guard let color else { return }
        let ns = NSColor(srgbRed: color.r, green: color.g, blue: color.b, alpha: 1)
        if ns.saturationComponent > 0, ns.brightnessComponent > 0 { hue = ns.hueComponent }
        saturation = ns.saturationComponent
        brightness = ns.brightnessComponent
    }

    private func commit() {
        guard let ns = NSColor(colorSpace: .sRGB, hue: hue, saturation: saturation, brightness: brightness, alpha: 1)
            .usingColorSpace(.sRGB) else { return }
        color = RGB(r: ns.redComponent, g: ns.greenComponent, b: ns.blueComponent)
    }
}
