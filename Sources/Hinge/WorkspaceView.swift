import SwiftUI
import FoldCore

private enum WorkspacePage: String, CaseIterable, Identifiable {
    case effects = "Effects", motion = "Motion", setup = "Setup & Help"
    var id: String { rawValue }
    var symbol: String {
        switch self {
        case .effects: return "sparkles"
        case .motion: return "slider.horizontal.3"
        case .setup: return "checkmark.shield"
        }
    }
}

struct Controls: View {
    @ObservedObject var model: AppModel
    @State private var page: WorkspacePage? = .effects
    @State private var notice = ""
    @State private var resetConfirmation = false
    @Environment(\.colorScheme) private var scheme
    private var accent: Color { scheme == .dark ? Color(red:0.40,green:0.86,blue:0.80) : Color(red:0.02,green:0.43,blue:0.40) }

    var body: some View {
        HStack(spacing:0) {
            sidebar.frame(width:190)
            Divider()
            VStack(spacing:0) {
                header
                Divider()
                ScrollView {
                    VStack(alignment:.leading,spacing:22) {
                        switch page ?? .effects {
                        case .effects: effects
                        case .motion: motion
                        case .setup: setup
                        }
                    }.padding(24).frame(maxWidth:840).frame(maxWidth:.infinity)
                }
                Divider()
                statusBar
            }.frame(maxWidth:.infinity,maxHeight:.infinity)
        }
        .background(Color(nsColor:.windowBackgroundColor))
        .tint(accent)
        .alert("Reset motion settings?",isPresented:$resetConfirmation) {
            Button("Cancel",role:.cancel) { }
            Button("Reset") { model.resetMotion(); notice = "Motion settings restored to their defaults." }
        } message: {
            Text("This restores the clear angle, stillness delay, and visual adjustments. Your chosen effect and saved favorite stay available.")
        }
    }

    private var sidebar: some View {
        VStack(alignment:.leading,spacing:18) {
            HStack(spacing:10) {
                Image(nsImage:AppBrand.mark).resizable().frame(width:38,height:38).accessibilityHidden(true)
                VStack(alignment:.leading,spacing:2) {
                    Text("Hinge").font(.title2.weight(.semibold))
                    Text("A little motion.").font(.caption).foregroundStyle(.secondary)
                }
            }.padding(.horizontal,16).padding(.top,22)
            List(selection:$page) {
                ForEach(WorkspacePage.allCases) { item in
                    Label(item.rawValue,systemImage:item.symbol).padding(.vertical,5).tag(item)
                }
            }.listStyle(.sidebar)
            VStack(alignment:.leading,spacing:10) {
                Label(model.sensorAvailable ? "Lid sensor connected" : "Sensor unavailable",
                      systemImage:model.sensorAvailable ? "checkmark.circle" : "exclamationmark.circle")
                    .font(.caption).foregroundStyle(model.sensorAvailable ? .secondary : Color.orange)
                Text("Version 2.0 Preview").font(.caption).foregroundStyle(.secondary)
            }.padding(16)
        }.background(.regularMaterial)
    }

    private var header: some View {
        HStack(spacing:16) {
            VStack(alignment:.leading,spacing:4) {
                Text((page ?? .effects).rawValue).font(.title2.weight(.semibold))
                Text(page == .motion ? "Make the movement yours." : page == .setup ? "Everything you need to get started." : "Choose a look. Give it a try.")
                    .foregroundStyle(.secondary)
            }
            Spacer()
            Button {
                if model.enabled || model.checkingPermission { model.pause() }
                else if !model.hasPermission { page = .setup }
                else { model.enable() }
            } label: {
                Label(model.checkingPermission ? "Cancel" : model.enabled ? "Pause Hinge" : "Enable Hinge",
                      systemImage:model.enabled ? "pause.fill" : "power")
            }
            .buttonStyle(.borderedProminent).controlSize(.large)
            .help("Controls real desktop effects. Previewing never requires screen access.")
        }.padding(.horizontal,24).padding(.vertical,18)
    }

