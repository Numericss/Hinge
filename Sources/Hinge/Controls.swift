import SwiftUI
import MetalKit
import FoldCore

struct MetalPreview: NSViewRepresentable {
    @ObservedObject var model: AppModel
    func makeNSView(context: Context) -> MTKView {
        let view = MTKView()
        do {
            let renderer = try model.preparePreviewRenderer()
            renderer.configure(view)
            context.coordinator.renderer = renderer
            model.previewRenderer = renderer
            model.previewView = view
        } catch { model.status = error.localizedDescription }
        return view
    }
    func updateNSView(_ view: MTKView, context: Context) {
        let fps = min(60,model.fps)
        if view.preferredFramesPerSecond != fps { view.preferredFramesPerSecond = fps }
        let inputs = model.uniforms(preview:true)
        let playing = model.previewPlaying || (model.followLid && model.demoRunning)
        let sharedClock = model.overlayVisible && model.followLid && !model.previewPlaying
        let coordinator = context.coordinator
        // The model also publishes status and sensor readings. Manual/settled
        // previews must not restart their display link for unrelated changes.
        guard coordinator.lastInputs != inputs || coordinator.playing != playing || coordinator.sharedClock != sharedClock else { return }
        coordinator.lastInputs = inputs
        coordinator.playing = playing
        coordinator.sharedClock = sharedClock
        coordinator.renderer?.wake(view)
    }
    static func dismantleNSView(_ view: MTKView, coordinator: Coordinator) { view.isPaused = true;view.delegate = nil }
    func makeCoordinator() -> Coordinator { Coordinator() }
    final class Coordinator {
        var renderer: FoldRenderer?
        var lastInputs: FoldUniforms?
        var playing = false
        var sharedClock = false
    }
}
