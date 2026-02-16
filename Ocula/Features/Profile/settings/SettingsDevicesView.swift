//
//  SettingsDevicesView.swift
//  Ocula
//
//  Created by Tyson Miles on 4/2/2026.
//

import SwiftUI
import FirebaseAuth
import FirebaseFirestore
import Combine

struct SettingsDevicesView: View {
    @EnvironmentObject var session: SessionManager
    @StateObject private var viewModel = DevicesViewModel()
    @State private var deviceToUnlink: LinkedDevice?

    var body: some View {
        SettingsScaffold(title: "Devices") {
            SettingsList {
                Section(header: SettingsSectionHeader(title: "Linked Devices")) {
                    if viewModel.isLoading {
                        HStack(spacing: 12) {
                            ProgressView()
                            Text("Loading devices...")
                                .captionStyle()
                        }
                    } else if viewModel.linkedDevices.isEmpty {
                        Text("No devices linked yet.")
                            .captionStyle()
                    } else {
                        ForEach(viewModel.linkedDevices) { device in
                            DeviceRow(device: device)
                                .swipeActions(edge: .trailing) {
                                    Button(role: .destructive) {
                                        deviceToUnlink = device
                                    } label: {
                                        Text("Unlink")
                                    }
                                }
                        }
                    }
                }

                Section {
                    Button("Add Device") {
                        viewModel.showAddDeviceSheet = true
                    }
                    .buttonStyle(PrimaryButtonStyle())
                    .listRowBackground(Color.clear)
                }
            }
        }
        .onAppear {
            if let uid = currentUserId {
                viewModel.startListening(uid: uid)
            }
        }
        .onChange(of: currentUserId) { newValue in
            if let uid = newValue {
                viewModel.startListening(uid: uid)
            }
        }
        .onDisappear {
            viewModel.stopListening()
        }
        .sheet(isPresented: $viewModel.showAddDeviceSheet) {
            AddDeviceFlowView(viewModel: viewModel)
                .environmentObject(session)
        }
        .alert("Device Error", isPresented: Binding(
            get: { viewModel.errorMessage != nil },
            set: { _ in viewModel.errorMessage = nil }
        )) {
            Button("OK", role: .cancel) { }
        } message: {
            Text(viewModel.errorMessage ?? "Something went wrong.")
        }
        .confirmationDialog(
            "Unlink this device?",
            isPresented: Binding(
                get: { deviceToUnlink != nil },
                set: { if !$0 { deviceToUnlink = nil } }
            ),
            titleVisibility: .visible
        ) {
            Button("Unlink Device", role: .destructive) {
                guard let uid = currentUserId, let device = deviceToUnlink else { return }
                Task {
                    await viewModel.unlinkDevice(uid: uid, deviceId: device.id)
                }
            }
            Button("Cancel", role: .cancel) { }
        }
    }

    private var currentUserId: String? {
        session.user?.id ?? Auth.auth().currentUser?.uid
    }
}

private struct DeviceRow: View {
    let device: LinkedDevice

    var body: some View {
        HStack(spacing: 16) {
            Image(systemName: "camera.fill")
                .title2Style()
                .foregroundColor(AppTheme.Colors.primary)
                .frame(width: 25)

            SettingsRowText(
                title: device.displayName,
                subtitle: device.summaryLine
            )

            Spacer()

            if let status = device.statusLabel {
                Text(status)
                    .font(.footnote)
                    .foregroundColor(AppTheme.Colors.secondary)
            }
        }
    }
}

struct AddDeviceFlowView: View {
    @EnvironmentObject var session: SessionManager
    @Environment(\.dismiss) private var dismiss
    @ObservedObject var viewModel: DevicesViewModel

    @StateObject private var bleManager = OculaBLEManager()
    @State private var step: AddDeviceStep = .method
    @State private var serialNumber: String = ""
    @State private var deviceName: String = ""
    @State private var isSubmitting = false
    @State private var showScanner = false
    @State private var errorMessage: String?
    @State private var showSuccessSheet = false
    @State private var animateSuccessIcon = false

