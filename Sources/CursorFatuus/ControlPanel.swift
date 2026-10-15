import AppKit
import SwiftUI

/// Grid rather than Form so the color picker can span both columns.
struct ControlPanel: View {
    private static let swatches: [RGB] = [
        RGB(r: 1, g: 1, b: 1),
        RGB(r: 0, g: 0, b: 0),
        RGB(r: 1, g: 0.9, b: 0),
        RGB(r: 1, g: 0.5, b: 0),
        RGB(r: 1, g: 0, b: 0),
        RGB(r: 1, g: 0, b: 1),
        RGB(r: 0, g: 1, b: 1),
        RGB(r: 0, g: 1, b: 0),
        RGB(r: 0, g: 0.4, b: 1),
    ]

    @ObservedObject var settings: Settings
    @State private var showsPicker = false

    private var isCustomColor: Bool {
        settings.color.map { !Self.swatches.contains($0) } ?? false
    }

    var body: some View {
        VStack(alignment: .leading, spacing: 12) {
            Grid(alignment: .leading, horizontalSpacing: 10, verticalSpacing: 10) {
                row("Enabled") {
                    Toggle("Enabled", isOn: $settings.enabled).labelsHidden()
                }
                row("Color") { swatchRow }
                if showsPicker {
                    GridRow {
                        ColorField(color: $settings.color)
                            .gridCellColumns(2)
                    }
                }
                row("Opacity") {
                    Slider(value: $settings.opacity, in: 0...1)
                }
                row("Blur") {
                    Slider(value: $settings.blurRadius, in: Settings.blurRange)
                }
                row("Radius") {
                    Slider(value: $settings.radius, in: Settings.radiusRange)
                }
                row("Softness") {
                    Slider(value: $settings.softness, in: 0...1)
                }
                row("Invert") {
                    Toggle("Invert", isOn: $settings.invert).labelsHidden()
                }
            }
            HStack {
                Button("Donate") { NSWorkspace.shared.open(URL(string: "https://vincent.codes/donate")!) }
                Spacer()
                Button("Quit") { NSApp.terminate(nil) }
            }
        }
        .toggleStyle(.switch)
        .padding()
        .frame(width: 330)
    }

    private func row(_ label: String, @ViewBuilder content: () -> some View) -> some View {
        GridRow {
            Text(label).gridColumnAlignment(.trailing)
            content()
        }
    }

    private var swatchRow: some View {
        HStack(spacing: 4) {
            Button {
                settings.color = nil
            } label: {
                Image(systemName: "circle.slash")
                    .font(.system(size: settings.color == nil ? 16 : 14, weight: settings.color == nil ? .bold : .regular))
                    .frame(width: 16, height: 16)
            }
            .buttonStyle(.plain)
            .help("None")
            ForEach(Self.swatches, id: \.self) { swatch in
                Button {
                    settings.color = swatch
                } label: {
                    swatchCircle(Circle().fill(Color(.sRGB, red: swatch.r, green: swatch.g, blue: swatch.b)), selected: settings.color == swatch)
                }
                .buttonStyle(.plain)
            }
            Button {
                showsPicker.toggle()
            } label: {
                swatchCircle(Circle().fill(AngularGradient(colors: ColorField.hues, center: .center)),
                             selected: isCustomColor || showsPicker)
            }
            .buttonStyle(.plain)
            .help("Custom")
        }
    }

    private func swatchCircle(_ fill: some View, selected: Bool) -> some View {
        fill
            .overlay(Circle().stroke(Color.primary, lineWidth: selected ? 2 : 0.5))
            .frame(width: 16, height: 16)
    }
}
