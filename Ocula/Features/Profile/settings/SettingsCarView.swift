//
//  SettingsCarView.swift
//  Ocula
//
//  Created by Tyson Miles on 7/2/2026.
//

import SwiftUI
import UIKit
import FirebaseAuth
import FirebaseFirestore

struct SettingsCarView: View {
    @EnvironmentObject var session: SessionManager

    @State private var driverNickname: String = ""
    @State private var vehicleNickname: String = ""
    @State private var vehiclePlate: String = ""
    @State private var plateTemplate: LicensePlateTemplate = .american
    @State private var plateSize: LicensePlateSize = .standard
    @State private var plateTextColor: Color = .black
    @State private var plateBackgroundColor: Color = .white
    @State private var plateBorderColor: Color = Color(.systemGray3)
    @State private var plateBorderWidth: Double = 2
    @State private var selectedBrand: CarBrand = .bmw
    @State private var customBrand: String = ""
    @State private var vehicleColor: Color = Color(hex: "2563EB") ?? .blue
    @State private var isSaving = false
    @State private var saveMessage: String? = nil
    @State private var showSuccessSheet = false
    @State private var animateIcon = false
    @State private var didLoad = false

    var body: some View {
        
        SettingsScaffold(title: "Car") {
            SettingsList {
                Section(header: SettingsSectionHeader(title: "Driver Nickname")) {
                    TextField("Driver nickname", text: $driverNickname)
                }

                Section(header: SettingsSectionHeader(title: "Vehicle Details")) {
                    HStack {
                        Text("Nickname")
                            .foregroundStyle(.primary)
                        Spacer()
                        TextField("Enter nickname", text: $vehicleNickname)
                            .multilineTextAlignment(.trailing)
                            .foregroundStyle(.secondary)
                    }
                }
                Section(header: SettingsSectionHeader(title: "Licence Plate")) {
                    NavigationLink {
                        SettingsLicensePlateView(
                            vehiclePlate: $vehiclePlate,
                            plateTemplate: $plateTemplate,
                            plateSize: $plateSize,
                            plateTextColor: $plateTextColor,
                            plateBackgroundColor: $plateBackgroundColor,
                            plateBorderColor: $plateBorderColor,
                            plateBorderWidth: $plateBorderWidth
                        )
                    } label: {
                        HStack {
                            Text("Plate Details")
                                .foregroundStyle(.primary)
                            Spacer()
                            Text(plateTemplate.rawValue)
                                .foregroundStyle(.secondary)
                                .lineLimit(1)
                        }
                    }
                }
                Section(header: SettingsSectionHeader(title: "Vehicle Brand")) {
                    Picker("Brand", selection: $selectedBrand) {
                        ForEach(brandOptions) { brand in
                            Text(brand.rawValue).tag(brand)
                        }
                    }
                    .pickerStyle(.navigationLink)
                    
                    if selectedBrand == .other {
                        HStack {
                            Text("Other")
                                .foregroundStyle(.primary)
                            Spacer()
                            TextField("Enter custom brand", text: $customBrand)
                                .multilineTextAlignment(.trailing)
                                .foregroundStyle(.secondary)
                        }
                    }
                }
                Section(header: SettingsSectionHeader(title: "Vehicle Appearance")) {

                    ColorPicker("Color", selection: $vehicleColor, supportsOpacity: false)
                }

            }
            .onAppear {
                if !didLoad {
                    loadCurrentValues()
                    didLoad = true
                }
            }
        }
        .toolbar {
            ToolbarItem(placement: .topBarTrailing) {
                Button(isSaving ? "" : "Save") {
                    saveProfilePreferences()
                }
                .disabled(isSaving)
                .overlay(alignment: .trailing) {
                    if isSaving {
                        ProgressView()
                    }
                }
            }
        }
        .oculaAlertSheet(
            isPresented: $showSuccessSheet,
            icon: "checkmark",
            iconTint: .green,
            title: "Saved",
            message: "",
            showsIconRing: false,
            iconAnimationActive: animateIcon,
            autoDismissAfter: 1.8,
            onAutoDismiss: {
                showSuccessSheet = false
                animateIcon = false
            }
        )
    }
}

