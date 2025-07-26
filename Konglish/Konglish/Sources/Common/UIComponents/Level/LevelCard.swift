//
//  LevelCard.swift
//  Konglish
//
//  Created by Apple MacBook on 7/22/25.
//

import SwiftUI

struct LevelCard: View {
    // MARK: - Property
    let level: LevelModel
    let num: Int
    let action: () -> Void
    
    // MARK: - LevelCardConstants
    fileprivate enum LevelCardConstants {
        static let middleVspacing: CGFloat = 30
        static let lelvelNumSize: CGFloat = 144
        static let contentsWiddth: CGFloat = 232
        static let contentsHeight: CGFloat = 362
        static let bestScoreText: String = "BestScore"
        static let noScoreText: String = "NoScore"
    }
    
    // MARK: - Init
    init(level: LevelModel, num: Int, action: @escaping () -> Void) {
        self.level = level
        self.num = num
        self.action = action
    }
    
    // MARK: - Body
    var body: some View {
        ButtonCard(content: {
            contents
        }, action: {
            action()
        })
    }
    
    private var contents: some View {
        VStack {
            topNumber
            Spacer()
            bestScore
            Spacer()
            SuccessProgress(currentCount: level.successCount)
        }
        .frame(width: LevelCardConstants.contentsWiddth)
        .frame(height: LevelCardConstants.contentsHeight)
    }
    
    // MARK: - TopContents
    /// 상단 레벨 숫자 넘버
    private var topNumber: some View {
        ZStack {
            Circle()
                .fill(.levelBg)
                .frame(width: LevelCardConstants.lelvelNumSize, height: LevelCardConstants.lelvelNumSize)
            
            Text("\(num)")
                .font(.bold80)
                .foregroundStyle(Color.secondary01)
        }
    }
    
    // MARK: - MiddleContents
    /// 중간 스코어 표시
    @ViewBuilder
    private var bestScore: some View {
        if level.bestScore > .zero {
            VStack(alignment: .center, spacing: LevelCardConstants.middleVspacing, content: {
                Text(LevelCardConstants.bestScoreText)
                    .font(.semibold64)
                Text("\(level.bestScore)")
                    .font(.bold32)
            })
            .foregroundStyle(Color.gray03)
        } else {
            Text(LevelCardConstants.noScoreText)
                .font(.semibold32)
                .foregroundStyle(Color.gray03)
        }
    }
    
    // MARK: - BottomArea
    private var bottomArea: some View {
        ZStack {
            
        }
    }
}

#Preview {
    LevelCard(level: .init(levelNumber: 2, category: .init(imageName: "11", difficulty: 2, nameKor: "1", nameEng: "1")), num: 2, action: {
        print("hello")
    })
}
