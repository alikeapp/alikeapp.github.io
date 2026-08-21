//
// Renders one 1200x630 link-preview card.
//
//   swift scripts/make-og-image.swift \
//     --icon assets/img/og-image.jpg \
//     --title Alike \
//     --tagline "Your camera roll, minus the near-duplicates." \
//     --out assets/img/og/en.jpg
//
// This is a pure renderer: every string it draws arrives as an argument. The
// locale list and the translated taglines are the wrapper's job
// (scripts/make-og-images.sh), so this file never learns to parse YAML.
//
// Why 1200x630 at all: Slack, iMessage, Telegram and WhatsApp only render the
// large card for a roughly 1.91:1 image. The site's og:image used to be the
// square 1024x1024 app artwork, and those clients answered by dropping the
// image and unfurling text only.
//
// CoreGraphics and CoreText, nothing else — no ImageMagick, no Pillow, no
// headless browser. The generated cards are committed, so CI (ubuntu) never
// runs this; it is a maintainer tool like scripts/fetch-app-store-badges.sh.
//

import CoreGraphics
import CoreText
import Foundation
import ImageIO
import UniformTypeIdentifiers

// MARK: - Arguments

func argument(_ name: String) -> String? {
    let args = CommandLine.arguments
    guard let i = args.firstIndex(of: "--\(name)"), i + 1 < args.count else { return nil }
    return args[i + 1]
}

func die(_ message: String) -> Never {
    FileHandle.standardError.write(Data("make-og-image: \(message)\n".utf8))
    exit(1)
}

guard let iconPath = argument("icon"),
      let title = argument("title"),
      let tagline = argument("tagline"),
      let outPath = argument("out")
else {
    die("usage: --icon <file> --title <text> --tagline <text> --out <file.jpg>")
}

// MARK: - Canvas

let W: CGFloat = 1200
let H: CGFloat = 630

// Everything that matters stays well inside the edges: clients do not all crop
// to the same aspect, and a tagline touching the edge loses its descenders
// first.
let margin: CGFloat = 88
let iconSize: CGFloat = 288
let gutter: CGFloat = 64

func rgb(_ hex: UInt32, _ alpha: CGFloat = 1) -> CGColor {
    CGColor(
        srgbRed: CGFloat((hex >> 16) & 0xFF) / 255,
        green: CGFloat((hex >> 8) & 0xFF) / 255,
        blue: CGFloat(hex & 0xFF) / 255,
        alpha: alpha
    )
}

// The ink end of the palette in assets/css/main.css, not the teal end: the app
// icon is itself teal on teal, so a teal card would swallow it. Dark ground,
// brand glow behind the icon, white type — legible in both Slack themes.
let inkTop = rgb(0x16272F)
let inkBottom = rgb(0x0E1417)
let brandTeal = rgb(0x1F9EB8)

let space = CGColorSpace(name: CGColorSpace.sRGB)!
guard let ctx = CGContext(
    data: nil,
    width: Int(W),
    height: Int(H),
    bitsPerComponent: 8,
    bytesPerRow: 0,
    space: space,
    bitmapInfo: CGImageAlphaInfo.noneSkipLast.rawValue
) else {
    die("could not create the drawing context")
}

// CoreText draws in this context's own bottom-left origin, so nothing here is
// flipped: a larger y is higher on the card.

// MARK: - Background

if let gradient = CGGradient(
    colorsSpace: space,
    colors: [inkTop, inkBottom] as CFArray,
    locations: [0, 1]
) {
    ctx.drawLinearGradient(
        gradient,
        start: CGPoint(x: 0, y: H),
        end: CGPoint(x: 0, y: 0),
        options: []
    )
}

// MARK: - Shapes

// The squircle iOS actually uses is a superellipse, not a rounded rectangle
// with circular corners, and CoreGraphics has no primitive for it — so the
// path is sampled from |x/a|^n + |y/b|^n = 1 with n = 5.
func superellipsePath(in rect: CGRect, exponent n: CGFloat = 5, samples: Int = 720) -> CGPath {
    let path = CGMutablePath()
    let a = rect.width / 2, b = rect.height / 2
    for i in 0...samples {
        let t = 2 * CGFloat.pi * CGFloat(i) / CGFloat(samples)
        let c = cos(t), s = sin(t)
        let x = rect.midX + a * (c < 0 ? -1 : 1) * pow(abs(c), 2 / n)
        let y = rect.midY + b * (s < 0 ? -1 : 1) * pow(abs(s), 2 / n)
        if i == 0 { path.move(to: CGPoint(x: x, y: y)) } else { path.addLine(to: CGPoint(x: x, y: y)) }
    }
    path.closeSubpath()
    return path
}

