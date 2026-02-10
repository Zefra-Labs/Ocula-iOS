//
//  SettingsCarView.swift
//  Ocula
//
//  Created by Tyson Miles on 7/2/2026.
//

import SwiftUI
import FirebaseAuth
import FirebaseFirestore

struct SettingsCarView: View {
    @EnvironmentObject var session: SessionManager

    @State private var driverNickname: String = ""
    @State private var vehicleNickname: String = ""
    @State private var selectedBrand: CarBrand = .bmw
    @State private var selectedColor: CarColorOption = CarColorOption.standard[0]
    @State private var isSaving = false
    @State private var saveMessage: String? = nil

    var body: some View {
        SettingsScaffold(title: "Car") {
            SettingsList {
                Section(header: SettingsSectionHeader(title: "Driver")) {
                    TextField("Driver nickname", text: $driverNickname)
                }

                Section(header: SettingsSectionHeader(title: "Vehicle")) {
                    TextField("Vehicle nickname", text: $vehicleNickname)

                    Picker("Car Brand", selection: $selectedBrand) {
                        ForEach(CarBrand.allCases) { brand in
                            Text(brand.rawValue).tag(brand)
                        }
                    }
                    .pickerStyle(.navigationLink)

                    Picker("Car Color", selection: $selectedColor) {
                        ForEach(CarColorOption.standard) { option in
                            HStack(spacing: 8) {
                                Circle()
                                    .fill(Color(hex: option.hex) ?? AppTheme.Colors.secondary)
                                    .frame(width: 16, height: 16)
                                Text(option.name)
                            }
                            .tag(option)
                        }
                    }
                    .pickerStyle(.navigationLink)
                }

                Section {
                    Button(isSaving ? "Saving..." : "Save Changes") {
                        saveProfilePreferences()
                    }
                    .buttonStyle(PrimaryButtonStyle())
                    .disabled(isSaving)
                }

                if let saveMessage {
                    Section {
                        Text(saveMessage)
                            .captionStyle()
                    }
                }
            }
            .onAppear(perform: loadCurrentValues)
        }
    }
}

private extension SettingsCarView {

    func loadCurrentValues() {
        driverNickname = session.user?.driverNickname ?? "Night Runner"
        vehicleNickname = session.user?.vehicleNickname ?? "Midnight Coupe"

        if let brand = session.user?.vehicleBrand, let matched = CarBrand(rawValue: brand) {
            selectedBrand = matched
        }

        if let colorHex = session.user?.vehicleColorHex,
           let matched = CarColorOption.standard.first(where: { $0.hex.lowercased() == colorHex.lowercased() }) {
            selectedColor = matched
        }
    }

    func saveProfilePreferences() {
        guard let uid = session.user?.id ?? Auth.auth().currentUser?.uid else { return }

        isSaving = true
        saveMessage = nil

        let payload: [String: Any] = [
            "driverNickname": driverNickname,
            "vehicleNickname": vehicleNickname,
            "vehicleBrand": selectedBrand.rawValue,
            "vehicleColorHex": selectedColor.hex
        ]

        Firestore.firestore().collection("users").document(uid).setData(payload, merge: true) { error in
            Task { @MainActor in
                isSaving = false
                if let error {
                    saveMessage = error.localizedDescription
                } else {
                    saveMessage = "Saved"
                    session.refreshUser()
                }
            }
        }
    }
}

#Preview {
    SettingsCarView()
        .environmentObject(SessionManager())
}
