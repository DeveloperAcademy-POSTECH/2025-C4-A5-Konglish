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
    var accuracyPercent: Int = 0
    
    // MARK: - 발음 결과 저장용
    var lastPassed: Bool = false
    
    // MARK: - 음성 합성 (TTS)
    let speechSynthesizer = AVSpeechSynthesizer()
    
    // MARK: - 무음 감지 관련 프로퍼티
    private let silenceThreshold: Float = -45.0 // 45db 이하면 무음으로 친다
    private let watingTime: TimeInterval = 2.5 // 무음 판정을 위해 대기할 시간
    private var lastSpokenTime: Date?
    
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
        
        accuracyType = .recording
        
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
                        
                        let similarityScore = self.evaluateSimilarityScore(lastSpokenWord, targetWord)
                        
                        if lastSpokenWord == targetWord {
                            // 완전 일치여도 confidence가 65% 이상이어야 성공
                            let confidenceScore = Int(score * 100)
                            self.accuracyPercent = confidenceScore
                            
                            if score >= 0.65 {
                                print("인식 결과: \(lastSpokenWord)")
                                print("신뢰도: \(confidenceScore)%")
                                self.lastPassed = true
                            } else {
                                print("신뢰도: \(confidenceScore)% (65% 미만)")
                            }
                        } else if similarityScore >= 0.6 {
                            // 60% 이상 유사도면 성공
                            self.accuracyPercent = Int(similarityScore * 100)
                            print("유사도 성공! target=\(targetWord) spoken=\(lastSpokenWord)")
                            print("유사도 점수: \(Int(similarityScore * 100))%")
                            self.lastPassed = true
                        } else {
                            // 60% 미만이면 실패
                            self.accuracyPercent = Int(similarityScore * 100)
                            print("인식 실패! target=\(targetWord) spoken=\(lastSpokenWord)")
                            print("유사도 점수: \(Int(similarityScore * 100))%")
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
                    self.accuracyPercent = 0
                }
                
                self.cleanupAudio()
                self.recordingState = .idle
            }
        }
        
        // Configure the microphone input.
        let recordingFormat = inputNode.outputFormat(forBus: 0)
        inputNode.installTap(onBus: 0, bufferSize: 1024, format: recordingFormat) { (buffer: AVAudioPCMBuffer, when: AVAudioTime) in
            self.recognitionRequest?.append(buffer)
            
            // MARK: 무음 감지
            // 음성 레벨 측정
            let channelData = buffer.floatChannelData?[0]
            let channelDataValueArray = stride(from: 0,
                                               to: Int(buffer.frameLength),
                                               by: buffer.stride).map { channelData?[$0] ?? 0 }

            // RMS 계산
            let rms = sqrt(channelDataValueArray.map { $0 * $0 }.reduce(0, +) / Float(buffer.frameLength))
            let avgPower = 20 * log10(rms)
            print("avgPower: \(avgPower)")

            if avgPower > self.silenceThreshold {
                // 말한 것으로 판단 → 마지막 발화 시점 업데이트
                self.lastSpokenTime = Date()
            }
            
            // 아직 lastSpokenTime이 nil이면 지금으로 설정
            if self.lastSpokenTime == nil {
                self.lastSpokenTime = Date()
            }

            // 무음 시간 체크
            if let lastSpokenTime = self.lastSpokenTime {
                let silenceDuration = Date().timeIntervalSince(lastSpokenTime)
                if silenceDuration > self.watingTime {
                    DispatchQueue.main.async { [weak self] in
                        self?.stopRecording()
                    }
                }
            }
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
        
        accuracyType = .btnMic
        
        audioEngine.stop()
        recognitionRequest?.endAudio()
        
        recordingState = .readyToEvaluate
        
        lastSpokenTime = nil // 레코딩 중지 시 마지막 발화 시간 초기화
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
