import Cocoa

public protocol Drawable {
    func draw(ctx: CGContextRef, bounds: CGRect)
}

public class DiagramView : NSView {

    let drawable: Drawable

    public init(frame frameRect: NSRect, drawable: Drawable) {
        self.drawable = drawable
        super.init(frame: frameRect)
    }

    required public init(coder: NSCoder) {
        fatalError("NSCoding not supported")
    }

    override public func drawRect(dirtyRect: NSRect) {
        guard let context = NSGraphicsContext.currentContext() else { return }
        drawable.draw(context.CGContext, bounds: self.bounds)
    }

    public func imageRepresentation() -> NSImage? {
        let wantedLayer = self.wantsLayer;
        self.wantsLayer = true;
        let image = NSImage(size: self.bounds.size)
        image.lockFocus()
        guard let context = NSGraphicsContext.currentContext() else { return nil }
        self.layer?.renderInContext(context.CGContext)
        image.unlockFocus()
        self.wantsLayer = wantedLayer
        return image
    }

    public func saveAsImage(path: String) {
        let image = imageRepresentation()!
        let rep = NSBitmapImageRep(data: image.TIFFRepresentation!)!
        let pngData = rep.representationUsingType(.NSPNGFileType, properties: [:])!
        pngData.writeToFile(path, atomically: true)
        Swift.print("Saved image as \(path)")
    }
}