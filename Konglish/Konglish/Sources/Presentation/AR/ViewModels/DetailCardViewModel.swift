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
    var accuracyType: AccuracyType = .btnMic
    var isBossCard: Bool = false
    var heart: Int = 5
    var currentScore: Int = 0
    var accuracyPercent: Int = 0
    
    // MARK: - 발음 결과 저장용
    var lastEvaluatedScore: Int? = nil
    var lastPassed: Bool = false
    
    // MARK: - 음성 레벨
    var voiceLevel: Float = 0.0
    
    // MARK: - 음성 합성 (TTS)
    let speechSynthesizer = AVSpeechSynthesizer()
    
    var finishedCards: Set<CardModel> = []
    
    func speakWord() {
        guard let word = word?.wordEng else {
            print("발음할 단어 없음")
            return
        }
        
        let utterance = AVSpeechUtterance(string: word)
        utterance.voice = AVSpeechSynthesisVoice(language: "en-US")
        utterance.rate = 0.5
        utterance.pitchMultiplier = 1.1
        speechSynthesizer.speak(utterance)
    }
    // MARK: - 상태
    var recordingState: RecordingState = .idle

    // MARK: - 오디오
    var recognitionRequest: SFSpeechAudioBufferRecognitionRequest?
    var recognitionTask: SFSpeechRecognitionTask?
    let audioEngine = AVAudioEngine()
    let speechRecognizer = SFSpeechRecognizer()

    // MARK: - 녹음 시작
    func startRecording() {
        cleanupAudio()

        SFSpeechRecognizer.requestAuthorization { status in
            guard status == .authorized else {
                print("권한 없음")
                return
            }

            DispatchQueue.main.async {
                do {
                    let session = AVAudioSession.sharedInstance()
                    try session.setCategory(.playAndRecord, mode: .default, options: [.defaultToSpeaker, .allowBluetooth])
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
                    print("녹음 시작 실패: \(error)")
                }
            }
        }
    }

    // MARK: - 녹음 중단
    func stopRecording() {
        guard recordingState == .recording else {
            print("중단 못해씀")
            return
        }
        audioEngine.stop()
        audioEngine.inputNode.removeTap(onBus: 0)
        recognitionRequest?.endAudio()
        recordingState = .readyToEvaluate
    }

    // MARK: - 평가 실행 (클로저 방식)
    func evaluate() {
        guard recordingState == .readyToEvaluate else { return }

        recordingState = .evaluating

        var didFinish = false

        self.recognitionTask = self.speechRecognizer?.recognitionTask(with: self.recognitionRequest!) { result, error in
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
            }

            if let error = error {
                print("인식 오류: \(error.localizedDescription)")
                didFinish = true
                self.evaluatePronunciation(scorePercent: 0)
                self.cleanupAudio()
                self.recordingState = .idle
            }
        }
    }
    
    /// 우선 시연을 위해 랜덤 점수를 반환한다.
    func evaluateStub() { // TODO: 음성 인식 고친 후 삭제 필요
        self.cleanupAudio()
        self.recordingState = .idle
        
        self.accuracyPercent = Int.random(in: 60..<100)
        switch accuracyPercent {
        case 100:
            updateScore(base: 5)
        case 90..<100:
            updateScore(base: 4)
        case 80..<90:
            updateScore(base: 3)
        case 70..<80:
            updateScore(base: 2)
        case 60..<70:
            updateScore(base: 1)
        default:
            print("발음 실패, 하트 -1")
            heart = max(0, heart - 1)
            accuracyType = .failure
            lastPassed = false
            lastEvaluatedScore = nil
        }
        
        if let word = word {
            finishedCards.insert(word)
        }
    }
    
    private func updateScore(base: Int) {
        let finalScore = isBossCard ? base * 3 : base
        currentScore += finalScore
        lastEvaluatedScore = finalScore
        lastPassed = true
        accuracyType = .success
        print("점수 획득: \(finalScore)점 \(isBossCard ? "(보스 ×3)" : "")")
    }

    // MARK: - 정리
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
        return spoken == target ? 1.0 : 0.0
    }
    
    private func evaluatePronunciation(scorePercent: Int) {
           print("💯 최종 점수: \(scorePercent)")
       }
}


enum RecordingState {
    case idle              // 녹음 안함
    case recording         // 녹음 중
    case readyToEvaluate   // 녹음 중단 후 평가 대기
    case evaluating        // 평가 중
}
