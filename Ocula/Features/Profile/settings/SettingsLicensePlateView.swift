//
//  SettingsLicensePlateView.swift
//  Ocula
//
//  Created by Tyson Miles on 2/14/2026.
//

import SwiftUI

enum LicensePlateTemplate: String, CaseIterable, Identifiable {
    case ausQld = "Australia - Variation 1"
    case ausNsw = "Australia - Variation 2"
    case american = "United States - Variation 1"
    case euro = "European Union - Variation 1"
    case custom = "Custom"

    var id: String { rawValue }

    var cornerRadius: CGFloat {
        switch self {
        case .ausQld:
            return 10
        case .ausNsw:
            return 10
        case .american:
            return 10
        case .euro:
            return 8
        case .custom:
            return 10
        }
    }

    var stripePlacement: StripePlacement {
        switch self {
        case .euro:
            return .left
        default:
            return .none
        }
    }

    var stripeColor: Color {
        switch self {
        case .euro:
            return Color(hex: "1D4ED8") ?? .blue
        default:
            return .clear
        }
    }

    var stripeText: String? {
        switch self {
        case .euro:
            return "EU"
        default:
            return nil
        }
    }

    var headerText: String? {
        switch self {
        case .american:
            return "In God We Trust"
        default:
            return nil
        }
    }

    var footerText: String? {
        switch self {
        case .ausQld:
            return "QUEENSLAND - SUNSHINE STATE"
        case .ausNsw:
            return "NEW SOUTH WALES"
        case .american:
            return "United States of America"
        default:
            return nil
        }
    }

    var defaultTextColor: Color {
        switch self {
        case .ausQld:
            return Color(hex: "7A0026") ?? Color(red: 0.48, green: 0, blue: 0.15)
        case .ausNsw:
            return .black
        case .american:
            return .black
        case .euro:
            return .black
        case .custom:
            return .black
        }
    }

    var defaultBackgroundColor: Color {
        switch self {
        case .ausQld:
            return .white
        case .ausNsw:
            return Color(hex: "F6E86D") ?? Color(red: 0.96, green: 0.91, blue: 0.43)
        case .american:
            return .white
        case .euro:
            return .white
        case .custom:
            return .white
        }
    }

    var defaultBorderColor: Color {
        switch self {
        case .ausQld:
            return Color(hex: "7A0026") ?? Color(red: 0.48, green: 0, blue: 0.15)
        case .ausNsw:
            return .black
        case .american:
            return Color(.systemGray3)
        case .euro:
            return Color(.systemGray3)
        case .custom:
            return Color(.systemGray3)
        }
    }

    var defaultBorderWidth: Double {
        return 1
    }

    enum StripePlacement {
        case none
        case left
    }
}

enum LicensePlateSize: String, CaseIterable, Identifiable {
    case compact = "Compact"
    case standard = "Standard"
    case wide = "Wide"

    var id: String { rawValue }

    var size: CGSize {
        switch self {
        case .compact:
            return CGSize(width: 170, height: 85)
        case .standard:
            return CGSize(width: 240, height: 85)
        case .wide:
            return CGSize(width: 300, height: 72)
        }
    }
}

struct SettingsLicensePlateView: View {
    @Binding var vehiclePlate: String
    @Binding var plateTemplate: LicensePlateTemplate
    @Binding var plateSize: LicensePlateSize
    @Binding var plateTextColor: Color
    @Binding var plateBackgroundColor: Color
    @Binding var plateBorderColor: Color
    @Binding var plateBorderWidth: Double