    private var pairingService: LocalPairingService {
        DefaultLocalPairingService(bleManager: bleManager)
    }

    var body: some View {
        NavigationStack {
            SettingsScaffold(title: "Add Device") {
                SettingsList {
                    switch step {
                    case .method:
                        methodSection
                    case .details:
                        detailsSection
                    case .success:
                        successSection
                    }
                }
            }
            .toolbar {
                ToolbarItem(placement: .topBarLeading) {
                    Button("Close") { dismiss() }
                }
            }
            .sheet(isPresented: $showScanner) {
                QRScannerContainerView { payload in
                    handleScanResult(payload)
                }
            }
            .onChange(of: bleManager.discoveredSerial) { newValue in
                guard let serial = newValue, !serial.isEmpty else { return }
                if serialNumber.isEmpty {
                    serialNumber = serial
                }
            }
            .alert("Unable to Add Device", isPresented: Binding(
                get: { errorMessage != nil },
                set: { _ in errorMessage = nil }
            )) {
                Button("OK", role: .cancel) { }
            } message: {
                Text(errorMessage ?? "Please try again.")
            }
            .oculaAlertSheet(
                isPresented: $showSuccessSheet,
                icon: "checkmark",
                iconTint: .green,
                title: "Device Linked",
                message: "Your Ocula device is now linked to this account.",
                showsIconRing: false,
                iconAnimationActive: animateSuccessIcon,
                autoDismissAfter: 2.2,
                onAutoDismiss: {
                    animateSuccessIcon = false
                    showSuccessSheet = false
                    dismiss()
                }
            )
            .onDisappear {
                bleManager.stopScan()
                bleManager.disconnect()
            }
        }
    }

    private var methodSection: some View {
        Section(header: SettingsSectionHeader(title: "Choose Method")) {
            actionRow(
                icon: "qrcode.viewfinder",
                title: "Scan QR Code",
                subtitle: "Fastest way to add your Ocula device",
                action: {
                    showScanner = true
                },
                style: .list
            )

            actionRow(
                icon: "number.circle.fill",
                title: "Enter Serial Number",
                subtitle: "Manually enter the serial from the device",
                action: {
                    step = .details
                },
                style: .list
            )
        }
    }

    private var detailsSection: some View {
        Group {
            Section(header: SettingsSectionHeader(title: "Device Info")) {
                TextField("Serial Number (12 characters, e.g. SK49L1J3F522)", text: $serialNumber)
                    .textInputAutocapitalization(.characters)
                    .autocorrectionDisabled()
                TextField("Device Name (Optional)", text: $deviceName)
            }

            Section(header: SettingsSectionHeader(title: "Local Pairing")) {
                Text("Pairing confirms the device is nearby using Bluetooth. Wi-Fi pairing can be added later.")
                    .font(.footnote)
                    .foregroundStyle(.secondary)

                if !bleManager.isPoweredOn {
                    Text("Bluetooth is off. Enable Bluetooth to scan.")
                        .captionStyle()
                } else {
                    HStack {
                        Text("Status")
                        Spacer()
                        Text(bleManager.statusLabel)
                            .foregroundStyle(.secondary)
                    }

                    if let name = bleManager.discoveredPeripheralName {
                        HStack {
                            Text("Device")
                            Spacer()
                            Text(name)
                                .foregroundStyle(.secondary)
                        }
                    }

                    if let serial = bleManager.discoveredSerial, !serial.isEmpty {
                        HStack {
                            Text("Serial")
                            Spacer()
                            Text(serial)
                                .foregroundStyle(.secondary)
                        }
                    }

                    if let rssi = bleManager.lastRSSI {
                        HStack {
                            Text("Signal")
                            Spacer()
                            Text("\(rssi)")
                                .foregroundStyle(.secondary)
                        }
                    }
                }

                if let error = bleManager.lastError {
                    Text(error)
                        .font(.footnote)
                        .foregroundStyle(.red)
                }

                Button(bleManager.isScanning ? "Scanning..." : "Scan for Device") {
                    bleManager.startScan(targetName: bleManager.preferredName)
                }
                .buttonStyle(PrimaryButtonStyle())
                .disabled(!bleManager.isPoweredOn || bleManager.isScanning)
                .listRowBackground(Color.clear)

                if bleManager.connectionState == .connected {
                    Button("Disconnect") {
                        bleManager.disconnect()
                    }
                    .buttonStyle(SecondaryLightButtonStyle())
                    .listRowBackground(Color.clear)
                }
            }

            Section {
                Button(isSubmitting ? "Pairing..." : "Pair & Link Device") {
                    submitPairing()
                }
                .buttonStyle(PrimaryButtonStyle())
                .disabled(isSubmitting)
                .listRowBackground(Color.clear)
            }
        }
    }