    @ViewBuilder private var effects: some View {
        VStack(alignment:.leading,spacing:16) {
            HStack {
                Label("Preview",systemImage:"macbook").font(.headline)
                Spacer()
                Text("Generated artwork · no screen access needed").font(.caption).foregroundStyle(.secondary)
            }
            MetalPreview(model:model)
                .aspectRatio(1.75,contentMode:.fit)
                .frame(height:250)
                .frame(maxWidth:.infinity)
                .clipShape(RoundedRectangle(cornerRadius:12))
                .overlay(RoundedRectangle(cornerRadius:12).strokeBorder(.primary.opacity(0.12)))
                .accessibilityLabel("Generated preview of the \(model.effect.title) effect")
            HStack(spacing:14) {
                Picker("Preview input",selection:$model.followLid) {
                    Text("My lid").tag(true)
                    Text("Manual").tag(false)
                }.pickerStyle(.segmented).labelsHidden().frame(width:190)
                    .accessibilityLabel("Preview input")
                Spacer()
                if model.followLid {
                    Text(model.lidAngle.map { String(format:"Lid %.0f°",$0) } ?? "No sensor")
                        .monospacedDigit().foregroundStyle(.secondary)
                }
                Button {
                    if model.previewPlaying { model.stopPreview() } else { model.playPreview() }
                } label: {
                    Label(model.previewPlaying ? "Stop preview" : "Replay effect",systemImage:model.previewPlaying ? "stop.fill" : "play.fill")
                }.controlSize(.large)
            }
            if !model.followLid {
                settingSlider("Preview angle",value:$model.previewAngle,range:5...140,unit:"°")
                    .disabled(model.previewPlaying)
                Text("Manual control affects this preview only. Use Pause Hinge to stop desktop effects.")
                    .font(.caption).foregroundStyle(.secondary)
            } else if !model.sensorAvailable {
                Label("No sensor detected. Replay and manual preview still work.",systemImage:"info.circle")
                    .font(.callout).foregroundStyle(.secondary)
            }
        }
        VStack(alignment:.leading,spacing:12) {
            Text("Choose an effect").font(.headline)
            LazyVGrid(columns:[GridItem(.adaptive(minimum:112),spacing:10)],spacing:10) {
                ForEach(FoldEffect.allCases) { effect in
                    Button { model.effect = effect; model.playPreview() } label: {
                        VStack(spacing:10) {
                            Image(systemName:effect.symbol).font(.title2)
                            HStack(spacing:5) {
                                Text(effect.title).fontWeight(.medium)
                                if model.effect == effect { Image(systemName:"checkmark.circle.fill").font(.caption) }
                            }
                        }
                        .frame(maxWidth:.infinity).padding(.vertical,16)
                        .foregroundStyle(model.effect == effect ? accent : .primary)
                        .background(model.effect == effect ? accent.opacity(0.10) : Color(nsColor:.controlBackgroundColor),in:RoundedRectangle(cornerRadius:10))
                        .overlay(RoundedRectangle(cornerRadius:10).strokeBorder(model.effect == effect ? accent : .primary.opacity(0.12),lineWidth:model.effect == effect ? 2 : 1))
                    }.buttonStyle(.plain)
                        .accessibilityLabel("\(effect.title) effect")
                        .accessibilityAddTraits(model.effect == effect ? [.isSelected] : [])
                        .help(effect.summary)
                }
            }
            Text(model.effect.summary).foregroundStyle(.secondary).fixedSize(horizontal:false,vertical:true)
        }
        GroupBox {
            HStack(spacing:14) {
                Image(systemName:"slider.horizontal.3").foregroundStyle(accent).font(.title2)
                VStack(alignment:.leading,spacing:4) {
                    Text("Find your feel").font(.headline)
                    Text("Try a preset, save a favorite, or fine-tune the motion.").foregroundStyle(.secondary)
                }
                Spacer()
                Button("Customize motion") { page = .motion }
            }.padding(10)
        }
    }