private extension SettingsCarView {
    var brandOptions: [CarBrand] {
        [.other] + CarBrand.allCases.filter { $0 != .other }
    }


    func loadCurrentValues() {
        driverNickname = session.user?.driverNickname ?? "Night Runner"
        vehicleNickname = session.user?.vehicleNickname ?? "Midnight Coupe"
        vehiclePlate = session.user?.vehiclePlate ?? ""
        if let storedStyle = session.user?.vehiclePlateStyle,
           let resolvedStyle = LicensePlateTemplate(rawValue: storedStyle) {
            plateTemplate = resolvedStyle
        }
        if let storedSize = session.user?.vehiclePlateSize,
           let resolvedSize = LicensePlateSize(rawValue: storedSize) {
            plateSize = resolvedSize
        }
        plateTextColor = {
            if let textHex = session.user?.vehiclePlateTextColorHex,
               let textColor = Color(hex: textHex) {
                return textColor
            }
            return plateTemplate.defaultTextColor
        }()
        plateBackgroundColor = {
            if let backgroundHex = session.user?.vehiclePlateBackgroundColorHex,
               let backgroundColor = Color(hex: backgroundHex) {
                return backgroundColor
            }
            return plateTemplate.defaultBackgroundColor
        }()
        plateBorderColor = {
            if let borderHex = session.user?.vehiclePlateBorderColorHex,
               let borderColor = Color(hex: borderHex) {
                return borderColor
            }
            return plateTemplate.defaultBorderColor
        }()
        plateBorderWidth = session.user?.vehiclePlateBorderWidth ?? plateTemplate.defaultBorderWidth

        if let brand = session.user?.vehicleBrand {
            if let matched = CarBrand(rawValue: brand) {
                selectedBrand = matched
                customBrand = ""
            } else {
                selectedBrand = .other
                customBrand = brand
            }
        }

        if let colorHex = session.user?.vehicleColorHex,
           let color = Color(hex: colorHex) {
            vehicleColor = color
        }
    }

    func saveProfilePreferences() {
        guard let uid = session.user?.id ?? Auth.auth().currentUser?.uid else { return }

        isSaving = true
        saveMessage = nil

        let brandToStore: String = {
            if selectedBrand == .other {
                let trimmed = customBrand.trimmingCharacters(in: .whitespacesAndNewlines)
                return trimmed.isEmpty ? CarBrand.other.rawValue : trimmed
            }
            return selectedBrand.rawValue
        }()

        let payload: [String: Any] = [
            "driverNickname": driverNickname,
            "vehicleNickname": vehicleNickname,
            "vehiclePlate": vehiclePlate,
            "vehiclePlateStyle": plateTemplate.rawValue,
            "vehiclePlateSize": plateSize.rawValue,
            "vehiclePlateTextColorHex": colorHex(from: plateTextColor),
            "vehiclePlateBackgroundColorHex": colorHex(from: plateBackgroundColor),
            "vehiclePlateBorderColorHex": colorHex(from: plateBorderColor),
            "vehiclePlateBorderWidth": plateBorderWidth,
            "vehicleBrand": brandToStore,
            "vehicleColorHex": colorHex(from: vehicleColor)
        ]

        Firestore.firestore().collection("users").document(uid).setData(payload, merge: true) { error in
            Task { @MainActor in
                isSaving = false
                if let error {
                    saveMessage = error.localizedDescription
                } else {
                    saveMessage = "Saved"
                    session.refreshUser()
                    animateIcon = true
                    showSuccessSheet = true
                }
            }
        }
    }

    func colorHex(from color: Color) -> String {
        let uiColor = UIColor(color)
        var red: CGFloat = 0
        var green: CGFloat = 0
        var blue: CGFloat = 0
        var alpha: CGFloat = 0
        guard uiColor.getRed(&red, green: &green, blue: &blue, alpha: &alpha) else {
            return "000000"
        }
        return String(format: "%02X%02X%02X",
                      Int(red * 255),
                      Int(green * 255),
                      Int(blue * 255))
    }
}

#Preview {
    SettingsCarView()
        .environmentObject(SessionManager())
}
