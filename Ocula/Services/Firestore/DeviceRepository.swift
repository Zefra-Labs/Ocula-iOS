//
//  DeviceRepository.swift
//  Ocula
//
//  Created by Tyson Miles on 4/2/2026.
//

import Foundation
import FirebaseFirestore

final class DeviceRepository {
    private let db = Firestore.firestore()

    func linkDevice(uid: String, result: LocalPairingResult, nickname: String?) async throws {
        let deviceId = result.deviceId
        let globalRef = db.collection("devices").document(deviceId)
        let userRef = db.collection("users").document(uid).collection("devices").document(deviceId)

        let globalSnapshot = try await globalRef.getDocument()
        let userSnapshot = try await userRef.getDocument()

        var globalData: [String: Any] = [
            "serial": result.serial,
            "status": "active",
            "currentOwnerUid": uid,
            "updatedAt": FieldValue.serverTimestamp(),
            "lastSeenAt": FieldValue.serverTimestamp()
        ]

        if let model = result.model {
            globalData["model"] = model
        }
        if let hardwareRev = result.hardwareRev {
            globalData["hardwareRev"] = hardwareRev
        }
        if let firmwareVersion = result.firmwareVersion {
            globalData["firmwareVersion"] = firmwareVersion
        }
        if !globalSnapshot.exists {
            globalData["createdAt"] = FieldValue.serverTimestamp()
        }

        var userData: [String: Any] = [
            "deviceId": deviceId,
            "serial": result.serial,
            "pairedAt": FieldValue.serverTimestamp(),
            "pairingMethod": result.pairingMethod.rawValue,
            "lastSeenAt": FieldValue.serverTimestamp(),
            "status": "active"
        ]

        if let model = result.model {
            userData["model"] = model
        }
        if let firmwareVersion = result.firmwareVersion {
            userData["firmwareVersion"] = firmwareVersion
        }

        let trimmedNickname = nickname?.trimmingCharacters(in: .whitespacesAndNewlines) ?? ""
        if !trimmedNickname.isEmpty {
            userData["nickname"] = trimmedNickname
        } else if !userSnapshot.exists {
            userData["nickname"] = result.model ?? "Ocula"
        }

        let batch = db.batch()
        batch.setData(globalData, forDocument: globalRef, merge: true)
        batch.setData(userData, forDocument: userRef, merge: true)
        try await batch.commit()
    }

    func unlinkDevice(uid: String, deviceId: String) async throws {
        let userRef = db.collection("users").document(uid).collection("devices").document(deviceId)
        let globalRef = db.collection("devices").document(deviceId)

        let batch = db.batch()
        batch.deleteDocument(userRef)
        batch.setData([
            "currentOwnerUid": NSNull(),
            "status": "unclaimed",
            "updatedAt": FieldValue.serverTimestamp()
        ], forDocument: globalRef, merge: true)

        try await batch.commit()
    }
}
