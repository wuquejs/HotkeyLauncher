#!/usr/bin/env swift

import AppKit
import Foundation

let sizes = [16, 32, 64, 128, 256, 512, 1024]

func drawIcon(size: Int) -> NSImage {
    let s = CGFloat(size)
    let image = NSImage(size: NSSize(width: s, height: s))
    image.lockFocus()

    guard let ctx = NSGraphicsContext.current?.cgContext else {
        image.unlockFocus()
        return image
    }

    let cornerRadius = s * 0.22
    let rect = CGRect(x: 0, y: 0, width: s, height: s)
    let clipPath = CGPath(roundedRect: rect, cornerWidth: cornerRadius, cornerHeight: cornerRadius, transform: nil)
    ctx.addPath(clipPath)
    ctx.clip()

    let colorSpace = CGColorSpaceCreateDeviceRGB()
    let colors = [
        CGColor(red: 0.16, green: 0.18, blue: 0.38, alpha: 1.0),
        CGColor(red: 0.36, green: 0.22, blue: 0.58, alpha: 1.0),
    ] as CFArray
    let gradient = CGGradient(colorsSpace: colorSpace, colors: colors, locations: [0, 1])!
    ctx.drawLinearGradient(gradient, start: CGPoint(x: 0, y: s), end: CGPoint(x: s, y: 0), options: [])

    let keyW = s * 0.52
    let keyH = s * 0.38
    let keyX = (s - keyW) / 2
    let keyY = s * 0.22
    let keyRadius = keyW * 0.12

    ctx.setShadow(offset: CGSize(width: 0, height: -s * 0.015), blur: s * 0.03, color: CGColor(red: 0, green: 0, blue: 0, alpha: 0.4))

    let keyRect = CGRect(x: keyX, y: keyY, width: keyW, height: keyH)
    let keyPath = CGPath(roundedRect: keyRect, cornerWidth: keyRadius, cornerHeight: keyRadius, transform: nil)
    ctx.setFillColor(CGColor(red: 0.88, green: 0.90, blue: 0.93, alpha: 1.0))
    ctx.addPath(keyPath)
    ctx.fillPath()

    ctx.setShadow(offset: .zero, blur: 0)

    let inset = keyW * 0.06
    let topRect = keyRect.insetBy(dx: inset, dy: inset)
    let topPath = CGPath(roundedRect: topRect, cornerWidth: keyRadius * 0.8, cornerHeight: keyRadius * 0.8, transform: nil)
    ctx.setFillColor(CGColor(red: 0.96, green: 0.97, blue: 0.99, alpha: 1.0))
    ctx.addPath(topPath)
    ctx.fillPath()

    let arrowSize = s * 0.1
    let arrowCenterX = s / 2
    let arrowBaseY = keyY + keyH * 0.28
    let arrowTipY = keyY + keyH * 0.72

    ctx.setFillColor(CGColor(red: 0.30, green: 0.35, blue: 0.65, alpha: 1.0))
    ctx.beginPath()
    ctx.move(to: CGPoint(x: arrowCenterX, y: arrowTipY))
    ctx.addLine(to: CGPoint(x: arrowCenterX - arrowSize * 0.7, y: arrowBaseY))
    ctx.addLine(to: CGPoint(x: arrowCenterX + arrowSize * 0.7, y: arrowBaseY))
    ctx.closePath()
    ctx.fillPath()

    ctx.setStrokeColor(CGColor(red: 0.30, green: 0.35, blue: 0.65, alpha: 0.5))
    ctx.setLineWidth(s * 0.015)
    ctx.setLineCap(.round)

    let trailY = arrowTipY + s * 0.02
    for offset in [-s * 0.06, 0.0, s * 0.06] as [CGFloat] {
        ctx.beginPath()
        ctx.move(to: CGPoint(x: arrowCenterX + offset, y: trailY))
        ctx.addLine(to: CGPoint(x: arrowCenterX + offset, y: trailY + s * 0.03))
        ctx.strokePath()
    }

    let smallKeyW = keyW * 0.28
    let smallKeyH = keyH * 0.5
    let smallKeyRadius = smallKeyW * 0.12
    let smallKeyY = keyY - smallKeyH - s * 0.03

    ctx.setShadow(offset: CGSize(width: 0, height: -s * 0.008), blur: s * 0.015, color: CGColor(red: 0, green: 0, blue: 0, alpha: 0.3))

    let modifierLabels = ["\u{2318}", "\u{2325}", "\u{21E7}"]
    for i in 0..<3 {
        let x = keyX + (keyW - smallKeyW * 3 - s * 0.025 * 2) / 2 + CGFloat(i) * (smallKeyW + s * 0.025)
        let r = CGRect(x: x, y: smallKeyY, width: smallKeyW, height: smallKeyH)
        let p = CGPath(roundedRect: r, cornerWidth: smallKeyRadius, cornerHeight: smallKeyRadius, transform: nil)
        ctx.setFillColor(CGColor(red: 0.78, green: 0.80, blue: 0.85, alpha: 1.0))
        ctx.addPath(p)
        ctx.fillPath()
    }

    ctx.setShadow(offset: .zero, blur: 0)

    for i in 0..<3 {
        let label = modifierLabels[i]
        let x = keyX + (keyW - smallKeyW * 3 - s * 0.025 * 2) / 2 + CGFloat(i) * (smallKeyW + s * 0.025)
        let fontSize = smallKeyH * 0.5
        let attrs: [NSAttributedString.Key: Any] = [
            .font: NSFont.systemFont(ofSize: fontSize, weight: .medium),
            .foregroundColor: NSColor(red: 0.30, green: 0.32, blue: 0.42, alpha: 1.0),
        ]
        let text = NSAttributedString(string: label, attributes: attrs)
        let textSize = text.size()
        let textX = x + (smallKeyW - textSize.width) / 2
        let textY = smallKeyY + (smallKeyH - textSize.height) / 2
        text.draw(at: NSPoint(x: textX, y: textY))
    }

    ctx.setBlendMode(.screen)
    ctx.setStrokeColor(CGColor(red: 1, green: 1, blue: 1, alpha: 0.25))
    ctx.setLineWidth(s * 0.008)
    ctx.beginPath()
    ctx.move(to: CGPoint(x: keyX + keyRadius, y: keyY + keyH - inset))
    ctx.addLine(to: CGPoint(x: keyX + keyW - keyRadius, y: keyY + keyH - inset))
    ctx.strokePath()
    ctx.setBlendMode(.normal)

    image.unlockFocus()
    return image
}

let iconsetDir = "HotkeyLauncher.iconset"
try? FileManager.default.removeItem(atPath: iconsetDir)
try! FileManager.default.createDirectory(atPath: iconsetDir, withIntermediateDirectories: true)

for size in sizes {
    let img = drawIcon(size: size)
    guard let tiff = img.tiffRepresentation,
          let rep = NSBitmapImageRep(data: tiff),
          let png = rep.representation(using: .png, properties: [:]) else { continue }

    let name1x = "icon_\(size)x\(size).png"
    try! png.write(to: URL(fileURLWithPath: iconsetDir + "/" + name1x))

    if size <= 512 {
        let img2x = drawIcon(size: size * 2)
        guard let tiff2 = img2x.tiffRepresentation,
              let rep2 = NSBitmapImageRep(data: tiff2),
              let png2 = rep2.representation(using: .png, properties: [:]) else { continue }
        let at2x = "@2x"
        let name2x = "icon_\(size)x\(size)" + at2x + ".png"
        try! png2.write(to: URL(fileURLWithPath: iconsetDir + "/" + name2x))
    }
}

print("图标集已生成到 " + iconsetDir + "/")
print("运行：iconutil -c icns " + iconsetDir)
