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
        static let bgHeight: CGFloat = 388
        static let cornerRadius: CGFloat = 40
        static let middleVspacing: CGFloat = 30
        static let levelNumHeight: CGFloat = 116
        static let levelNumWidth: CGFloat = 172
        static let contentsWiddth: CGFloat = 232
        static let contentsHeight: CGFloat = 316
        static let pointHspacing: CGFloat = 10
        static let binWidth: CGFloat = 34
        static let binHeight: CGFloat = 28
        static let bestScoreText: String = "Best Score"
        static let noScoreText: String = "No Score"
        static let progressText: String = "단어 수집 진행도"
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
                    .grayShadow(if: isTapped ? false : true)
                contents
            }
        })
    }
    
    private var contents: some View {
        VStack {
            levelBox
            Spacer()
            bestScore
            Spacer()
            bottomProgress
        }
        .frame(width: LevelCardConstants.contentsWiddth)
        .frame(height: LevelCardConstants.contentsHeight)
    }
    
    // MARK: - TopContents
    /// 레벨 표시 박스 (Easy, Normal, Hard)
    private var levelBox: some View {
        ZStack {
            RoundedRectangle(cornerRadius: LevelCardConstants.cornerRadius)
                .fill(num.color)
                .frame(width: LevelCardConstants.levelNumWidth, height: LevelCardConstants.levelNumHeight)
            
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
            
            Text("\(level.bestScore)")
                .font(.bold32)
        })
    }
    
    private var bottomProgress: some View {
        VStack {
            Text(LevelCardConstants.progressText)
                .font(.bold16)
                .foregroundStyle(Color(#colorLiteral(red: 0, green: 0, blue: 0, alpha: 0.2)))
            
            SuccessProgress(currentCount: level.successCount)
        }
    }
}

#Preview {
    LevelCard(level: .init(levelNumber: .easy, category: .init(imageName: "11", nameKor: "2", nameEng: "3")), num: .easy, action: {
        print("hello")
    }, isTapped: .constant(true))
}
