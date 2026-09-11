import SwiftUI
import FoldCore

struct StudioSettings: View {
    @ObservedObject var model: AppModel
    @Environment(\.dismiss) private var dismiss
    @State private var notice = "Presets change your settings without enabling screen capture."

    var body: some View {
        VStack(alignment:.leading,spacing:20) {
            HStack {
                VStack(alignment:.leading,spacing:4) {
                    Text("Motion studio").font(.title2.bold())
                    Text("Find your feel. Make it yours.").foregroundStyle(.secondary)
                }
                Spacer()
                Button("Done") { dismiss() }.keyboardShortcut(.defaultAction)
            }
            GroupBox("Start with a mood") {
                HStack(spacing:12) {
                    preset("Subtle",detail:"Soft, quiet movement",symbol:"wind",value:.subtle)
                    preset("Cinematic",detail:"Deep curl and shadow",symbol:"film",value:.cinematic)
                    preset("Crisp",detail:"Clean, sharp panels",symbol:"square.stack",value:.crisp)
                }.padding(10)
            }
            GroupBox("Your signature") {
                HStack {
                    Text("Keep one favorite setup across launches.").foregroundStyle(.secondary)
                    Spacer()
                    Button("Save current") { model.savePersonalPreset(); notice = "Your current settings are saved on this Mac." }
                    Button("Restore") {
                        if let preset = model.personalPreset { model.applyPreset(preset); notice = "Your personal preset is restored." }
                    }.disabled(model.personalPreset == nil)
                }.padding(10)
            }
            GroupBox("Calibrate your comfortable angle") {
                VStack(alignment:.leading,spacing:10) {
                    Text("Place the lid at your usual working angle, then set it as the point where the desktop becomes clear.")
                        .foregroundStyle(.secondary)
                    HStack {
                        Text(model.lidAngle.map { String(format:"Current lid: %.0f°",$0) } ?? "No compatible lid sensor detected")
                            .monospacedDigit()
                        Spacer()
                        Button("Use current angle") { model.calibrate(); notice = "Clear angle set to \(Int(model.clearAngle))°." }
                            .disabled(!model.canCalibrate)
                    }
                    Text("Calibration requires a live sensor reading between 60° and 140°.").font(.caption).foregroundStyle(.secondary)
                }.padding(10)
            }
            Text(notice).font(.callout).foregroundStyle(.secondary).accessibilityLabel(notice)
            Divider()
            HStack(alignment:.top) {
                VStack(alignment:.leading,spacing:4) {
                    Text("Hinge · 0.1.0 Preview").font(.callout.bold())
                    Text("Built on MacDuo · MIT licensed\nScreen frames stay in memory on your Mac.")
                        .font(.caption).foregroundStyle(.secondary)
                }
                Spacer()
                Button("License & credits") {
                    if let url = Bundle.main.url(forResource:"ATTRIBUTION",withExtension:"md") { NSWorkspace.shared.open(url) }
                }
            }
        }.padding(24).frame(width:610)
    }

    private func preset(_ title: String, detail: String, symbol: String, value: MotionPreset) -> some View {
        Button {
            model.applyPreset(value)
            notice = "\(title) applied. Replay the preview to try it."
        } label: {
            VStack(alignment:.leading,spacing:8) {
                Image(systemName:symbol).font(.title2)
                Text(title).font(.headline)
                Text(detail).font(.caption).foregroundStyle(.secondary)
            }.frame(maxWidth:.infinity,alignment:.leading).padding(8)
        }.buttonStyle(.bordered)
    }
}
