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

    func startPronunciationEvaluation() async {
        let target = word?.wordEng.lowercased() ?? ""

        await withCheckedContinuation { continuation in
            SFSpeechRecognizer.requestAuthorization { authStatus in
                guard authStatus == .authorized else {
                    continuation.resume()
                    return
                }

                DispatchQueue.main.async {
                    self.recognitionRequest = SFSpeechAudioBufferRecognitionRequest()
                    self.recognitionRequest?.shouldReportPartialResults = false // 중요!
                    let inputNode = self.audioEngine.inputNode

                    guard let request = self.recognitionRequest else {
                        continuation.resume()
                        return
                    }

                    var didFinish = false

                    self.recognitionTask = self.speechRecognizer?.recognitionTask(with: request) { result, error in
                        if didFinish { return }

                        if let result = result, result.isFinal {
                            let spoken = result.bestTranscription.formattedString.lowercased()
                            let similarity = self.calculateSimilarityScore(spoken: spoken, target: target)
                            let percent = Int(similarity * 100)

                            self.evaluatePronunciation(scorePercent: percent)

                            didFinish = true
                            self.cleanupAudio()
                            continuation.resume()
                        }

                        if let error = error {
                            print("Speech Recognition Error: \(error.localizedDescription)")
                            didFinish = true
                            self.cleanupAudio()
                            continuation.resume()
                        }
                    }

                    let inputNode = audioEngine.inputNode
                    inputNode.removeTap(onBus: 0)

                    let format = inputNode.inputFormat(forBus: 0)

                    inputNode.installTap(onBus: 0, bufferSize: 1024, format: format) { buffer, _ in
                        self.recognitionRequest?.append(buffer)

                        guard let channelData = buffer.floatChannelData?[0] else { return }
                        let channelDataArray = Array(UnsafeBufferPointer(start: channelData, count: Int(buffer.frameLength)))
                        let rms = sqrt(channelDataArray.map { $0 * $0 }.reduce(0, +) / Float(buffer.frameLength))
                        let avgPower = 20 * log10(rms)
                        let normalizedPower = max(0, min(1, (avgPower + 50) / 50))

                        DispatchQueue.main.async {
                            self.voiceLevel = normalizedPower
                        }
                    }

                    try? self.audioEngine.start()

                    DispatchQueue.main.asyncAfter(deadline: .now() + 3.0) {
                        if !didFinish {
                            print("Timeout - No speech detected")
                            didFinish = true
                            self.evaluatePronunciation(scorePercent: 0)
                            self.cleanupAudio()
                            continuation.resume()
                        }
                    }
                }
            }
        }
    }
    
    private func cleanupAudio() {
        audioEngine.stop()
        audioEngine.inputNode.removeTap(onBus: 0)
        recognitionRequest = nil
        recognitionTask = nil
        voiceLevel = 0
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
}
