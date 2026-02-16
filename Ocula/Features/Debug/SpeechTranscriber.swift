//
//  SpeechTranscriber.swift
//  Ocula
//
//  Created by Tyson Miles on 2/15/2026.
//

import AVFoundation
import Speech
import Combine
import SwiftUI

final class SpeechTranscriber: NSObject, ObservableObject {
    @Published var transcript: String = ""
    @Published var isRecording: Bool = false
    @Published var isAvailable: Bool = true
    @Published var authorizationStatus: SFSpeechRecognizerAuthorizationStatus
    @Published var micPermissionGranted: Bool = false
    @Published var errorMessage: String?

    private let audioEngine = AVAudioEngine()
    private let speechRecognizer = SFSpeechRecognizer()
    private var request: SFSpeechAudioBufferRecognitionRequest?
    private var recognitionTask: SFSpeechRecognitionTask?

    override init() {
        authorizationStatus = SFSpeechRecognizer.authorizationStatus()
        super.init()
        speechRecognizer?.delegate = self
        isAvailable = speechRecognizer?.isAvailable ?? false
        micPermissionGranted = AVAudioSession.sharedInstance().recordPermission == .granted
    }

    func toggleRecording() {
        if isRecording {
            stopTranscribing()
        } else {
            startTranscribing()
        }
    }

    func startTranscribing() {
        errorMessage = nil

        if authorizationStatus != .authorized || !micPermissionGranted {
            requestPermissions { [weak self] granted in
                guard let self else { return }
                if granted {
                    self.startTranscribing()
                }
            }
            return
        }

        guard isAvailable else {
            errorMessage = "Speech recognition is unavailable right now."
            return
        }

        if audioEngine.isRunning {
            stopTranscribing()
        }

        request = SFSpeechAudioBufferRecognitionRequest()
        guard let request else { return }
        request.shouldReportPartialResults = true

        let audioSession = AVAudioSession.sharedInstance()
        do {
            try audioSession.setCategory(.record, mode: .measurement, options: .duckOthers)
            try audioSession.setActive(true, options: .notifyOthersOnDeactivation)
        } catch {
            errorMessage = "Unable to start audio session."
            return
        }

        let inputNode = audioEngine.inputNode
        inputNode.removeTap(onBus: 0)
        let recordingFormat = inputNode.outputFormat(forBus: 0)
        inputNode.installTap(onBus: 0, bufferSize: 1024, format: recordingFormat) { [weak self] buffer, _ in
            self?.request?.append(buffer)
        }

        audioEngine.prepare()
        do {
            try audioEngine.start()
        } catch {
            errorMessage = "Unable to start recording."
            return
        }

        isRecording = true

        recognitionTask = speechRecognizer?.recognitionTask(with: request) { [weak self] result, error in
            guard let self else { return }
            if let result {
                DispatchQueue.main.async {
                    self.transcript = result.bestTranscription.formattedString
                }
            }

            if error != nil || (result?.isFinal ?? false) {
                DispatchQueue.main.async {
                    self.stopTranscribing()
                }
            }
        }
    }

    func stopTranscribing() {
        if audioEngine.isRunning {
            audioEngine.stop()
        }
        audioEngine.inputNode.removeTap(onBus: 0)
        request?.endAudio()
        recognitionTask?.cancel()
        recognitionTask = nil
        request = nil
        isRecording = false
    }

    private func requestPermissions(completion: @escaping (Bool) -> Void) {
        SFSpeechRecognizer.requestAuthorization { [weak self] status in
            DispatchQueue.main.async {
                self?.authorizationStatus = status
            }

            guard status == .authorized else {
                DispatchQueue.main.async {
                    self?.errorMessage = "Enable Speech Recognition in Settings to use dictation."
                    completion(false)
                }
                return
            }

            AVAudioSession.sharedInstance().requestRecordPermission { granted in
                DispatchQueue.main.async {
                    self?.micPermissionGranted = granted
                    if !granted {
                        self?.errorMessage = "Enable Microphone access in Settings to use dictation."
                    }
                    completion(granted)
                }
            }
        }
    }
}

extension SpeechTranscriber: SFSpeechRecognizerDelegate {
    func speechRecognizer(_ speechRecognizer: SFSpeechRecognizer, availabilityDidChange available: Bool) {
        DispatchQueue.main.async {
            self.isAvailable = available
        }
    }
}