    private var successSection: some View {
        Section {
            VStack(alignment: .leading, spacing: 12) {
                Text("Device Linked")
                    .headlineStyle()
                Text("Your device is ready. It will appear under Linked Devices.")
                    .captionStyle()
                Button("Done") {
                    dismiss()
                }
                .buttonStyle(PrimaryButtonStyle())
            }
            .padding(.vertical, 6)
            .listRowBackground(Color.clear)
        }
    }

    private func handleScanResult(_ payload: String) {
        let parsed = DeviceQRCodeParser.parse(payload)
        guard let parsed else {
            errorMessage = "We couldn't read that QR code. Try again or enter the serial manually."
            return
        }
        serialNumber = parsed.serial
        bleManager.preferredName = parsed.bleName
        step = .details
    }

    private func submitPairing() {
        guard let uid = session.user?.id ?? Auth.auth().currentUser?.uid else {
            errorMessage = "Please sign in to add a device."
            return
        }

        let normalizedSerial = DeviceSerialFormatter.normalize(serialNumber)
        guard DeviceSerialFormatter.isValid(normalizedSerial) else {
            errorMessage = "Enter a valid 12-character serial number (A-Z, 0-9)."
            return
        }

        isSubmitting = true
        let repository = DeviceRepository()
        let nickname = deviceName.trimmingCharacters(in: .whitespacesAndNewlines)

        Task {
            do {
                let result = try await pairingService.pair(serial: normalizedSerial)
                try await repository.linkDevice(uid: uid, result: result, nickname: nickname)
                await MainActor.run {
                    animateSuccessIcon = true
                    showSuccessSheet = true
                    isSubmitting = false
                }
            } catch {
                await MainActor.run {
                    isSubmitting = false
                    errorMessage = error.localizedDescription
                }
            }
        }
    }
}

enum AddDeviceStep {
    case method
    case details
    case success
}

struct LinkedDevice: Identifiable {
    let id: String
    let serialNumber: String
    let nickname: String?
    let model: String?
    let firmwareVersion: String?
    let lastSeen: Date?
    let status: String?
    let createdAt: Date?

    init?(snapshot: DocumentSnapshot) {
        guard let data = snapshot.data(),
              let serialNumber = data["serial"] as? String else {
            return nil
        }
        self.id = snapshot.documentID
        self.serialNumber = serialNumber
        self.nickname = data["nickname"] as? String
        self.model = data["model"] as? String
        self.firmwareVersion = data["firmwareVersion"] as? String
        self.status = data["status"] as? String
        self.createdAt = (data["pairedAt"] as? Timestamp)?.dateValue()
        self.lastSeen = (data["lastSeenAt"] as? Timestamp)?.dateValue()
    }

    var displayName: String {
        if let nickname, !nickname.isEmpty { return nickname }
        if let model, !model.isEmpty { return model }
        return "Ocula"
    }

    var summaryLine: String {
        var parts: [String] = ["Serial \(serialNumber)"]
        if let lastSeen {
            parts.append("Last seen \(DeviceDateFormatter.relative(lastSeen))")
        }
        return parts.joined(separator: " • ")
    }

    var statusLabel: String? {
        guard let status, !status.isEmpty else { return nil }
        return status.capitalized
    }
}

