import XCTest
@testable import FoldCore

final class MotionPresetTests: XCTestCase {
    func testPersonalPresetSurvivesPersistence() throws {
        let original = MotionPreset(effect:.iris,perspective:0.2,softness:0.9,shadow:0.4,clearAngle:123,stillnessDelay:4,clearWhenStill:false)
        let restored = try JSONDecoder().decode(MotionPreset.self,from:JSONEncoder().encode(original))
        XCTAssertEqual(restored.validated,original)
    }
    func testCorruptNumbersCannotReachRenderer() {
        var preset = MotionPreset.cinematic
        preset.perspective = .nan; preset.softness = 9; preset.shadow = -3
        preset.clearAngle = .infinity; preset.stillnessDelay = 0
        let safe = preset.validated
        XCTAssertEqual(safe.perspective,0.7)
        XCTAssertEqual(safe.softness,1)
        XCTAssertEqual(safe.shadow,0)
        XCTAssertEqual(safe.clearAngle,105)
        XCTAssertEqual(safe.stillnessDelay,1)
    }
    func testUnknownEffectIsRejectedOnRestore() {
        let json = "{\"effect\":\"unknown\",\"perspective\":0,\"softness\":0,\"shadow\":0,\"clearAngle\":100,\"stillnessDelay\":2,\"clearWhenStill\":true}"
        XCTAssertThrowsError(try JSONDecoder().decode(MotionPreset.self,from:Data(json.utf8)))
    }
}
