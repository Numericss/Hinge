import XCTest
@testable import FoldCore

final class PerformanceModeTests: XCTestCase {
    func testBatteryAndThermalCapsApplyEvenToSmoothMode() {
        XCTAssertEqual(PerformanceMode.smooth.frameRate(maximum:120,onBattery:false,lowPower:false,thermalPressure:false),120)
        XCTAssertEqual(PerformanceMode.smooth.frameRate(maximum:120,onBattery:true,lowPower:false,thermalPressure:false),60)
        for mode in PerformanceMode.allCases {
            XCTAssertEqual(mode.frameRate(maximum:120,onBattery:false,lowPower:true,thermalPressure:false),30)
            XCTAssertEqual(mode.frameRate(maximum:120,onBattery:false,lowPower:false,thermalPressure:true),30)
            XCTAssertLessThanOrEqual(mode.frameRate(maximum:48,onBattery:false,lowPower:false,thermalPressure:false),48)
        }
        XCTAssertEqual(PerformanceMode.balanced.frameRate(maximum:120,onBattery:true,lowPower:false,thermalPressure:false),30)
    }
    func testCaptureSizePreservesAspectRatioAndDoesNotUpscale() {
        let saver = PerformanceMode.batterySaver.captureSize(width:3200,height:2000,onBattery:false)
        XCTAssertEqual(saver.width,1600); XCTAssertEqual(saver.height,1000)
        let small = PerformanceMode.smooth.captureSize(width:1200,height:800,onBattery:false)
        XCTAssertEqual(small.width,1200); XCTAssertEqual(small.height,800)
        let balanced = PerformanceMode.balanced.captureSize(width:3200,height:2000,onBattery:false)
        XCTAssertEqual(balanced.width,2560); XCTAssertEqual(balanced.height,1600)
    }
    func testPresetNamesNormalizeWithoutChangingIdentity() throws {
        let preset = SavedMotionPreset(name:"  Work  ",settings:.cinematic)
        XCTAssertEqual(preset.name,"Work")
        let restored = try JSONDecoder().decode(SavedMotionPreset.self,from:JSONEncoder().encode(preset))
        XCTAssertEqual(restored.id,preset.id)
        XCTAssertEqual(restored.settings,.cinematic)
        XCTAssertEqual(SavedMotionPreset.cleanName("  "),"Untitled preset")
        XCTAssertEqual(SavedMotionPreset.cleanName(String(repeating:"a",count:100)).count,50)
    }
}
