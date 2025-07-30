//
//  DetailCardViewModel.swift
//  Konglish
//
//  Created by Apple MacBook on 7/24/25.
//

import Foundation
import AVFoundation
import Speech
import SwiftData

@Observable
class DetailCardViewModel: NSObject {
    // MARK: - 모델 상태
    var word: CardModel?
    var accuracyType: AccuracyType = .failure
    var isBossCard: Bool = false
    var heart: Int = 3
    var currentScore: Int = 0
    
    // MARK: - 발음 결과 저장용
    var lastEvaluatedScore: Int? = nil
    var lastPassed: Bool = false
    
    // MARK: - 음성 레벨
    var voiceLevel: Float = 0.0
    
    // MARK: - 음성 합성 (TTS)
    let speechSynthesizer = AVSpeechSynthesizer()
    
    func speakWord() {
        guard let word = word?.wordEng else {
            print("발음할 단어 없음")
            return
        }
        
        let utterance = AVSpeechUtterance(string: word)
        utterance.voice = AVSpeechSynthesisVoice(language: "en-US")
        utterance.rate = 1.0
        utterance.pitchMultiplier = 1.1
        speechSynthesizer.speak(utterance)
    }
    
    // MARK: - 발음 평가
    private let speechRecognizer = SFSpeechRecognizer(locale: Locale(identifier: "en-US"))
    private let audioEngine = AVAudioEngine()
    private var recognitionRequest: SFSpeechAudioBufferRecognitionRequest?
    private var recognitionTask: SFSpeechRecognitionTask?
    var recordingState: RecordingState = .idle
    var isRecording: Bool { recordingState == .recording }

    // 오디오 관련 속성
    var recognitionRequest: SFSpeechAudioBufferRecognitionRequest?
    var recognitionTask: SFSpeechRecognitionTask?
    let audioEngine = AVAudioEngine()
    let speechRecognizer = SFSpeechRecognizer()

    // 마이크 레벨 표시용
    var voiceLevel: Float = 0.0

    // 단어
    var word: CardModel?

    // MARK: - 버튼 눌렀을 때 동작
    func toggleRecording() {
        switch recordingState {
        case .idle:
            startRecording()
        case .recording:
            Task {
                await stopAndEvaluate()
            }
        case .evaluating:
            // 평가 중이면 무시
            break
        }
    }

    // MARK: - 녹음 시작
    private func startRecording() {
        cleanupAudio()

        SFSpeechRecognizer.requestAuthorization { status in
            guard status == .authorized else {
                print("Speech recognition not authorized")
                return
            }

            DispatchQueue.main.async {
                do {
                    let session = AVAudioSession.sharedInstance()
                    try session.setCategory(.record, mode: .measurement, options: .duckOthers)
                    try session.setActive(true, options: .notifyOthersOnDeactivation)
                } catch {
                    print("AVAudioSession 설정 실패: \(error)")
                    return
                }

                self.recognitionRequest = SFSpeechAudioBufferRecognitionRequest()
                self.recognitionRequest?.shouldReportPartialResults = true

                guard let request = self.recognitionRequest else { return }

                let inputNode = self.audioEngine.inputNode
                let format = inputNode.inputFormat(forBus: 0)

                inputNode.removeTap(onBus: 0)
                inputNode.installTap(onBus: 0, bufferSize: 1024, format: format) { buffer, _ in
                    request.append(buffer)
                    self.updateVoiceLevel(from: buffer)
                }

                self.recognitionTask = self.speechRecognizer?.recognitionTask(with: request) { _, _ in }

                do {
                    try self.audioEngine.start()
                    self.recordingState = .recording
                } catch {
                    print("audioEngine start 실패: \(error)")
                }
            }
        }
    }

    // MARK: - 녹음 멈추고 평가
    private func stopAndEvaluate() async {
        recordingState = .evaluating

        audioEngine.stop()
        audioEngine.inputNode.removeTap(onBus: 0)
        recognitionRequest?.endAudio()

        guard let task = recognitionTask else { return }

        await withCheckedContinuation { continuation in
            var didFinish = false

            recognitionTask = speechRecognizer?.recognitionTask(with: recognitionRequest!) { result, error in
                if didFinish { return }

                if let result = result, result.isFinal {
                    let spokenRaw = result.bestTranscription.formattedString
                    let spoken = self.normalize(spokenRaw)
                    let target = self.normalize(self.word?.wordEng ?? "")
                    let score = self.calculateSimilarityScore(spoken: spoken, target: target)

                    print("🎤 인식 결과: \(spokenRaw)")
                    print("📊 점수: \(Int(score * 100))")

                    self.evaluatePronunciation(scorePercent: Int(score * 100))

                    didFinish = true
                    self.cleanupAudio()
                    self.recordingState = .idle
                    continuation.resume()
                }

                if let error = error {
                    print("인식 에러: \(error.localizedDescription)")
                    didFinish = true
                    self.evaluatePronunciation(scorePercent: 0)
                    self.cleanupAudio()
                    self.recordingState = .idle
                    continuation.resume()
                }
            }
        }
    }

    // MARK: - 오디오 초기화
    private func cleanupAudio() {
        recognitionTask?.cancel()
        recognitionTask = nil
        recognitionRequest = nil

        if audioEngine.isRunning {
            audioEngine.stop()
        }

        audioEngine.inputNode.removeTap(onBus: 0)
    }

    private func updateVoiceLevel(from buffer: AVAudioPCMBuffer) {
        guard let channelData = buffer.floatChannelData?[0] else { return }
        let array = Array(UnsafeBufferPointer(start: channelData, count: Int(buffer.frameLength)))
        let rms = sqrt(array.map { $0 * $0 }.reduce(0, +) / Float(buffer.frameLength))
        let power = 20 * log10(rms)
        let normalized = max(0, min(1, (power + 50) / 50))

        DispatchQueue.main.async {
            self.voiceLevel = normalized
        }
    }

    private func normalize(_ string: String) -> String {
        string.lowercased().trimmingCharacters(in: .whitespacesAndNewlines)
    }

    private func calculateSimilarityScore(spoken: String, target: String) -> Float {
        // 간단한 예: Levenshtein 거리로 유사도 계산
        return spoken == target ? 1.0 : 0.0
    }

    private func evaluatePronunciation(scorePercent: Int) {
        // 평가 결과 처리
        print("결과 점수: \(scorePercent)")
    }
}


enum RecordingState {
    case idle
    case recording
    case evaluating
}
