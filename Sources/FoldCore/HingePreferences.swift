import Foundation

public enum PerformanceMode: String, Codable, CaseIterable, Identifiable, Sendable {
    case batterySaver, balanced, smooth
    public var id: String { rawValue }
    public var title: String {
        switch self {
        case .batterySaver: return "Battery Saver"
        case .balanced: return "Balanced"
        case .smooth: return "Smooth"
        }
    }
    public func frameRate(maximum:Int, onBattery:Bool, lowPower:Bool, thermalPressure:Bool) -> Int {
        let cap: Int
        if lowPower || thermalPressure || self == .batterySaver { cap = 30 }
        else if self == .balanced { cap = onBattery ? 30 : 60 }
        else { cap = onBattery ? 60 : 120 }
        return max(1,min(maximum,cap))
    }
    public func captureSize(width:Int,height:Int,onBattery:Bool) -> (width:Int,height:Int) {
        let longest = self == .batterySaver ? 1600.0 : (self == .balanced || onBattery ? 2560.0 : 4096.0)
        let scale = min(1,longest / Double(max(1,max(width,height))))
        return (max(1,Int(Double(width)*scale)),max(1,Int(Double(height)*scale)))
    }
}

public struct SavedMotionPreset: Codable, Identifiable, Equatable, Sendable {
    public let id: UUID
    public var name: String
    public var settings: MotionPreset
    public init(id:UUID = UUID(),name:String,settings:MotionPreset) {
        self.id = id
        self.name = Self.cleanName(name)
        self.settings = settings.validated
    }
    public static func cleanName(_ name:String) -> String {
        let trimmed = name.trimmingCharacters(in:.whitespacesAndNewlines)
        return String((trimmed.isEmpty ? "Untitled preset" : trimmed).prefix(50))
    }
}

public struct ExcludedApplication: Codable, Identifiable, Equatable, Sendable {
    public var bundleID: String
    public var name: String
    public var id: String { bundleID }
    public init(bundleID:String,name:String) { self.bundleID = bundleID; self.name = name }
}
