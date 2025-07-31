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
    var speechRecognitionAvaliable: Bool = false
    var recognitionRequest: SFSpeechAudioBufferRecognitionRequest?
    var recognitionTask: SFSpeechRecognitionTask?
    let audioEngine = AVAudioEngine()
    let speechRecognizer = SFSpeechRecognizer()!
    
    override init() {
        super.init()
        checkAuthorizationStatus()
        setAudioSession()
    }
    
    // MARK: - STT 권한
    private func checkAuthorizationStatus() {
        SFSpeechRecognizer.requestAuthorization { authStatus in
            Task { @MainActor in
                switch authStatus {
                case .authorized:
                    self.speechRecognitionAvaliable = true
                    print("Speech recognition avaliable")
                case .denied:
                    self.speechRecognitionAvaliable = false
                    print("user denied access to speech recognition")
                case .restricted:
                    self.speechRecognitionAvaliable = false
                    print("Speech recognition restricted on this device")
                case .notDetermined:
                    self.speechRecognitionAvaliable = false
                    print("Speech recognition not yet authorized")
                default:
                    self.speechRecognitionAvaliable = false
                }
            }
        }
    }
    
    // MARK: - 오디오 세션 세팅
    private func setAudioSession() {
        // Configure the audio session for the app.
        let audioSession = AVAudioSession.sharedInstance()
        
        do {
            try audioSession.setCategory(.playAndRecord, mode: .measurement, options: .duckOthers)
            try audioSession.setActive(true, options: .notifyOthersOnDeactivation)
        } catch {
            print("error setting up audio session: \(error)")
        }
    }

    // MARK: - 녹음 시작
    func startRecording() {
        guard speechRecognitionAvaliable else {
            print("speech recognition is not available...")
            return
        }
        
        cleanupAudio()
        
        let inputNode = audioEngine.inputNode

        // Create and configure the speech recognition request.
        recognitionRequest = SFSpeechAudioBufferRecognitionRequest()
        guard let recognitionRequest = recognitionRequest else { fatalError("Unable to created a SFSpeechAudioBufferRecognitionRequest object") }
        recognitionRequest.shouldReportPartialResults = true
        
        // Create a recognition task for the speech recognition session.
        // Keep a reference to the task so that it can be canceled.
        recognitionTask = speechRecognizer.recognitionTask(with: recognitionRequest) { result, error in
            if let result = result {
                print("👂 \(result.bestTranscription.formattedString)")

                if result.isFinal {
                    if let lastSegment = result.bestTranscription.segments.last {
                        let lastSpokenWord = self.normalizeWord(lastSegment.substring)
                        let score = lastSegment.confidence
                        let targetWord = self.normalizeWord(self.word?.wordEng ?? "")
                        
                        if lastSpokenWord == targetWord {
                            print("인식 성공 \(lastSpokenWord)")
                            print("🎤 인식 결과: \(lastSpokenWord)")
                            print("📊 점수: \(Int(score * 100))")
                            self.evaluate(scorePercent: Int(score * 100))
                            self.accuracyPercent = Int(score * 100)
                        } else {
                            let similarityScore = self.evaluateSimilarityScore(lastSpokenWord, targetWord)
                            print("인식 실패 target=\(targetWord) spoken=\(lastSpokenWord) similarityScore=\(similarityScore)")
                            self.evaluate(scorePercent: Int(similarityScore * 100))
                            self.accuracyPercent = Int(similarityScore * 100)
                        }
                    } else {
                        print("no lastSegment")
                    }
                    
                    self.cleanupAudio()
                    self.recordingState = .idle
                }
            }
            
            if error != nil {
                print("error during speech recognition: \(error!)")
                
                if let error = error as? NSError,
                   error.domain == "kAFAssistantErrorDomain" && error.code == 1110 {
                    print("👂🏻 음성이 감지되지 않았습니다.")
                    self.evaluate(scorePercent: 0)
                }
                
                self.cleanupAudio()
                self.recordingState = .idle
            }
        }
        
        // Configure the microphone input.
        let recordingFormat = inputNode.outputFormat(forBus: 0)
        inputNode.installTap(onBus: 0, bufferSize: 1024, format: recordingFormat) { (buffer: AVAudioPCMBuffer, when: AVAudioTime) in
            self.recognitionRequest?.append(buffer)
            self.updateVoiceLevel(from: buffer)
        }
        
        audioEngine.prepare()
        
        do {
            try audioEngine.start()
            self.recordingState = .recording
        } catch {
            print("error starting audio engine: \(error)")
        }
    }

    // MARK: - 녹음 중단
    func stopRecording() {
        guard recordingState == .recording else {
            print("중단 못해씀")
            return
        }
        
        audioEngine.stop()
        recognitionRequest?.endAudio()
        
        recordingState = .readyToEvaluate
    }
    
    /// 인식 컨피던스를 바탕으로 점수를 업데이트한다.
    private func evaluate(scorePercent: Int) {
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

    private func normalizeWord(_ string: String) -> String {
        string.lowercased().trimmingCharacters(in: .whitespacesAndNewlines)
    }
    
    /// 두 문자열 사이 [Levenshtein distance](https://en.wikipedia.org/wiki/Levenshtein_distance)를 계산한다.
    private func levenshtein(_ s: String, _ t: String) -> Int {
        let sChars = Array(s)
        let tChars = Array(t)
        let m = sChars.count
        let n = tChars.count

        var dist = [[Int]](repeating: [Int](repeating: 0, count: n + 1), count: m + 1)

        for i in 0...m { dist[i][0] = i }
        for j in 0...n { dist[0][j] = j }

        for i in 1...m {
            for j in 1...n {
                if sChars[i - 1] == tChars[j - 1] {
                    dist[i][j] = dist[i - 1][j - 1]
                } else {
                    dist[i][j] = min(dist[i - 1][j], dist[i][j - 1], dist[i - 1][j - 1]) + 1
                }
            }
        }

        return dist[m][n]
    }

    /// 인식된 단어가 타겟 단어와 다른 경우 유사도를 기반으로 점수를 결정한다
    private func evaluateSimilarityScore(_ a: String, _ b: String) -> Double {
        let distance = Double(levenshtein(a, b))
        let maxLength = Double(max(a.count, b.count))
        return max(0, 1.0 - (distance / maxLength)) // 0.0 ~ 1.0
    }
}


enum RecordingState {
    case idle              // 녹음 안함
    case recording         // 녹음 중
    case readyToEvaluate   // 녹음 중단 후 평가 대기
    case evaluating        // 평가 중
}