final class DevicesViewModel: ObservableObject {
    @Published var linkedDevices: [LinkedDevice] = []
    @Published var isLoading = false
    @Published var showAddDeviceSheet = false
    @Published var errorMessage: String?

    private let db = Firestore.firestore()
    private var linkedListener: ListenerRegistration?
    private var currentUid: String?
    private let repository = DeviceRepository()

    deinit {
        stopListening()
    }

    func startListening(uid: String) {
        guard currentUid != uid else { return }
        stopListening()
        currentUid = uid
        isLoading = true

        linkedListener = db.collection("users")
            .document(uid)
            .collection("devices")
            .addSnapshotListener { [weak self] snapshot, error in
                guard let self else { return }
                if let error {
                    Task { @MainActor in
                        self.errorMessage = error.localizedDescription
                        self.isLoading = false
                    }
                    return
                }
                let devices = snapshot?.documents.compactMap(LinkedDevice.init(snapshot:)) ?? []
                Task { @MainActor in
                    self.linkedDevices = devices.sorted {
                        ($0.createdAt ?? Date.distantPast) > ($1.createdAt ?? Date.distantPast)
                    }
                    self.isLoading = false
                }
            }
    }

    func stopListening() {
        linkedListener?.remove()
        linkedListener = nil
        currentUid = nil
    }

    func unlinkDevice(uid: String, deviceId: String) async {
        do {
            try await repository.unlinkDevice(uid: uid, deviceId: deviceId)
        } catch {
            await MainActor.run {
                self.errorMessage = error.localizedDescription
            }
        }
    }
}

enum DeviceSerialFormatter {
    static func normalize(_ input: String) -> String {
        input
            .trimmingCharacters(in: .whitespacesAndNewlines)
            .uppercased()
            .replacingOccurrences(of: " ", with: "")
            .replacingOccurrences(of: "-", with: "")
    }

    static func isValid(_ input: String) -> Bool {
        guard input.count == 12 else { return false }
        let pattern = "^[A-Z0-9]{12}$"
        return NSPredicate(format: "SELF MATCHES %@", pattern).evaluate(with: input)
    }
}

struct DeviceQRCodePayload {
    let serial: String
    let bleName: String?
}

enum DeviceQRCodeParser {
    static func parse(_ payload: String) -> DeviceQRCodePayload? {
        let trimmed = payload.trimmingCharacters(in: .whitespacesAndNewlines)

        if let components = URLComponents(string: trimmed),
           let scheme = components.scheme?.lowercased(),
           scheme == "ocula" {
            let serial = components.queryItems?.first(where: { $0.name == "serial" || $0.name == "sn" })?.value
            let bleName = components.queryItems?.first(where: { $0.name == "ble" || $0.name == "bleName" })?.value
            if let serial {
                return DeviceQRCodePayload(
                    serial: DeviceSerialFormatter.normalize(serial),
                    bleName: bleName
                )
            }
        }

        if let data = trimmed.data(using: .utf8),
           let json = try? JSONSerialization.jsonObject(with: data) as? [String: Any] {
            let serial = json["serial"] as? String ?? json["serialNumber"] as? String
            let ble = json["ble"] as? String ?? json["bleName"] as? String
            if let serial {
                return DeviceQRCodePayload(
                    serial: DeviceSerialFormatter.normalize(serial),
                    bleName: ble
                )
            }
        }

        let normalized = DeviceSerialFormatter.normalize(trimmed)
        if DeviceSerialFormatter.isValid(normalized) {
            return DeviceQRCodePayload(
                serial: normalized,
                bleName: nil
            )
        }

        return nil
    }
}

enum DeviceDateFormatter {
    private static let relativeFormatter: RelativeDateTimeFormatter = {
        let formatter = RelativeDateTimeFormatter()
        formatter.unitsStyle = .abbreviated
        return formatter
    }()

    static func relative(_ date: Date) -> String {
        relativeFormatter.localizedString(for: date, relativeTo: Date())
    }
}

#Preview {
    SettingsDevicesView()
        .environmentObject(SessionManager())
}