    @ViewBuilder private var motion: some View {
        GroupBox("Start with a mood") {
            VStack(alignment:.leading,spacing:14) {
                HStack(spacing:10) {
                    preset("Subtle",detail:"Soft and quiet",symbol:"wind",value:.subtle)
                    preset("Cinematic",detail:"Deep curl",symbol:"film",value:.cinematic)
                    preset("Crisp",detail:"Sharp panels",symbol:"square.stack",value:.crisp)
                }
                HStack {
                    Text("Your favorite").fontWeight(.medium)
                    Spacer()
                    Button(model.personalPreset == nil ? "Save current setup" : "Update favorite") {
                        model.savePersonalPreset(); notice = "Favorite saved on this Mac."
                    }
                    Button("Restore favorite") {
                        if let preset = model.personalPreset { model.applyPreset(preset); notice = "Favorite restored." }
                    }.disabled(model.personalPreset == nil)
                }
            }.padding(12)
        }
        GroupBox("When the effect appears") {
            VStack(alignment:.leading,spacing:18) {
                settingSlider("Clear angle",value:$model.clearAngle,range:60...140,unit:"°")
                Text("Your desktop is fully visible above this angle.").foregroundStyle(.secondary)
                HStack {
                    Text("Set your lid at a comfortable working angle.").foregroundStyle(.secondary)
                    Spacer()
                    Button("Use current angle") { model.calibrate(); notice = "Clear angle set to \(Int(model.clearAngle))°." }
                        .disabled(!model.canCalibrate)
                        .help("Requires a current lid reading between 60° and 140°.")
                }
                Divider()
                Toggle("Clear the desktop when the lid is still",isOn:$model.clearWhenStill).toggleStyle(.switch)
                if model.clearWhenStill {
                    settingSlider("Clear after",value:$model.stillnessDelay,range:1...5,unit:" seconds",step:1)
                    Text("Move your lid to bring the effect back.").font(.callout).foregroundStyle(.secondary)
                }
            }.padding(12)
        }
        GroupBox("Fine-tune the look") {
            VStack(spacing:18) {
                settingSlider("Perspective",value:$model.perspective,range:0...1,unit:"%",multiplier:100)
                settingSlider("Softness",value:$model.blur,range:0...1,unit:"%",multiplier:100)
                settingSlider("Shadow",value:$model.shadow,range:0...1,unit:"%",multiplier:100)
                HStack {
                    Button("Reset motion settings…") { resetConfirmation = true }
                    Spacer()
                    Button("Preview changes") { page = .effects; model.playPreview() }
                }
            }.padding(12)
        }
        if !notice.isEmpty { Label(notice,systemImage:"checkmark.circle").foregroundStyle(accent) }
    }

