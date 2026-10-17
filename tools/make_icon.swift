// Render the pane icon (black squircle, white Wi-Fi glyph) into an .iconset, then iconutil -> .icns
import AppKit

let out = CommandLine.arguments[1]
try? FileManager.default.createDirectory(atPath: out, withIntermediateDirectories: true)

func render(_ px: Int) -> Data {
    let s = CGFloat(px)
    let rep = NSBitmapImageRep(bitmapDataPlanes: nil, pixelsWide: px, pixelsHigh: px, bitsPerSample: 8,
                               samplesPerPixel: 4, hasAlpha: true, isPlanar: false,
                               colorSpaceName: .deviceRGB, bytesPerRow: 0, bitsPerPixel: 0)!
    NSGraphicsContext.saveGraphicsState()
    NSGraphicsContext.current = NSGraphicsContext(bitmapImageRep: rep)

    let rect = NSRect(x: 0, y: 0, width: s, height: s).insetBy(dx: s * 0.04, dy: s * 0.04)
    let shape = NSBezierPath(roundedRect: rect, xRadius: rect.width * 0.225, yRadius: rect.width * 0.225)
    NSGradient(starting: NSColor(white: 0.17, alpha: 1), ending: NSColor(white: 0.02, alpha: 1))!
        .draw(in: shape, angle: -90)
    NSColor(white: 1, alpha: 0.12).setStroke()
    shape.lineWidth = max(1, s * 0.006)
    shape.stroke()

    let cfg = NSImage.SymbolConfiguration(pointSize: s * 0.42, weight: .semibold)
        .applying(.init(paletteColors: [.white]))
    let glyph = NSImage(systemSymbolName: "wifi", accessibilityDescription: nil)!.withSymbolConfiguration(cfg)!
    let g = glyph.size
    glyph.draw(in: NSRect(x: (s - g.width) / 2, y: (s - g.height) / 2 - s * 0.01, width: g.width, height: g.height))

    NSGraphicsContext.restoreGraphicsState()
    return rep.representation(using: .png, properties: [:])!
}

for base in [16, 32, 128, 256, 512] {
    try! render(base).write(to: URL(fileURLWithPath: "\(out)/icon_\(base)x\(base).png"))
    try! render(base * 2).write(to: URL(fileURLWithPath: "\(out)/icon_\(base)x\(base)@2x.png"))
}
