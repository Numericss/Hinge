import Foundation

/// A portable snapshot of visual settings. Enabling screen capture is deliberately
/// excluded: loading a preset must never turn on the desktop overlay.
public struct MotionPreset: Codable, Equatable, Sendable {
    public var effect: FoldEffect
    public var perspective: Double
    public var softness: Double
    public var shadow: Double
    public var clearAngle: Double
    public var stillnessDelay: Double
    public var clearWhenStill: Bool

    public init(effect: FoldEffect, perspective: Double, softness: Double, shadow: Double,
                clearAngle: Double, stillnessDelay: Double, clearWhenStill: Bool = true) {
        self.effect = effect
        self.perspective = Self.clamp(perspective, to: 0...1, fallback: 0.7)
        self.softness = Self.clamp(softness, to: 0...1, fallback: 0.65)
        self.shadow = Self.clamp(shadow, to: 0...1, fallback: 0.65)
        self.clearAngle = Self.clamp(clearAngle, to: 60...140, fallback: 105)
        self.stillnessDelay = Self.clamp(stillnessDelay, to: 1...5, fallback: 2)
        self.clearWhenStill = clearWhenStill
    }
    private static func clamp(_ value: Double, to range: ClosedRange<Double>, fallback: Double) -> Double {
        value.isFinite ? min(range.upperBound, max(range.lowerBound, value)) : fallback
    }
    public var validated: MotionPreset {
        MotionPreset(effect:effect, perspective:perspective, softness:softness, shadow:shadow,
                     clearAngle:clearAngle, stillnessDelay:stillnessDelay, clearWhenStill:clearWhenStill)
    }
    public static let subtle = MotionPreset(effect:.duo, perspective:0.35, softness:0.25, shadow:0.3, clearAngle:95, stillnessDelay:1)
    public static let cinematic = MotionPreset(effect:.roll, perspective:0.85, softness:0.75, shadow:0.8, clearAngle:110, stillnessDelay:3)
    public static let crisp = MotionPreset(effect:.shutter, perspective:0.6, softness:0, shadow:0.55, clearAngle:105, stillnessDelay:2)
}