    @ViewBuilder private var setup: some View {
        GroupBox("Get started") {
            VStack(alignment:.leading,spacing:18) {
                setupRow("1",title:"Try an effect",detail:"Explore all five effects using generated artwork. Screen access is not needed.") {
                    Button("Try preview") { page = .effects; model.playPreview() }
                }
                Divider()
                setupRow("2",title:model.sensorAvailable ? "Lid sensor connected" : "Check your MacBook",detail:"Automatic effects need a compatible MacBook lid sensor and its active, unmirrored built-in display.") {
                    Button("Check sensor") { model.retrySensor() }
                }
                Divider()
                setupRow("3",title:"Allow screen access",detail:"Hinge uses Screen Recording to animate your desktop. Frames stay in memory on your Mac; audio is never captured.") {
                    HStack {
                        Button("Open System Settings") { model.openPrivacy() }
                        Button(model.checkingPermission ? "Cancel" : "Enable desktop effects") {
                            if model.checkingPermission { model.pause() } else { model.enable() }
                        }.disabled(model.enabled || !model.sensorAvailable || model.device == nil)
                    }
                }
                Text("If macOS asks you to reopen Hinge after granting permission, quit and open it again, then enable desktop effects.")
                    .font(.callout).foregroundStyle(.secondary)
            }.padding(12)
        }
        GroupBox("Try it on your desktop") {
            VStack(alignment:.leading,spacing:12) {
                Text("Run an eight-second test with your actual desktop. When it finishes, Hinge returns to its previous on/off state.")
                    .foregroundStyle(.secondary)
                HStack {
                    Button(model.demoRunning ? "Stop desktop test" : "Test desktop · 8 seconds") {
                        if model.demoRunning { model.finishDesktopTest() } else { model.testDesktop() }
                    }.disabled(model.checkingPermission || !model.sensorAvailable)
                    Spacer()
                    Text("Esc or ⌃⌥⌘F always pauses Hinge.").font(.callout).foregroundStyle(.secondary)
                }
            }.padding(12)
        }
        GroupBox("Appearance") {
            VStack(alignment:.leading,spacing:12) {
                Picker("Theme",selection:$model.appearance) {
                    ForEach(AppAppearance.allCases) { appearance in Text(appearance.title).tag(appearance) }
                }.pickerStyle(.segmented)
                if model.reducedMotion {
                    Label("Reduce Motion is on. Hinge uses a simpler fade.",systemImage:"accessibility").foregroundStyle(.secondary)
                }
            }.padding(12)
        }
        GroupBox("About Hinge") {
            VStack(alignment:.leading,spacing:10) {
                Text("Hinge 2.0 · Preview").font(.headline)
                Text("A little motion. A more personal Mac.").foregroundStyle(.secondary)
                Text("macOS 14+ · Apple silicon · compatible lid sensor\nHinge stays available in your menu bar when this window closes.")
                    .font(.callout).foregroundStyle(.secondary)
                HStack {
                    Text("Built on MacDuo · MIT licensed").font(.caption).foregroundStyle(.secondary)
                    Spacer()
                    Button("License & credits") {
                        if let url = Bundle.main.url(forResource:"ATTRIBUTION",withExtension:"md") { NSWorkspace.shared.open(url) }
                    }
                }
            }.padding(12)
        }
    }

    private var statusBar: some View {
        HStack(alignment:.top,spacing:12) {
            Image(systemName:model.checkingPermission ? "hourglass" : model.enabled ? "power.circle.fill" : "pause.circle")
                .font(.title3).foregroundStyle(model.enabled ? accent : .secondary)
            VStack(alignment:.leading,spacing:4) {
                Text(model.activityTitle).fontWeight(.medium)
                Text(model.status).font(.callout).foregroundStyle(.secondary)
                    .fixedSize(horizontal:false,vertical:true).textSelection(.enabled)
            }
            Spacer(minLength:8)
            if !model.enabled && !model.checkingPermission && page != .setup {
                Button("Setup & Help") { page = .setup }
            }
        }.padding(.horizontal,24).padding(.vertical,14).background(.bar)
    }

    private func preset(_ title:String,detail:String,symbol:String,value:MotionPreset) -> some View {
        Button {
            model.applyPreset(value); notice = "\(title) applied. Preview it in Effects."
        } label: {
            VStack(alignment:.leading,spacing:8) {
                Label(title,systemImage:symbol).font(.headline)
                Text(detail).font(.callout).foregroundStyle(.secondary)
            }.frame(maxWidth:.infinity,alignment:.leading).padding(8)
        }.buttonStyle(.bordered)
    }

    private func settingSlider(_ title:String,value:Binding<Double>,range:ClosedRange<Double>,unit:String,multiplier:Double = 1,step:Double = 0.01) -> some View {
        VStack(alignment:.leading,spacing:8) {
            HStack {
                Text(title).fontWeight(.medium)
                Spacer()
                Text("\(Int((value.wrappedValue*multiplier).rounded()))\(unit)").monospacedDigit().foregroundStyle(.secondary)
            }
            Slider(value:value,in:range,step:step).accessibilityLabel(title)
        }
    }

    private func setupRow<Content:View>(_ number:String,title:String,detail:String,@ViewBuilder action:() -> Content) -> some View {
        HStack(alignment:.top,spacing:14) {
            Text(number).font(.headline).foregroundStyle(accent).frame(width:28,height:28)
                .background(accent.opacity(0.1),in:Circle())
            VStack(alignment:.leading,spacing:10) {
                Text(title).font(.headline)
                Text(detail).foregroundStyle(.secondary).fixedSize(horizontal:false,vertical:true)
                action()
            }.frame(maxWidth:.infinity,alignment:.leading)
        }
    }
}
