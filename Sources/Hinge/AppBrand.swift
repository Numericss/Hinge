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

    /// Short version from the bundled Info.plist (fallback matches current customer target).
    static var shortVersion: String {
        Bundle.main.object(forInfoDictionaryKey:"CFBundleShortVersionString") as? String ?? "3.0.0"
    }

    /// Buyer support address embedded at package time via `HINGE_SUPPORT_EMAIL` → Info.plist `HingeSupportEmail`.
    /// Empty when unset — About hides the Support button rather than inventing a domain.
    static var supportEmail: String {
        let raw = Bundle.main.object(forInfoDictionaryKey:"HingeSupportEmail") as? String ?? ""
        return raw.trimmingCharacters(in:.whitespacesAndNewlines)
    }

    static var supportMailURL: URL? {
        let email = supportEmail
        guard !email.isEmpty else { return nil }
        return URL(string:"mailto:\(email)")
    }
}
