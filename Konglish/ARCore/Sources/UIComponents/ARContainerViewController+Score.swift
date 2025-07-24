//
//  ARContainerViewController+Score.swift
//  ARCore
//
//  Created by 임영택 on 7/23/25.
//

import Foundation

extension ARContainerViewController {
    /// 특정 단어에 대한 발음 정확도 점수를 제출한다
    public func submitAccuracy(wordId: UUID, accuracy: Float) throws {
        let gameCard = gameSettings.gameCards.first { $0.id == wordId }
        guard let gameCard = gameCard else {
            throw ARCoreError.cardNotFound
        }
        
        // 실패한 경우 라이프 카운트 1 감소
        if !isPassed(accuracy: accuracy) {
            reaminLifeCounts -= 1
        }
        
        // 프로퍼티 업데이트
        gameCardToAccuracy[gameCard] = accuracy
        
        // 대리자 호출
        delegate?.didChangeScore(self)
        
        // 모두 완료한 경우 완료 상태로 게임 페이즈 변경
        if numberOfFinishedCards == gameSettings.gameCards.count {
            gamePhase = .fisished
        }
    }
    
    /// 정확도 점수에 따른 점수를 계산한다
    func calcualteScore(gameCard: GameCard, accuracy: Float) -> Int {
        let isBoss = false // TODO: 추후 GameCard에 보스 여부 프로퍼티 추가 후 변경 필요
        let baseScore = isBoss ? 300 : 100
        
        switch accuracy {
        case 1.0: return baseScore * 10
        case 0.9..<1.0: return baseScore * 5
        case 0.7..<0.9: return baseScore * 3
        case 0.6..<0.7: return baseScore * 2
        default: return baseScore
        }
    }
    
    /// 정확도 점수에 따른 통과, 미통과 여부를 결정한다
    func isPassed(accuracy: Float) -> Bool {
        accuracy >= 0.4
    }
}
