import Foundation
import IOBluetooth
import Combine

final class BluetoothManager: NSObject, ObservableObject {
    enum MoodColorType {
        case solid, candle, aurora, seaWave, fireFly
    }

    // Constants translated from C#
    private let VENDOR_PT: UInt16 = 0x5054
    private let DEFAULT_FLAGS: UInt8 = 0
    private let DEVICE_NAME: String = "STONE"

    @Published var statusText: String = "Idle"
    @Published var isConnected: Bool = false

    private var rfcommChannel: IOBluetoothRFCOMMChannel?
    private var device: IOBluetoothDevice?

    private var connectCancellable: AnyCancellable?

    func scanAndConnect() {
        statusText = "Searching For STONE"
        // Discover paired devices first
        if let devices = IOBluetoothDevice.pairedDevices() as? [IOBluetoothDevice] {
            if let match = devices.first(where: { $0.name == DEVICE_NAME }) {
                connect(to: match)
                return
            }
        }
        // Fallback to inquiry
        let inquiry = IOBluetoothDeviceInquiry(delegate: self)
        inquiry?.updateNewDeviceNames = true
        inquiry?.start()
    }

    func connect(to device: IOBluetoothDevice) {
        self.device = device
        statusText = "Connecting"
        var channelID: BluetoothRFCOMMChannelID = 0
        // Try to find RFCOMM service channel via SDP for Serial Port or RFCOMM
        if let sp = device.getServiceRecord(for: IOBluetoothSDPUUID(uuid16: kBluetoothSDPUUID16ServiceClassSerialPort)) {
            sp.getRFCOMMChannelID(&channelID)
        }
        if channelID == 0 {
            // As in C# example uses BluetoothService.RFCommProtocol -> typically channel 1
            channelID = 1
        }
        var channel: IOBluetoothRFCOMMChannel?
        let status = device.openRFCOMMChannelSync(&channel, withChannelID: channelID, delegate: self)
        if status == kIOReturnSuccess, let ch = channel {
            self.rfcommChannel = ch
            self.isConnected = true
            self.statusText = "Connected"
            // Send initial commands same as C#
            sendCommand(vendorId: VENDOR_PT, commandId: 1)
            sendCommand(vendorId: VENDOR_PT, commandId: 16)
            let randomValue: UInt8 = UInt8(Int.random(in: 1...2))
            sendCommand(vendorId: VENDOR_PT, commandId: 578, payload: [randomValue])
        } else {
            self.statusText = "Connect failed (\(status))"
            self.isConnected = false
        }
    }

    func disconnect() {
        if let ch = rfcommChannel {
            ch.close()
        }
        rfcommChannel = nil
        isConnected = false
        statusText = "Disconnected"
    }

    // MARK: - Commands

    func sendSolidColor(r: UInt8, g: UInt8, b: UInt8) {
        // Assuming a made-up command id for solid color unless specified. If the protocol expects a specific id, set it here.
        // Keeping compatibility: only packet framing must match; the C# sample does not specify RGB command id.
        let payload: [UInt8] = [r, g, b]
        sendCommand(vendorId: VENDOR_PT, commandId: 0x0200, payload: payload)
    }

    func sendMode(_ mode: MoodColorType) {
        let cmdId: UInt16
        switch mode {
        case .solid: cmdId = 0x0200
        case .candle: cmdId = 0x0201
        case .aurora: cmdId = 0x0202
        case .seaWave: cmdId = 0x0203
        case .fireFly: cmdId = 0x0204
        }
        sendCommand(vendorId: VENDOR_PT, commandId: cmdId)
    }

    func sendCommand(vendorId: UInt16, commandId: UInt16, payload: [UInt8]? = nil) {
        guard let channel = rfcommChannel else {
            if commandId != 4096 && commandId != 1 && commandId != 16 {
                statusText = "Speak not available. Unable to connect to Device"
            }
            return
        }
        // Stream availability not directly exposed; we validate channel open
        if !isConnected { return }

        // Payload length check
        let payloadLength = UInt8(min(payload?.count ?? 0, 254))
        if let payload = payload, payload.count > 254 {
            statusText = "Payload length too long."
            return
        }

        let flags: UInt8 = DEFAULT_FLAGS
        let useCheck = (flags & 1) != 0
        var command = [UInt8]()
        command.reserveCapacity(Int(payloadLength) + 8 + (useCheck ? 1 : 0))
        command.append(0xFF)
        command.append(1)
        command.append(flags)
        command.append(payloadLength)
        command.append(UInt8(vendorId >> 8))
        command.append(UInt8(truncatingIfNeeded: vendorId))
        command.append(UInt8(commandId >> 8))
        command.append(UInt8(truncatingIfNeeded: commandId))
        if let payload = payload { command.append(contentsOf: payload) }
        if useCheck {
            var check: UInt8 = 0xFF
            for b in command { check ^= b }
            command.append(check)
        }

        let status = command.withUnsafeBytes { ptr -> IOReturn in
            guard let base = ptr.baseAddress else { return kIOReturnError }
            return channel.writeSync(base.assumingMemoryBound(to: UInt8.self), length: UInt16(command.count))
        }
        if status != kIOReturnSuccess {
            statusText = "Error while sending command: \\((status))"
        }
    }

    // Reading responses (optional API surface like C#)
    func readResponseAsync(completion: @escaping (Data?) -> Void) {
        // IOBluetoothRFCOMMChannel provides async delegate callback; we buffer next incoming frame and deliver.
        pendingReadCompletion = completion
    }

    func readResponseAsyncString(completion: @escaping (String?) -> Void) {
        readResponseAsync { data in
            guard let data else { completion(nil); return }
            completion(data.map { String(format: "%02X", $0) }.joined(separator: "-"))
        }
    }

    // MARK: - Incoming data handling
    private var incomingBuffer = Data()
    private var pendingReadCompletion: ((Data?) -> Void)?
}

extension BluetoothManager: IOBluetoothDeviceInquiryDelegate {
    func deviceInquiryDeviceFound(_ sender: IOBluetoothDeviceInquiry, device: IOBluetoothDevice) {
        if device.name == DEVICE_NAME {
            sender.stop()
            connect(to: device)
        }
    }
    func deviceInquiryComplete(_ sender: IOBluetoothDeviceInquiry, error: IOReturn, aborted: Bool) {
        if !isConnected && !aborted {
            statusText = "Device not found."
        }
    }
}

extension BluetoothManager: IOBluetoothRFCOMMChannelDelegate {
    func rfcommChannelData(_ rfcommChannel: IOBluetoothRFCOMMChannel!, data dataPointer: UnsafeMutableRawPointer!, length dataLength: Int) {
        let buffer = UnsafeRawPointer(dataPointer).assumingMemoryBound(to: UInt8.self)
        let data = Data(bytes: buffer, count: dataLength)
        incomingBuffer.append(data)
        if let completion = pendingReadCompletion {
            pendingReadCompletion = nil
            completion(incomingBuffer)
            incomingBuffer.removeAll(keepingCapacity: false)
        }
    }

    func rfcommChannelClosed(_ rfcommChannel: IOBluetoothRFCOMMChannel!) {
        DispatchQueue.main.async {
            self.isConnected = false
            self.statusText = "Disconnected"
        }
    }
}