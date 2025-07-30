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
    
    // 기존 변수들과 녹음 관련 설정은 동일
    
    func toggleRecording() {
        switch recordingState {
        case .idle:
            startRecording()
        case .recording:
            Task {
                await stopAndEvaluate()
            }
        case .evaluating:
            break
        }
    }
    
    private func startRecording() {
        SFSpeechRecognizer.requestAuthorization { authStatus in
            guard authStatus == .authorized else { return }
            
            DispatchQueue.main.async {
                do {
                    try AVAudioSession.sharedInstance().setCategory(.record, mode: .measurement, options: .duckOthers)
                    try AVAudioSession.sharedInstance().setActive(true, options: .notifyOthersOnDeactivation)
                } catch {
                    print("오디오 세션 설정 실패: \(error)")
                    return
                }
                
                self.recognitionRequest = SFSpeechAudioBufferRecognitionRequest()
                self.recognitionRequest?.shouldReportPartialResults = true
                
                let inputNode = self.audioEngine.inputNode
                let format = inputNode.inputFormat(forBus: 0)
                
                inputNode.removeTap(onBus: 0)
                inputNode.installTap(onBus: 0, bufferSize: 1024, format: format) { buffer, _ in
                    self.recognitionRequest?.append(buffer)
                    self.updateVoiceLevel(from: buffer)
                }
                
                self.recognitionTask = self.speechRecognizer?.recognitionTask(with: self.recognitionRequest!) { _, _ in }
                try? self.audioEngine.start()
                self.recordingState = .recording
            }
        }
    }
    
    private func stopAndEvaluate() async {
        recordingState = .evaluating

        return await withCheckedContinuation { continuation in
            audioEngine.stop()
            audioEngine.inputNode.removeTap(onBus: 0)
            recognitionRequest?.endAudio()

            var didFinish = false

            recognitionTask = speechRecognizer?.recognitionTask(with: recognitionRequest!) { result, error in
                if didFinish { return }

                if let result = result, result.isFinal {
                    let spokenRaw = result.bestTranscription.formattedString
                    let spoken = self.normalize(spokenRaw)
                    let target = self.normalize(self.word?.wordEng ?? "")
                    let similarity = self.calculateSimilarityScore(spoken: spoken, target: target)
                    let percent = Int(similarity * 100)

                    print("🎤 인식 결과: \(spokenRaw)")
                    print("🧼 정제된 인식 결과: \(spoken)")
                    print("🎯 목표 단어: \(target)")
                    print("📊 유사도 점수: \(percent)")

                    self.evaluatePronunciation(scorePercent: percent)

                    didFinish = true
                    self.cleanupAudio()
                    self.recordingState = .idle
                    continuation.resume()
                }

                if let error = error {
                    print("Recognition Error: \(error.localizedDescription)")
                    didFinish = true
                    self.evaluatePronunciation(scorePercent: 0)
                    self.cleanupAudio()
                    self.recordingState = .idle
                    continuation.resume()
                }
            }
        }
    }
    
    private func updateVoiceLevel(from buffer: AVAudioPCMBuffer) {
        guard let channelData = buffer.floatChannelData?[0] else { return }
        let channelDataArray = Array(UnsafeBufferPointer(start: channelData, count: Int(buffer.frameLength)))
        let rms = sqrt(channelDataArray.map { $0 * $0 }.reduce(0, +) / Float(buffer.frameLength))
        let avgPower = 20 * log10(rms)
        let normalizedPower = max(0, min(1, (avgPower + 50) / 50))
        
        DispatchQueue.main.async {
            self.voiceLevel = normalizedPower
        }
    }
    
    private func cleanupAudio() {
        recognitionTask?.cancel()
        recognitionTask = nil
        recognitionRequest = nil
        audioEngine.stop()
        audioEngine.inputNode.removeTap(onBus: 0)
    }
    
    // MARK: - 점수 평가
    private func evaluatePronunciation(scorePercent: Int) {
        switch scorePercent {
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
    }
    
    private func updateScore(base: Int) {
        let finalScore = isBossCard ? base * 3 : base
        currentScore += finalScore
        lastEvaluatedScore = finalScore
        lastPassed = true
        accuracyType = .success
        print("점수 획득: \(finalScore)점 \(isBossCard ? "(보스 ×3)" : "")")
    }
    
    // MARK: - 문자열 유사도
    private func calculateSimilarityScore(spoken: String, target: String) -> Double {
        let distance = levenshtein(aStr: spoken, bStr: target)
        let maxLength = max(spoken.count, target.count)
        return maxLength == 0 ? 1.0 : 1.0 - Double(distance) / Double(maxLength)
    }
    
    private func levenshtein(aStr: String, bStr: String) -> Int {
        let a = Array(aStr)
        let b = Array(bStr)
        var dist = Array(repeating: Array(repeating: 0, count: b.count + 1), count: a.count + 1)
        
        for i in 0...a.count { dist[i][0] = i }
        for j in 0...b.count { dist[0][j] = j }
        
        for i in 1...a.count {
            for j in 1...b.count {
                if a[i - 1] == b[j - 1] {
                    dist[i][j] = dist[i - 1][j - 1]
                } else {
                    dist[i][j] = min(
                        dist[i - 1][j] + 1,
                        dist[i][j - 1] + 1,
                        dist[i - 1][j - 1] + 1
                    )
                }
            }
        }
        return dist[a.count][b.count]
    }
    
    private func normalize(_ string: String) -> String {
        let lowercased = string.lowercased()
        let trimmed = lowercased.trimmingCharacters(in: .whitespacesAndNewlines)
        let filtered = trimmed.filter { $0.isLetter }
        return filtered
    }
}


enum RecordingState {
    case idle
    case recording
    case evaluating
}
