//
//  QRCodeScannerView.swift
//  Ocula
//
//  Created by Tyson Miles on 4/2/2026.
//

import SwiftUI
import AVFoundation
import UIKit

struct QRScannerContainerView: View {
    @Environment(\.dismiss) private var dismiss
    let onCode: (String) -> Void

    @State private var authorizationStatus = AVCaptureDevice.authorizationStatus(for: .video)

    var body: some View {
        ZStack {
            switch authorizationStatus {
            case .authorized:
                QRScannerView { code in
                    onCode(code)
                    dismiss()
                }
                .ignoresSafeArea()
            case .notDetermined:
                ProgressView("Requesting Camera Access...")
                    .task {
                        let granted = await AVCaptureDevice.requestAccess(for: .video)
                        authorizationStatus = granted ? .authorized : .denied
                    }
            case .denied, .restricted:
                VStack(spacing: 16) {
                    Text("Camera Access Needed")
                        .headlineStyle()
                    Text("Enable camera access in Settings to scan your device QR code.")
                        .captionStyle()
                        .multilineTextAlignment(.center)

                    Button("Open Settings") {
                        guard let url = URL(string: UIApplication.openSettingsURLString) else { return }
                        UIApplication.shared.open(url)
                    }
                    .buttonStyle(PrimaryButtonStyle())
                }
                .padding()
            @unknown default:
                Text("Unable to access camera.")
                    .captionStyle()
            }
        }
    }
}

struct QRScannerView: UIViewRepresentable {
    let onCode: (String) -> Void

    func makeUIView(context: Context) -> UIView {
        let view = UIView(frame: .zero)
        context.coordinator.configureSession(in: view)
        return view
    }

    func updateUIView(_ uiView: UIView, context: Context) {
        context.coordinator.previewLayer?.frame = uiView.bounds
    }

    func makeCoordinator() -> Coordinator {
        Coordinator(onCode: onCode)
    }

    final class Coordinator: NSObject, AVCaptureMetadataOutputObjectsDelegate {
        private let onCode: (String) -> Void
        private let session = AVCaptureSession()
        var previewLayer: AVCaptureVideoPreviewLayer?
        private var didCaptureCode = false

        init(onCode: @escaping (String) -> Void) {
            self.onCode = onCode
        }

        func configureSession(in view: UIView) {
            guard let device = AVCaptureDevice.default(for: .video) else { return }

            do {
                let input = try AVCaptureDeviceInput(device: device)
                if session.canAddInput(input) {
                    session.addInput(input)
                }

                let output = AVCaptureMetadataOutput()
                if session.canAddOutput(output) {
                    session.addOutput(output)
                    output.setMetadataObjectsDelegate(self, queue: DispatchQueue.main)
                    output.metadataObjectTypes = [.qr]
                }

                let previewLayer = AVCaptureVideoPreviewLayer(session: session)
                previewLayer.videoGravity = .resizeAspectFill
                previewLayer.frame = view.layer.bounds
                view.layer.addSublayer(previewLayer)
                self.previewLayer = previewLayer

                session.startRunning()
            } catch {
                return
            }
        }

        func metadataOutput(_ output: AVCaptureMetadataOutput,
                            didOutput metadataObjects: [AVMetadataObject],
                            from connection: AVCaptureConnection) {
            guard !didCaptureCode,
                  let object = metadataObjects.first as? AVMetadataMachineReadableCodeObject,
                  object.type == .qr,
                  let stringValue = object.stringValue else { return }

            didCaptureCode = true
            session.stopRunning()
            onCode(stringValue)
        }
    }
}
