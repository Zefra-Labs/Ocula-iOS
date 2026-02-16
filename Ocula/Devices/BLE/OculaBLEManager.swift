//
//  OculaBLEManager.swift
//  Ocula
//
//  Created by Tyson Miles on 4/2/2026.
//

import Foundation
import CoreBluetooth
import Combine

struct DeviceBLEProof: Equatable {
    let nonce: String
    let responseBase64: String
    let serial: String?
    let peripheralId: String
    let bleName: String?

    func asPayload() -> [String: Any] {
        var payload: [String: Any] = [
            "nonce": nonce,
            "responseBase64": responseBase64,
            "peripheralId": peripheralId
        ]
        if let serial, !serial.isEmpty {
            payload["serial"] = serial
        }
        if let bleName, !bleName.isEmpty {
            payload["bleName"] = bleName
        }
        return payload
    }
}

enum BLEConnectionState: String {
    case idle
    case scanning
    case connecting
    case connected
    case verifying
    case failed
}

enum OculaBLEConstants {
    static let serviceUUID = CBUUID(string: "9E3C0A0E-5B7A-4D73-B67E-6C1D75D8E0A1")
    static let serialCharacteristic = CBUUID(string: "9E3C0A0F-5B7A-4D73-B67E-6C1D75D8E0A1")
    static let pairingNonceCharacteristic = CBUUID(string: "9E3C0A10-5B7A-4D73-B67E-6C1D75D8E0A1")
    static let pairingResponseCharacteristic = CBUUID(string: "9E3C0A11-5B7A-4D73-B67E-6C1D75D8E0A1")
    static let telemetryCharacteristic = CBUUID(string: "9E3C0A12-5B7A-4D73-B67E-6C1D75D8E0A1")
}

final class OculaBLEManager: NSObject, ObservableObject {
    @Published var isPoweredOn = false
    @Published var isScanning = false
    @Published var connectionState: BLEConnectionState = .idle
    @Published var discoveredPeripheralName: String?
    @Published var discoveredPeripheralId: String?
    @Published var lastRSSI: NSNumber?
    @Published var discoveredSerial: String?
    @Published var pairingNonce: String?
    @Published var pairingResponseBase64: String?
    @Published var pairingProof: DeviceBLEProof?
    @Published var lastError: String?

    var preferredName: String?

    private var central: CBCentralManager!
    private var peripheral: CBPeripheral?
    private var serialCharacteristic: CBCharacteristic?
    private var nonceCharacteristic: CBCharacteristic?
    private var responseCharacteristic: CBCharacteristic?
    private var scanTimeoutWorkItem: DispatchWorkItem?
    private var currentNonce: String?
    private var expectedSerial: String?

    override init() {
        super.init()
        central = CBCentralManager(delegate: self, queue: nil)
    }

    func startScan(targetName: String? = nil) {
        preferredName = targetName
        lastError = nil
        pairingProof = nil
        pairingNonce = nil
        pairingResponseBase64 = nil
        discoveredSerial = nil

        guard central.state == .poweredOn else {
            lastError = "Bluetooth is off. Enable it to scan."
            connectionState = .failed
            return
        }

        if isScanning { return }
        isScanning = true
        connectionState = .scanning
        central.scanForPeripherals(
            withServices: [OculaBLEConstants.serviceUUID],
            options: [CBCentralManagerScanOptionAllowDuplicatesKey: false]
        )

        scanTimeoutWorkItem?.cancel()
        let workItem = DispatchWorkItem { [weak self] in
            guard let self else { return }
            if self.isScanning {
                self.stopScan()
                if self.peripheral == nil {
                    self.lastError = "No Ocula device found nearby."
                    self.connectionState = .failed
                }
            }
        }
        scanTimeoutWorkItem = workItem
        DispatchQueue.main.asyncAfter(deadline: .now() + 12, execute: workItem)
    }

    func stopScan() {
        central.stopScan()
        isScanning = false
        if connectionState == .scanning {
            connectionState = .idle
        }
    }

    func disconnect() {
        if let peripheral {
            central.cancelPeripheralConnection(peripheral)
        }
    }

    func startHandshake(expectedSerial: String?) {
        lastError = nil
        pairingProof = nil
        self.expectedSerial = expectedSerial

        guard connectionState == .connected, let peripheral else {
            lastError = "Connect to the device first."
            return
        }
        guard let nonceCharacteristic, let responseCharacteristic else {
            lastError = "Pairing characteristics not found."
            return
        }

        let nonce = UUID().uuidString
        currentNonce = nonce
        pairingNonce = nonce
        pairingResponseBase64 = nil
        connectionState = .verifying

        peripheral.setNotifyValue(true, for: responseCharacteristic)
        if let serialCharacteristic {
            peripheral.readValue(for: serialCharacteristic)
        }

        let data = Data(nonce.utf8)
        peripheral.writeValue(data, for: nonceCharacteristic, type: .withResponse)
    }

