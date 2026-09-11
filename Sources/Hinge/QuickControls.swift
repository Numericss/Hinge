import SwiftUI
import FoldCore

struct QuickControls: View {
    @ObservedObject var model: AppModel
    let openWorkspace: () -> Void
    let quit: () -> Void
    var body: some View {
        VStack(alignment:.leading,spacing:16) {
            HStack {
                Image(nsImage:AppBrand.mark).resizable().frame(width:32,height:32)
                VStack(alignment:.leading,spacing:3) {
                    Text("Hinge").font(.headline)
                    Text(model.activityTitle).font(.caption).foregroundStyle(.secondary)
                }
                Spacer()
                Button(model.enabled || model.checkingPermission ? "Pause" : "Enable") {
                    if model.enabled || model.checkingPermission { model.pause() } else { model.enable() }
                }.buttonStyle(.borderedProminent).tint(.teal)
            }
            Picker("Effect",selection:$model.effect) {
                ForEach(FoldEffect.allCases) { effect in Text(effect.title).tag(effect) }
            }
            Menu {
                Button("Subtle") { model.applyPreset(.subtle) }
                Button("Cinematic") { model.applyPreset(.cinematic) }
                Button("Crisp") { model.applyPreset(.crisp) }
                if !model.savedPresets.isEmpty {
                    Divider()
                    ForEach(model.savedPresets) { preset in
                        Button(preset.name) { model.applyPreset(preset.settings) }
                    }
                }
            } label: { Label("Choose a preset",systemImage:"slider.horizontal.3") }
            Picker("Performance",selection:$model.performanceMode) {
                ForEach(PerformanceMode.allCases) { mode in Text(mode.title).tag(mode) }
            }
            Text(model.automaticPauseReason ?? model.status).font(.callout).foregroundStyle(.secondary)
                .fixedSize(horizontal:false,vertical:true)
            Divider()
            HStack {
                Button("Open Hinge",action:openWorkspace)
                Spacer()
                Button("Quit",action:quit)
            }
            Text("⌃⌥⌘F pauses effects anywhere").font(.caption).foregroundStyle(.secondary)
        }.padding(20).frame(width:340)
    }
}
