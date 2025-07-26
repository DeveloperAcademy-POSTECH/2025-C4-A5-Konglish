//
//  DetailCardViewModel.swift
//  Konglish
//
//  Created by Apple MacBook on 7/24/25.
//

import Foundation
import AVFoundation

@Observable
class DetailCardViewModel: NSObject {
    var accurayType: AccuracyType = .failure
    var word: CardModel? = .init(imageName: "11", pronunciation: "[fragment]", wordKor: "개구리", wordEng: "frog", category: .init(imageName: "", difficulty: 2, nameKor: "1", nameEng: "2"))
    var point: Int? = 40
    
    var audioRecorder: AVAudioRecorder? = nil
    var timer: Timer?
    var level: Float = 0.0
    
    func setupRecoder() {
        let settings: [String: Any] = [
            AVFormatIDKey: Int(kAudioFormatAppleLossless),
            AVSampleRateKey: 44100.0,
            AVNumberOfChannelsKey: 1,
            AVEncoderAudioQualityKey: AVAudioQuality.max.rawValue
        ]
        
        let url = URL(fileURLWithPath: "/dev/null") // 실사용하지 않는 더미 URL
        
        do {
            audioRecorder = try AVAudioRecorder(url: url, settings: settings)
            audioRecorder?.isMeteringEnabled = true
            audioRecorder?.prepareToRecord()
            audioRecorder?.record()
            
            timer = Timer.scheduledTimer(withTimeInterval: 0.1, repeats: true) { _ in
                self.audioRecorder?.updateMeters()
                if let average = self.audioRecorder?.averagePower(forChannel: 0) {
                    let normalizedLevel = self.normalizedLevel(level: average)
                    DispatchQueue.main.async {
                        self.level = normalizedLevel
                    }
                }
            }
        } catch {
            print("녹음실패: \(error.localizedDescription)")
        }
    }
    
    private func normalizedLevel(level: Float) -> Float {
        let level = max(0.2, CGFloat(level) + 60) / 60
        return Float(level)
    }
    
    
}