// MARK: - Type

// The system font by descriptor, never by name: that is what gives every
// script — Cyrillic, Polish, Turkish, Traditional Chinese — the standard
// cascade list. Naming "SFPro-Bold" would render tofu for zh-Hant.
func systemFont(size: CGFloat, bold: Bool) -> CTFont {
    let base = CTFontCreateUIFontForLanguage(.system, size, nil)
        ?? CTFontCreateWithName("Helvetica" as CFString, size, nil)
    guard bold else { return base }
    return CTFontCreateCopyWithSymbolicTraits(base, size, nil, .traitBold, .traitBold) ?? base
}

func paragraphStyle(lineHeight: CGFloat) -> CTParagraphStyle {
    // The settings hold raw pointers, so the values have to outlive the call
    // that reads them — hence the nested withUnsafePointer rather than `&x`
    // inline, which would hand CoreText a dangling pointer.
    var spacing = lineHeight
    var alignment = CTTextAlignment.left.rawValue
    return withUnsafePointer(to: &spacing) { linePointer in
        withUnsafePointer(to: &alignment) { alignmentPointer in
            let settings = [
                CTParagraphStyleSetting(
                    spec: .maximumLineHeight,
                    valueSize: MemoryLayout<CGFloat>.size,
                    value: linePointer
                ),
                CTParagraphStyleSetting(
                    spec: .minimumLineHeight,
                    valueSize: MemoryLayout<CGFloat>.size,
                    value: linePointer
                ),
                CTParagraphStyleSetting(
                    spec: .alignment,
                    valueSize: MemoryLayout<CTTextAlignment.RawValue>.size,
                    value: alignmentPointer
                ),
            ]
            return CTParagraphStyleCreate(settings, settings.count)
        }
    }
}

func attributed(_ text: String, font: CTFont, color: CGColor, lineHeight: CGFloat) -> CFAttributedString {
    NSAttributedString(
        string: text,
        attributes: [
            kCTFontAttributeName as NSAttributedString.Key: font,
            kCTForegroundColorAttributeName as NSAttributedString.Key: color,
            kCTParagraphStyleAttributeName as NSAttributedString.Key: paragraphStyle(lineHeight: lineHeight),
        ]
    ) as CFAttributedString
}

// Measuring and drawing are separate so the layout can be decided from real
// text metrics before anything is committed to the canvas.
func measure(_ string: CFAttributedString, width: CGFloat) -> (framesetter: CTFramesetter, size: CGSize) {
    let framesetter = CTFramesetterCreateWithAttributedString(string)
    let size = CTFramesetterSuggestFrameSizeWithConstraints(
        framesetter,
        CFRangeMake(0, 0),
        nil,
        CGSize(width: width, height: .greatestFiniteMagnitude),
        nil
    )
    return (framesetter, CGSize(width: ceil(size.width), height: ceil(size.height)))
}

func draw(_ framesetter: CTFramesetter, in rect: CGRect) {
    let path = CGPath(rect: rect, transform: nil)
    let frame = CTFramesetterCreateFrame(framesetter, CFRangeMake(0, 0), path, nil)
    CTFrameDraw(frame, ctx)
}

// MARK: - Layout

let titleFont = systemFont(size: 96, bold: true)
let taglineFont = systemFont(size: 38, bold: false)

let titleText = attributed(title, font: titleFont, color: rgb(0xFFFFFF), lineHeight: 106)
let taglineText = attributed(tagline, font: taglineFont, color: rgb(0xFFFFFF, 0.82), lineHeight: 52)

// Measure first, place second. The tagline is a different length in each of the
// eleven locales, so the icon-and-text group is centred on what the text really
// occupies rather than on a guessed column, and no card ends up leaning left
// with a stripe of dead space down the right-hand side.
let textLimit = W - (margin + iconSize + gutter) - margin
let titleBlock = measure(titleText, width: textLimit)
let taglineBlock = measure(taglineText, width: textLimit)

