import AppKit

@MainActor enum AppBrand {
    static let mark: NSImage = {
        if let url = Bundle.main.url(forResource:"HingeMark",withExtension:"png"),
           let image = NSImage(contentsOf:url) { return image }
        return NSImage(systemSymbolName:"macbook",accessibilityDescription:"Hinge") ?? NSImage()
    }()

    static var menuBarMark: NSImage {
        let image = NSImage(systemSymbolName:"macbook",accessibilityDescription:"Hinge") ?? NSImage()
        image.size = NSSize(width:22,height:18)
        image.isTemplate = true
        return image
    }
}