    var body: some View {
        SettingsScaffold(title: "License Plate") {
            SettingsList {
                Section(header: SettingsSectionHeader(title: "Preview")) {
                    platePreview
                        .frame(maxWidth: .infinity)
                }

                Section(header: SettingsSectionHeader(title: "Plate Text")) {
                    TextField("Enter vehicle plate", text: $vehiclePlate)
                }

                Section(header: SettingsSectionHeader(title: "Template")) {
                    Picker("Template", selection: $plateTemplate) {
                        ForEach(LicensePlateTemplate.allCases) { template in
                            Text(template.rawValue).tag(template)
                        }
                    }
                    .pickerStyle(.navigationLink)
                }

                Section(header: SettingsSectionHeader(title: "Size")) {
                    Picker("Size", selection: $plateSize) {
                        ForEach(LicensePlateSize.allCases) { size in
                            Text(size.rawValue).tag(size)
                        }
                    }
                    .pickerStyle(.segmented)
                }

                Section(header: SettingsSectionHeader(title: "Colors")) {
                    ColorPicker("Text Color", selection: $plateTextColor, supportsOpacity: false)
                    ColorPicker("Background Color", selection: $plateBackgroundColor, supportsOpacity: false)
                    Button("Reset Template Colors") {
                        applyTemplateDefaults()
                    }
                }

                Section(header: SettingsSectionHeader(title: "Border")) {
                    Toggle("Show Border", isOn: showBorderBinding)
                    if showBorderBinding.wrappedValue {
                        ColorPicker("Border Color", selection: $plateBorderColor, supportsOpacity: false)
                        HStack {
                            Text("Border Width")
                                .foregroundStyle(.primary)
                            Spacer()
                            Text(String(format: "%.1f", plateBorderWidth))
                                .foregroundStyle(.secondary)
                        }
                        Slider(value: $plateBorderWidth, in: 0.5...6, step: 0.5)
                    }
                }
            }
        }
        .onAppear {
            applyTemplateDefaultsIfNeeded()
        }
        .onChange(of: plateTemplate) { _ in
            applyTemplateDefaults()
        }
    }
}

private extension SettingsLicensePlateView {
    var effectiveSize: LicensePlateSize {
        plateSize
    }

    var showBorderBinding: Binding<Bool> {
        Binding(
            get: { plateBorderWidth > 0.1 },
            set: { isOn in
                if isOn {
                    plateBorderWidth = max(plateBorderWidth, 1)
                } else {
                    plateBorderWidth = 0
                }
            }
        )
    }

    func applyTemplateDefaultsIfNeeded() {
        if plateBorderWidth == 0 && plateBorderColor == .clear {
            applyTemplateDefaults()
        }
    }

    func applyTemplateDefaults() {
        plateTextColor = plateTemplate.defaultTextColor
        plateBackgroundColor = plateTemplate.defaultBackgroundColor
        plateBorderColor = plateTemplate.defaultBorderColor
        plateBorderWidth = plateTemplate.defaultBorderWidth
    }

    var platePreview: some View {
        let plateSize = effectiveSize.size
        return ZStack {
            RoundedRectangle(cornerRadius: plateTemplate.cornerRadius, style: .continuous)
                .fill(plateBackgroundColor)
                .overlay(borderOverlay)
                .shadow(color: Color.black.opacity(0.08), radius: 4, x: 0, y: 2)

            stripeOverlay

            if plateTemplate.headerText == nil && plateTemplate.footerText == nil {
                Text(formattedPlateText)
                    .font(.custom("LicensePlate", size: 55))
                    .foregroundStyle(plateTextColor)
                    .tracking(2)
                    .minimumScaleFactor(0.6)
                    .lineLimit(1)
                    .padding(.horizontal, 6)
            } else {
                VStack(spacing: 0) {
                    if let headerText = plateTemplate.headerText {
                        Text(headerText)
                            .font(.caption2.weight(.semibold))
                            .padding(.top, 3)
                            .foregroundStyle(plateTextColor.opacity(0.9))
                    }
                    

                    Text(formattedPlateText)
                        .font(.custom("LicensePlate", size: 50))
                        .foregroundStyle(plateTextColor)
                        .tracking(2)
                        .minimumScaleFactor(0.6)
                        .lineLimit(1)
                        .padding(.horizontal, 18)


                    
                    if let footerText = plateTemplate.footerText {
                        Text(footerText)
                            .font(.caption2.weight(.semibold))
                            .padding(.bottom, 4)
                            .foregroundStyle(plateTextColor.opacity(0.9))
                    }
                }
            }
        }
        .frame(width: plateSize.width, height: plateSize.height)
        .padding(.vertical, 6)
    }

