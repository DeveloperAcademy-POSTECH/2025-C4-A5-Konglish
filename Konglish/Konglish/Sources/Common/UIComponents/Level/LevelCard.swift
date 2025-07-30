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
    let num : LevelType
    let action: () -> Void
    
    @Binding var isTapped: Bool
    
    // MARK: - LevelCardConstants
    fileprivate enum LevelCardConstants {
        static let bgWidth: CGFloat = 280
        static let bgHeight: CGFloat = 380
        static let cornerRadius: CGFloat = 30
        static let middleVspacing: CGFloat = 30
        static let lelvelNumHeight: CGFloat = 116
        static let lelvelNumWidth: CGFloat = 172
        static let contentsWiddth: CGFloat = 232
        static let contentsHeight: CGFloat = 316
        static let pointHspacing: CGFloat = 10
        static let binWidth: CGFloat = 34
        static let binHeight: CGFloat = 28
        static let bestScoreText: String = "BestScore"
        static let noScoreText: String = "NoScore"
        static let progressText: String = "학습 진행도"
    }
    
    // MARK: - Body
    var body: some View {
        Button(action: {
            isTapped.toggle()
            action()
        }, label: {
            ZStack {
                RoundedRectangle(cornerRadius: LevelCardConstants.cornerRadius)
                    .fill(isTapped ? num.backgroundColor : .white)
                    .stroke(isTapped ? num.buttonStrokeColor : .clear, style: .init(lineWidth: 4))
                    .frame(width: LevelCardConstants.bgWidth, height: LevelCardConstants.bgHeight)
                contents
            }
        })
    }
    
    private var contents: some View {
        VStack {
            topNumber
            Spacer()
            bestScore
            Spacer()
            bottomProgress
        }
        .frame(width: LevelCardConstants.contentsWiddth)
        .frame(height: LevelCardConstants.contentsHeight)
    }
    
    // MARK: - TopContents
    /// 상단 레벨 숫자 넘버
    private var topNumber: some View {
        ZStack {
            RoundedRectangle(cornerRadius: LevelCardConstants.cornerRadius)
                .fill(num.color)
                .frame(width: LevelCardConstants.lelvelNumWidth, height: LevelCardConstants.lelvelNumHeight)
            
            Text(num.rawValue)
                .font(.semibold36)
                .foregroundStyle(num.fontColor)
        }
    }
    
    // MARK: - MiddleContents
    /// 중간 스코어 표시
    @ViewBuilder
    private var bestScore: some View {
        if level.bestScore > .zero {
            VStack(alignment: .center, spacing: LevelCardConstants.middleVspacing, content: {
                Text(LevelCardConstants.bestScoreText)
                    .font(.semibold32)
                
                pointHstack
            })
            .foregroundStyle(Color.gray03)
        } else {
            Text(LevelCardConstants.noScoreText)
                .font(.semibold32)
                .foregroundStyle(Color.gray04)
        }
    }
    
    private var pointHstack: some View {
        HStack(spacing: LevelCardConstants.pointHspacing, content: {
            Image(.bin)
                .resizable()
                .aspectRatio(contentMode: .fit)
                .frame(width: LevelCardConstants.binWidth, height: LevelCardConstants.binHeight)
        })
    }
    
    private var bottomProgress: some View {
        VStack {
            Text(LevelCardConstants.progressText)
                .font(.bold16)
            
            SuccessProgress(currentCount: level.successCount)
        }
    }
}

#Preview {
    LevelCard(level: .init(levelNumber: .easy, category: .init(imageName: "11", difficulty: 1, nameKor: "2", nameEng: "3")), num: .easy, action: {
        print("hello")
    }, isTapped: .constant(true))
}