    var statusLabel: String {
        switch connectionState {
        case .idle: return "Idle"
        case .scanning: return "Scanning"
        case .connecting: return "Connecting"
        case .connected: return "Connected"
        case .verifying: return "Verifying"
        case .failed: return "Error"
        }
    }

    var canVerify: Bool {
        connectionState == .connected && nonceCharacteristic != nil && responseCharacteristic != nil
    }
}

extension OculaBLEManager: CBCentralManagerDelegate {
    func centralManagerDidUpdateState(_ central: CBCentralManager) {
        isPoweredOn = central.state == .poweredOn
        if !isPoweredOn {
            connectionState = .idle
            isScanning = false
        }
    }

    func centralManager(_ central: CBCentralManager,
                        didDiscover peripheral: CBPeripheral,
                        advertisementData: [String: Any],
                        rssi RSSI: NSNumber) {
        let name = peripheral.name ?? advertisementData[CBAdvertisementDataLocalNameKey] as? String
        if let preferredName, !preferredName.isEmpty {
            if let name, !name.localizedCaseInsensitiveContains(preferredName) {
                return
            }
        }

        lastRSSI = RSSI
        discoveredPeripheralName = name
        discoveredPeripheralId = peripheral.identifier.uuidString
        self.peripheral = peripheral
        self.peripheral?.delegate = self
        stopScan()

        connectionState = .connecting
        central.connect(peripheral, options: nil)
    }

    func centralManager(_ central: CBCentralManager, didConnect peripheral: CBPeripheral) {
        connectionState = .connected
        peripheral.delegate = self
        peripheral.discoverServices([OculaBLEConstants.serviceUUID])
    }

    func centralManager(_ central: CBCentralManager,
                        didFailToConnect peripheral: CBPeripheral,
                        error: Error?) {
        connectionState = .failed
        lastError = error?.localizedDescription ?? "Failed to connect."
    }

    func centralManager(_ central: CBCentralManager,
                        didDisconnectPeripheral peripheral: CBPeripheral,
                        error: Error?) {
        if let error {
            lastError = error.localizedDescription
        }
        connectionState = .idle
        currentNonce = nil
        expectedSerial = nil
    }
}

extension OculaBLEManager: CBPeripheralDelegate {
    func peripheral(_ peripheral: CBPeripheral, didDiscoverServices error: Error?) {
        if let error {
            lastError = error.localizedDescription
            return
        }
        guard let services = peripheral.services else { return }
        for service in services where service.uuid == OculaBLEConstants.serviceUUID {
            peripheral.discoverCharacteristics([
                OculaBLEConstants.serialCharacteristic,
                OculaBLEConstants.pairingNonceCharacteristic,
                OculaBLEConstants.pairingResponseCharacteristic,
                OculaBLEConstants.telemetryCharacteristic
            ], for: service)
        }
    }

    func peripheral(_ peripheral: CBPeripheral,
                    didDiscoverCharacteristicsFor service: CBService,
                    error: Error?) {
        if let error {
            lastError = error.localizedDescription
            return
        }
        guard let characteristics = service.characteristics else { return }
        for characteristic in characteristics {
            switch characteristic.uuid {
            case OculaBLEConstants.serialCharacteristic:
                serialCharacteristic = characteristic
                peripheral.readValue(for: characteristic)
            case OculaBLEConstants.pairingNonceCharacteristic:
                nonceCharacteristic = characteristic
            case OculaBLEConstants.pairingResponseCharacteristic:
                responseCharacteristic = characteristic
            default:
                break
            }
        }
    }

    func peripheral(_ peripheral: CBPeripheral,
                    didUpdateValueFor characteristic: CBCharacteristic,
                    error: Error?) {
        if let error {
            lastError = error.localizedDescription
            return
        }
        guard let data = characteristic.value else { return }

        if characteristic.uuid == OculaBLEConstants.serialCharacteristic {
            let serial = String(decoding: data, as: UTF8.self)
                .trimmingCharacters(in: .whitespacesAndNewlines)
            discoveredSerial = serial
            if let expectedSerial, !expectedSerial.isEmpty, expectedSerial != serial {
                lastError = "Serial mismatch. Check the device."
            }
            return
        }

        if characteristic.uuid == OculaBLEConstants.pairingResponseCharacteristic {
            let responseBase64 = data.base64EncodedString()
            pairingResponseBase64 = responseBase64
            if let nonce = currentNonce {
                pairingProof = DeviceBLEProof(
                    nonce: nonce,
                    responseBase64: responseBase64,
                    serial: discoveredSerial,
                    peripheralId: peripheral.identifier.uuidString,
                    bleName: discoveredPeripheralName
                )
                connectionState = .connected
                currentNonce = nil
                expectedSerial = nil
            }
        }
    }
}
