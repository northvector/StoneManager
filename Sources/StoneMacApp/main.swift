import SwiftUI
import AppKit

@main
struct StoneApp: App {
    var body: some Scene {
        WindowGroup {
            ContentView()
                .background(VisualEffectView(material: .hudWindow, blendingMode: .withinWindow))
                .background(WindowConfigurator())
                .ignoresSafeArea()
        }
        .windowStyle(.hiddenTitleBar)
    }
}

struct VisualEffectView: NSViewRepresentable {
    let material: NSVisualEffectView.Material
    let blendingMode: NSVisualEffectView.BlendingMode

    func makeNSView(context: Context) -> NSVisualEffectView {
        let view = NSVisualEffectView()
        view.material = material
        view.blendingMode = blendingMode
        view.state = .active
        view.isEmphasized = true
        view.wantsLayer = true
        view.layer?.cornerRadius = 16
        view.layer?.masksToBounds = true
        return view
    }

    func updateNSView(_ nsView: NSVisualEffectView, context: Context) {
        nsView.material = material
        nsView.blendingMode = blendingMode
    }
}

struct ContentView: View {
    @StateObject private var bt = BluetoothManager()
    @State private var red: Double = 255
    @State private var green: Double = 0
    @State private var blue: Double = 0

    var body: some View {
        ZStack {
            Color.clear
            VStack(spacing: 16) {
                Text(bt.statusText)
                    .font(.headline)
                    .foregroundColor(bt.isConnected ? .green : .secondary)

                HStack(spacing: 12) {
                    Button(action: bt.scanAndConnect) {
                        Label(bt.isConnected ? "Reconnect" : "Connect", systemImage: "antenna.radiowaves.left.and.right")
                    }
                    .keyboardShortcut(.defaultAction)

                    if bt.isConnected {
                        Button("Disconnect", action: bt.disconnect)
                    }
                }

                VStack(alignment: .leading, spacing: 8) {
                    Text("RGB Solid")
                        .font(.subheadline)
                    HStack {
                        Slider(value: $red, in: 0...255, step: 1) { Text("R") }
                            .tint(.red)
                        Slider(value: $green, in: 0...255, step: 1) { Text("G") }
                            .tint(.green)
                        Slider(value: $blue, in: 0...255, step: 1) { Text("B") }
                            .tint(.blue)
                    }
                    HStack {
                        Button("Send Solid") {
                            bt.sendSolidColor(r: UInt8(red), g: UInt8(green), b: UInt8(blue))
                        }
                        Button("Candle") { bt.sendMode(.candle) }
                        Button("Aurora") { bt.sendMode(.aurora) }
                        Button("Sea Wave") { bt.sendMode(.seaWave) }
                        Button("Firefly") { bt.sendMode(.fireFly) }
                    }
                }
            }
            .padding(24)
        }
        .frame(width: 520, height: 280)
        .background(.clear)
    }
}