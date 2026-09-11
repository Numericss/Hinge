import XCTest
import FoldCore
@testable import Hinge

@MainActor final class VersionThreeTests: XCTestCase {
    private func preferences() -> UserDefaults {
        let suite = "com.datalynlabs.hinge.v3tests.\(UUID().uuidString)"
        let prefs = UserDefaults(suiteName:suite)!
        addTeardownBlock { prefs.removePersistentDomain(forName:suite) }
        return prefs
    }
    func testFavoriteMigratesOnceAndDeletedLibraryStaysEmpty() throws {
        let prefs = preferences()
        prefs.set(try JSONEncoder().encode(MotionPreset.cinematic),forKey:"personalPreset")
        let first = AppModel(preferences:prefs,startServices:false)
        XCTAssertEqual(first.savedPresets.count,1)
        XCTAssertEqual(first.savedPresets[0].settings,.cinematic)
        first.deletePreset(id:first.savedPresets[0].id)
        let reopened = AppModel(preferences:prefs,startServices:false)
        XCTAssertTrue(reopened.savedPresets.isEmpty)
        XCTAssertEqual(reopened.personalPreset,.cinematic)
    }
    func testNamedPresetCRUDPersistsAndDoesNotEnableCapture() {
        let prefs = preferences()
        let model = AppModel(preferences:prefs,startServices:false)
        model.applyPreset(.crisp); model.savePreset(name:"Work")
        let id = model.savedPresets[0].id
        model.renamePreset(id:id,name:" Focus ")
        let reopened = AppModel(preferences:prefs,startServices:false)
        XCTAssertEqual(reopened.savedPresets[0].name,"Focus")
        XCTAssertEqual(reopened.savedPresets[0].id,id)
        XCTAssertEqual(reopened.savedPresets[0].settings,.crisp)
        XCTAssertFalse(reopened.enabled)
        XCTAssertFalse(reopened.capture.isRunning)
    }
    func testSmartPausePreservesEnablementAndManualPauseWins() {
        let model = AppModel(preferences:preferences(),startServices:false)
        model.addExcludedApplication(.init(bundleID:"test.meeting",name:"Meeting"))
        model.enabled = true
        model.evaluateSmartPause(frontmostBundleID:"test.meeting",hasExternalDisplay:false)
        XCTAssertNotNil(model.automaticPauseReason)
        XCTAssertTrue(model.enabled)
        XCTAssertEqual(model.liveProgress,0)
        XCTAssertFalse(model.capture.isRunning)
        model.evaluateSmartPause(frontmostBundleID:"test.editor",hasExternalDisplay:false)
        XCTAssertNil(model.automaticPauseReason)
        XCTAssertTrue(model.enabled)
        model.evaluateSmartPause(frontmostBundleID:"test.meeting",hasExternalDisplay:false)
        model.pause()
        model.evaluateSmartPause(frontmostBundleID:"test.editor",hasExternalDisplay:false)
        XCTAssertFalse(model.enabled)
    }
    func testExternalDisplayPauseBlocksDesktopTestAndResumesOnlyIfEnabled() {
        let model = AppModel(preferences:preferences(),startServices:false)
        model.pauseOnExternalDisplay = true
        model.evaluateSmartPause(frontmostBundleID:nil,hasExternalDisplay:true)
        XCTAssertNotNil(model.automaticPauseReason)
        model.testDesktop()
        XCTAssertFalse(model.demoRunning)
        XCTAssertFalse(model.enabled)
        model.evaluateSmartPause(frontmostBundleID:nil,hasExternalDisplay:false)
        XCTAssertNil(model.automaticPauseReason)
        XCTAssertFalse(model.enabled)
    }
    func testExclusionsDeduplicatePersistAndDiagnosticsOmitActivity() {
        let prefs = preferences()
        let model = AppModel(preferences:prefs,startServices:false)
        let app = ExcludedApplication(bundleID:"private.client.app",name:"Private Client")
        model.addExcludedApplication(app); model.addExcludedApplication(app)
        XCTAssertEqual(model.excludedApplications.count,1)
        let reopened = AppModel(preferences:prefs,startServices:false)
        XCTAssertEqual(reopened.excludedApplications,[app])
        reopened.evaluateSmartPause(frontmostBundleID:app.bundleID,hasExternalDisplay:false)
        XCTAssertFalse(reopened.diagnosticText.contains(app.name))
        XCTAssertFalse(reopened.diagnosticText.contains(app.bundleID))
        reopened.removeExcludedApplication(id:app.id)
        XCTAssertTrue(AppModel(preferences:prefs,startServices:false).excludedApplications.isEmpty)
    }
    func testSetupCompletionAndPerformanceModeSurviveRelaunch() {
        let prefs = preferences()
        let model = AppModel(preferences:prefs,startServices:false)
        model.performanceMode = .batterySaver
        model.setupCompleted = true
        let reopened = AppModel(preferences:prefs,startServices:false)
        XCTAssertEqual(reopened.performanceMode,.batterySaver)
        XCTAssertTrue(reopened.setupCompleted)
        XCTAssertFalse(reopened.enabled)
    }
}
