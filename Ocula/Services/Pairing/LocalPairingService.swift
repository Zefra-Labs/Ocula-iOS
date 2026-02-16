//
//  LocalPairingService.swift
//  Ocula
//
//  Created by Tyson Miles on 4/2/2026.
//

import Foundation

protocol LocalPairingService {
    func pair(serial: String) async throws -> LocalPairingResult
}

enum PairingMethod: String {
    case ble
    case wifi
}

struct LocalPairingResult {
    let serial: String
    let deviceId: String
    let model: String?
    let firmwareVersion: String?
    let hardwareRev: String?
    let pairingMethod: PairingMethod
    let pairingToken: String
}

enum LocalPairingError: LocalizedError {
    case invalidSerial
    case bluetoothUnavailable
    case deviceNotFound

    var errorDescription: String? {
        switch self {
        case .invalidSerial:
            return "Invalid serial number."
        case .bluetoothUnavailable:
            return "Bluetooth is unavailable."
        case .deviceNotFound:
            return "No matching device found nearby."
        }
    }
}

struct DefaultLocalPairingService: LocalPairingService {
    private let bleManager: OculaBLEManager?

    init(bleManager: OculaBLEManager? = nil) {
        self.bleManager = bleManager
    }

    func pair(serial: String) async throws -> LocalPairingResult {
        let normalized = DeviceSerialFormatter.normalize(serial)
        guard DeviceSerialFormatter.isValid(normalized) else {
            throw LocalPairingError.invalidSerial
        }

        #if targetEnvironment(simulator)
        try await Task.sleep(nanoseconds: 500_000_000)
        return LocalPairingResult(
            serial: normalized,
            deviceId: normalized,
            model: "Ocula Pilot",
            firmwareVersion: "0.1.0-sim",
            hardwareRev: nil,
            pairingMethod: .ble,
            pairingToken: UUID().uuidString
        )
        #else
        if let bleManager {
            if !bleManager.isPoweredOn {
                throw LocalPairingError.bluetoothUnavailable
            }
            if let discovered = bleManager.discoveredSerial,
               DeviceSerialFormatter.normalize(discovered) == normalized {
                return LocalPairingResult(
                    serial: normalized,
                    deviceId: normalized,
                    model: "Ocula",
                    firmwareVersion: nil,
                    hardwareRev: nil,
                    pairingMethod: .ble,
                    pairingToken: UUID().uuidString
                )
            }
        }

        #if DEBUG
        // TODO: Replace this mock fallback with a real BLE handshake on device builds.
        try await Task.sleep(nanoseconds: 700_000_000)
        return LocalPairingResult(
            serial: normalized,
            deviceId: normalized,
            model: "Ocula",
            firmwareVersion: nil,
            hardwareRev: nil,
            pairingMethod: .ble,
            pairingToken: UUID().uuidString
        )
        #else
        throw LocalPairingError.deviceNotFound
        #endif
        #endif
    }
}
