import XCTest
import FoldCore
@testable import Hinge

@MainActor final class AppModelTests: XCTestCase {
    private func makeModel(verify: (@MainActor () async throws -> Void)? = nil) -> AppModel {
        let suite = "com.datalynlabs.hinge.tests.\(UUID().uuidString)"
        let preferences = UserDefaults(suiteName:suite)!
        addTeardownBlock { preferences.removePersistentDomain(forName:suite) }
        return AppModel(preferences:preferences,startServices:false,verifyCaptureAccess:verify)
    }

    func testMalformedSavedVisualSettingsAreClampedOnLaunch() {
        let suite = "com.datalynlabs.hinge.tests.\(UUID().uuidString)"
        let preferences = UserDefaults(suiteName:suite)!
        defer { preferences.removePersistentDomain(forName:suite) }
        preferences.set(999.0,forKey:"clearAngle")
        preferences.set(-5.0,forKey:"blur")
        preferences.set(12.0,forKey:"perspective")
        preferences.set(0.0,forKey:"stillnessDelay")
        let model = AppModel(preferences:preferences,startServices:false)
        XCTAssertEqual(model.clearAngle,140)
        XCTAssertEqual(model.blur,0)
        XCTAssertEqual(model.perspective,1)
        XCTAssertEqual(model.stillnessDelay,1)
    }

    func testDesktopTestReturnsToDisabledState() async {
        let model = makeModel(verify:{ })
        model.sensorAvailable = true
        model.testDesktop()
        for _ in 0..<1000 {
            if model.demoRunning { break }
            await Task.yield()
        }
        XCTAssertTrue(model.demoRunning)
        XCTAssertTrue(model.enabled)
        model.finishDesktopTest()
        XCTAssertFalse(model.demoRunning)
        XCTAssertFalse(model.enabled)
        XCTAssertFalse(model.capture.isRunning)
    }

    func testDesktopTestPreservesPreviouslyEnabledState() {
        let model = makeModel()
        model.enabled = true
        model.testDesktop()
        XCTAssertTrue(model.demoRunning)
        model.finishDesktopTest()
        XCTAssertTrue(model.enabled)
        XCTAssertFalse(model.demoRunning)
        model.pause()
    }

    func testPreviewStopDoesNotChangeDesktopEnablement() {
        let model = makeModel()
        model.enabled = true
        model.playPreview()
        XCTAssertTrue(model.previewPlaying)
        model.stopPreview()
        XCTAssertFalse(model.previewPlaying)
        XCTAssertTrue(model.enabled)
        model.pause()
    }

    func testResetPreservesEffectAndFavorite() {
        let model = makeModel()
        model.applyPreset(.cinematic)
        model.savePersonalPreset()
        model.resetMotion()
        XCTAssertEqual(model.effect,.roll)
        XCTAssertEqual(model.personalPreset,.cinematic)
        XCTAssertEqual(model.clearAngle,105)
        XCTAssertEqual(model.blur,0.65)
        XCTAssertFalse(model.enabled)
    }

    func testLivePreviewFollowsLidBeforeScreenAccessIsEnabled() {
        let model = makeModel()
        model.sensorAvailable = true
        model.lidAngle = 72
        XCTAssertFalse(model.enabled)
        XCTAssertGreaterThan(model.previewProgress,0)
        XCTAssertGreaterThan(model.uniforms(preview:true).progress,0)
        XCTAssertNil(model.animatedProgress(preview:true),"A preview with no desktop overlay must use its own renderer's clock.")
        XCTAssertEqual(model.liveProgress,0)
        XCTAssertFalse(model.capture.isRunning)
    }

    func testManualPreviewDoesNotNeedSensorOrCapture() {
        let model = makeModel()
        model.followLid = false
        model.previewAngle = 60
        XCTAssertGreaterThan(model.previewProgress,0)
        XCTAssertNil(model.animatedProgress(preview:true))
        XCTAssertFalse(model.capture.isRunning)
    }

    func testPersonalPresetRestoresAcrossModelInstancesWithoutEnablingCapture() {
        let suite = "com.datalynlabs.hinge.tests.\(UUID().uuidString)"
        let preferences = UserDefaults(suiteName:suite)!
        defer { preferences.removePersistentDomain(forName:suite) }
        let first = AppModel(preferences:preferences,startServices:false)
        first.applyPreset(.cinematic)
        first.savePersonalPreset()
        first.applyPreset(.subtle)
        let restored = AppModel(preferences:preferences,startServices:false)
        XCTAssertEqual(restored.effect,.duo)
        XCTAssertEqual(restored.personalPreset,.cinematic)
        restored.applyPreset(restored.personalPreset!)
        XCTAssertEqual(restored.effect,.roll)
        XCTAssertEqual(restored.perspective,0.85)
        XCTAssertEqual(restored.blur,0.75)
        XCTAssertFalse(restored.enabled)
        XCTAssertFalse(restored.capture.isRunning)
    }

    func testCancelledPermissionCheckCannotEnableAfterPause() async {
        let access = AccessChecks()
        let model = makeModel { await access.wait() }
        model.sensorAvailable = true
        model.enable()
        await access.waitForPendingCount(1)
        model.pause()
        access.completeFirst()
        for _ in 0..<10 { await Task.yield() }
        XCTAssertFalse(model.enabled)
        XCTAssertFalse(model.checkingPermission)
        XCTAssertFalse(model.capture.isRunning)
    }

    func testCancelledPermissionCheckCannotClearNewCheckingState() async {
        let access = AccessChecks()
        let model = makeModel { await access.wait() }
        model.sensorAvailable = true
        model.enable()
        await access.waitForPendingCount(1)
        model.pause()
        model.enable()
        await access.waitForPendingCount(2)
        access.completeFirst()
        // Completing the old request must not make the pending newer request look idle.
        for _ in 0..<10 { await Task.yield() }
        XCTAssertTrue(model.checkingPermission)
        XCTAssertFalse(model.enabled)
        access.completeFirst()
        for _ in 0..<10 { await Task.yield() }
        model.pause()
    }
}

@MainActor private final class AccessChecks {
    private var pending: [CheckedContinuation<Void,Never>] = []
    func wait() async { await withCheckedContinuation { pending.append($0) } }
    func waitForPendingCount(_ count: Int) async {
        for _ in 0..<1000 {
            if pending.count == count { return }
            await Task.yield()
        }
        XCTFail("Permission request did not reach the expected suspension point")
    }
    func completeFirst() { if !pending.isEmpty { pending.removeFirst().resume() } }
}
