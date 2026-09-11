import SwiftUI
import MetalKit
import FoldCore

struct MetalPreview: NSViewRepresentable {
    @ObservedObject var model: AppModel
    func makeNSView(context: Context) -> MTKView {
        let view = MTKView()
        guard let device = model.device else { return view }
        do {
            let renderer = try FoldRenderer(device:device)
            renderer.fallback = try renderer.makePreviewTexture()
            renderer.parameters = { [weak model] in model?.uniforms(preview:true) ?? FoldUniforms() }
            renderer.animatedProgress = { [weak model] in model?.animatedProgress(preview:true) }
            renderer.pausesWhenSettled = true
            renderer.keepsAnimating = { [weak model] in
                guard let model else { return false }
                return model.previewPlaying || (model.followLid && model.demoRunning)
            }
            renderer.onFailure = { [weak model] message in model?.status = message }
            renderer.configure(view)
            context.coordinator.renderer = renderer
            model.previewRenderer = renderer
            model.previewView = view
        } catch { model.status = error.localizedDescription }
        return view
    }
    func updateNSView(_ view: MTKView, context: Context) {
        view.preferredFramesPerSecond = min(60,model.fps)
        context.coordinator.renderer?.wake(view)
    }
    static func dismantleNSView(_ view: MTKView, coordinator: Coordinator) { view.isPaused = true;view.delegate = nil }
    func makeCoordinator() -> Coordinator { Coordinator() }
    final class Coordinator { var renderer: FoldRenderer? }
}
