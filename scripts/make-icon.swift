import AppKit

// Original vector mark: two luminous planes meeting at a hinge.
let root = URL(fileURLWithPath:CommandLine.arguments[1],isDirectory:true)
let iconset = root.appendingPathComponent("Hinge.iconset")
try FileManager.default.createDirectory(at:iconset,withIntermediateDirectories:true)
func draw(size:Int) -> Data {
    let bitmap = NSBitmapImageRep(bitmapDataPlanes:nil,pixelsWide:size,pixelsHigh:size,bitsPerSample:8,samplesPerPixel:4,hasAlpha:true,isPlanar:false,colorSpaceName:.deviceRGB,bytesPerRow:0,bitsPerPixel:0)!
    NSGraphicsContext.saveGraphicsState()
    NSGraphicsContext.current = NSGraphicsContext(bitmapImageRep:bitmap)
    let scale = CGFloat(size)/1024
    let transform = NSAffineTransform(); transform.scale(by:scale); transform.concat()
    NSColor(calibratedRed:0.055,green:0.11,blue:0.16,alpha:1).setFill()
    NSBezierPath(roundedRect:NSRect(x:32,y:32,width:960,height:960),xRadius:220,yRadius:220).fill()
    let upper = NSBezierPath(); upper.move(to:NSPoint(x:250,y:300)); upper.line(to:NSPoint(x:340,y:800)); upper.line(to:NSPoint(x:820,y:655)); upper.line(to:NSPoint(x:730,y:300)); upper.close()
    NSGradient(starting:NSColor(calibratedRed:0.48,green:0.95,blue:0.88,alpha:1),ending:NSColor(calibratedRed:0.04,green:0.48,blue:0.60,alpha:1))!.draw(in:upper,angle:-70)
    let lower = NSBezierPath(); lower.move(to:NSPoint(x:250,y:280)); lower.line(to:NSPoint(x:730,y:280)); lower.line(to:NSPoint(x:830,y:210)); lower.line(to:NSPoint(x:160,y:210)); lower.close()
    NSColor(calibratedRed:0.72,green:1,blue:0.93,alpha:1).setFill(); lower.fill()
    NSGraphicsContext.restoreGraphicsState()
    return bitmap.representation(using:.png,properties:[:])!
}
for base in [16,32,128,256,512] {
    for factor in [1,2] {
        let name = "icon_\(base)x\(base)\(factor == 2 ? "@2x" : "").png"
        try draw(size:base*factor).write(to:iconset.appendingPathComponent(name))
    }
}
try draw(size:1024).write(to:root.appendingPathComponent("HingeMark.png"))