    var formattedPlateText: String {
        let cleaned = vehiclePlate.uppercased().filter { $0.isLetter || $0.isNumber }
        if cleaned.isEmpty {
            switch plateTemplate {
            case .ausQld:
                return "ABC-123"
            case .ausNsw:
                return "AB-C1-23"
            case .american:
                return "ABC-123"
            case .euro:
                return "AB C123"
            case .custom:
                return "CUSTOM"
            }
        }

        switch plateTemplate {
        case .ausQld:
            return formatGroups(cleaned, groups: [3, 3])
        case .ausNsw:
            return formatGroups(cleaned, groups: [3, 2, 1])
        case .american:
            return String(cleaned.prefix(7))
        case .euro:
            return String(cleaned.prefix(8))
        case .custom:
            return String(cleaned.prefix(8))
        }
    }

    func formatGroups(_ text: String, groups: [Int]) -> String {
        var result: [String] = []
        var index = text.startIndex

        for group in groups {
            guard index < text.endIndex else { break }
            let end = text.index(index, offsetBy: group, limitedBy: text.endIndex) ?? text.endIndex
            result.append(String(text[index..<end]))
            index = end
        }

        if index < text.endIndex {
            result.append(String(text[index...]))
        }

        return result.joined(separator: "-")
    }

    @ViewBuilder
    var borderOverlay: some View {
        if plateBorderWidth > 0 {
            RoundedRectangle(cornerRadius: plateTemplate.cornerRadius, style: .continuous)
                .stroke(plateBorderColor, lineWidth: plateBorderWidth)
        }
    }

    @ViewBuilder
    var stripeOverlay: some View {
        switch plateTemplate.stripePlacement {
        case .none:
            EmptyView()
        case .left:
            let innerRadius = max(0, plateTemplate.cornerRadius)
            HStack(spacing: 0) {
                UnevenRoundedRectangle(cornerRadii: .init(
                    topLeading: innerRadius,
                    bottomLeading: innerRadius,
                    bottomTrailing: 0,
                    topTrailing: 0
                ), style: .continuous)
                    .fill(plateTemplate.stripeColor)
                    .frame(width: 35)
                    .overlay(euStripeLabel)
                Spacer()
            }
        }
    }

    @ViewBuilder
    var euStripeLabel: some View {
        if plateTemplate == .euro {
            VStack(spacing: 6) {
                GeometryReader { proxy in
                    let size = min(proxy.size.width, proxy.size.height)
                    let radius = size * 0.35
                    let center = CGPoint(x: proxy.size.width / 2, y: proxy.size.height / 2)
                    ZStack {
                        ForEach(0..<12, id: \.self) { index in
                            let angle = (Double(index) / 12.0) * (2.0 * Double.pi) - Double.pi / 2
                            let x = center.x + CGFloat(cos(angle)) * radius
                            let y = center.y + CGFloat(sin(angle)) * radius
                            Image(systemName: "star.fill")
                                .font(.system(size: size * 0.10))
                                .foregroundStyle(.yellow)
                                .position(x: x, y: y)
                        }
                    }
                }
                .frame(height: 28)

                if let text = plateTemplate.stripeText {
                    Text(text)
                        .font(.caption2.weight(.bold))
                        .foregroundStyle(.white)
                }
            }
            .padding(.vertical, 6)
        }
    }
}

#Preview {
    SettingsLicensePlateView(
        vehiclePlate: .constant("OCU123"),
        plateTemplate: .constant(.american),
        plateSize: .constant(.standard),
        plateTextColor: .constant(.black),
        plateBackgroundColor: .constant(.white),
        plateBorderColor: .constant(Color(.systemGray3)),
        plateBorderWidth: .constant(2)
    )
}