let blockGap: CGFloat = 26
let blockHeight = titleBlock.size.height + blockGap + taglineBlock.size.height
if blockHeight > H - 2 * margin {
    die("the text block is \(Int(blockHeight))pt tall and does not fit the safe area — shorten the tagline")
}

let textWidth = max(titleBlock.size.width, taglineBlock.size.width)
let groupWidth = iconSize + gutter + textWidth
let iconX = max(margin, (W - groupWidth) / 2)
let textX = iconX + iconSize + gutter

let iconRect = CGRect(x: iconX, y: (H - iconSize) / 2, width: iconSize, height: iconSize)
let iconShape = superellipsePath(in: iconRect)

// MARK: - Icon

// A soft brand glow behind the icon: it is what keeps the card from reading as
// a generic dark rectangle, and it lifts the icon off the ground.
let glowCentre = CGPoint(x: iconX + iconSize / 2, y: H / 2)
if let glow = CGGradient(
    colorsSpace: space,
    colors: [brandTeal.copy(alpha: 0.40)!, brandTeal.copy(alpha: 0)!] as CFArray,
    locations: [0, 1]
) {
    ctx.drawRadialGradient(
        glow,
        startCenter: glowCentre, startRadius: 0,
        endCenter: glowCentre, endRadius: 440,
        options: []
    )
}

let iconFileURL = URL(fileURLWithPath: iconPath)
guard let source = CGImageSourceCreateWithURL(iconFileURL as CFURL, nil),
      let iconImage = CGImageSourceCreateImageAtIndex(source, 0, nil)
else {
    die("could not read the icon at \(iconPath)")
}

// The shadow is painted by filling the shape once, so it stays a shadow of the
// squircle rather than of the image's bounding box.
ctx.saveGState()
ctx.setShadow(offset: CGSize(width: 0, height: -14), blur: 44, color: rgb(0x000000, 0.45))
ctx.addPath(iconShape)
ctx.setFillColor(rgb(0x000000))
ctx.fillPath()
ctx.restoreGState()

ctx.saveGState()
ctx.addPath(iconShape)
ctx.clip()
ctx.draw(iconImage, in: iconRect)
ctx.restoreGState()

// A hairline highlight along the squircle, the way a real icon catches light.
ctx.saveGState()
ctx.addPath(iconShape)
ctx.setStrokeColor(rgb(0xFFFFFF, 0.18))
ctx.setLineWidth(2)
ctx.strokePath()
ctx.restoreGState()

// MARK: - Type on the card

var cursorY = (H + blockHeight) / 2   // top edge of the block
cursorY -= titleBlock.size.height
draw(titleBlock.framesetter, in: CGRect(x: textX, y: cursorY, width: textWidth, height: titleBlock.size.height))
cursorY -= blockGap + taglineBlock.size.height
draw(taglineBlock.framesetter, in: CGRect(x: textX, y: cursorY, width: textWidth, height: taglineBlock.size.height))

// MARK: - Write

guard let image = ctx.makeImage() else { die("could not snapshot the drawing context") }

let outURL = URL(fileURLWithPath: outPath)
try? FileManager.default.createDirectory(
    at: outURL.deletingLastPathComponent(),
    withIntermediateDirectories: true
)

guard let destination = CGImageDestinationCreateWithURL(
    outURL as CFURL,
    UTType.jpeg.identifier as CFString,
    1,
    nil
) else {
    die("could not open \(outPath) for writing")
}

// Baseline JPEG, sRGB, quality 0.85: every unfurler reads it, and it keeps the
// file well under the size where WhatsApp starts skipping the fetch.
CGImageDestinationAddImage(destination, image, [
    kCGImageDestinationLossyCompressionQuality: 0.85,
] as CFDictionary)

guard CGImageDestinationFinalize(destination) else { die("could not encode \(outPath)") }

let bytes = (try? FileManager.default.attributesOfItem(atPath: outPath)[.size] as? Int) ?? 0
print("  \(outPath)  \(Int(W))x\(Int(H))  \(bytes / 1024) KB")
