//
//  WordDetailCard.swift
//  Konglish
//
//  Created by Apple MacBook on 7/23/25.
//

import SwiftUI

/// 단어 카드 상세 컴포넌트
struct WordDetailCard: View {
    // MARK: - Property
    @Bindable var viewModel: DetailCardViewModel
    
    // MARK: - Constants
    fileprivate enum WordDetailCardConstants {
        static let horizonPadding: CGFloat = 40
        static let cornerRadius: CGFloat = 30
        static let safePadding: CGFloat = 12
        static let topPadding: CGFloat = 19
        
        static let bottomContentsHspacing: CGFloat = 40
        static let topRightVspacing: CGFloat = 12
        static let bottomRightHspacing: CGFloat = 20
        static let guideHspacing: CGFloat = 18
        static let voiceHspacing: CGFloat = 4
        static let accuracyHspacing: CGFloat = 8
        
        static let offsetValue: CGFloat = 25
        static let maxWidth: CGFloat = 680
        static let mainMaxHeight: CGFloat = 493
        static let mainMaxWidth: CGFloat = 730
        static let capsuleWidth: CGFloat = 6
        static let capsuleHeight: CGFloat = 56
        static let divicerLine: CGFloat = 4
        static let imageSize: CGFloat = 280
        static let voiceBarCount: Int = 8
        static let textTStroke: CGFloat = 5
        static let textBStroke: CGFloat = 3
        static let textCStroke: CGFloat = 1
        
        static let rotationDegree: CGFloat = 35
        static let micImageSize: CGFloat = 36
        static let voiceWidth: CGFloat = 6
        static let voiceAnimation: TimeInterval = 0.1
        static let accuracyText: String = "발음 정확도"
        static let successText: String = "성공"
        
    }
    // MARK: - Body
    var body: some View {
        if let model = viewModel.word {
            ZStack(alignment: .topTrailing, content: {
                VStack {
                    closeBtn
                    topContents(model: model)
                    dividerLine
                    bottomContents
                }
                .safeAreaPadding(WordDetailCardConstants.safePadding)
                .background {
                    RoundedRectangle(cornerRadius: WordDetailCardConstants.cornerRadius)
                        .fill(Color.wordCardYellow)
                        .background(Material.thin)
                }
                .frame(maxWidth: WordDetailCardConstants.maxWidth)
                .offset(x: -WordDetailCardConstants.offsetValue, y: WordDetailCardConstants.offsetValue)
                
                successText
                    .rotationEffect(.degrees(WordDetailCardConstants.rotationDegree))
            })
            .frame(width: WordDetailCardConstants.mainMaxWidth, height: WordDetailCardConstants.mainMaxHeight)
        }
    }
    
    private var closeBtn: some View {
        HStack {
            Spacer()
            Image(.closeBtn)
        }
    }
    
    private var successText: some View {
        Text(WordDetailCardConstants.successText)
            .font(.semibold64)
            .foregroundStyle(Color.green01)
            .customOutline(width: WordDetailCardConstants.textTStroke, color: .white01)
    }
    
    // MARK: - Top
    private func topContents(model: CardModel) -> some View {
        HStack {
            image(model: model)
            Spacer()
            wordText(model: model)
        }
        .safeAreaPadding(.horizontal, WordDetailCardConstants.horizonPadding)
    }
    /// 단어 이미지
    private func image(model: CardModel) -> some View {
        Image(model.imageName)
            .resizable()
            .aspectRatio(contentMode: .fit)
            .frame(width: WordDetailCardConstants.imageSize, height: WordDetailCardConstants.imageSize)
    }
    
    private func wordText(model: CardModel) -> some View {
        VStack(spacing: WordDetailCardConstants.topRightVspacing, content: {
            Text(model.wordEng)
                .font(.semibold64)
                .customOutline(width: WordDetailCardConstants.textTStroke, color: .white)
            
            Text(model.pronunciation)
                .font(.bold32)
                .customOutline(width: WordDetailCardConstants.textBStroke, color: .white)
            
            Text(model.wordKor)
                .font(.bold32)
                .customOutline(width: WordDetailCardConstants.textCStroke, color: .white)
        })
        .foregroundStyle(Color.black)
    }
    
    // MARK: - Bottom
    private var bottomContents: some View {
        HStack(spacing: WordDetailCardConstants.bottomContentsHspacing, content: {
            voiceLevel
            Capsule()
                .fill(Color.voiceShadow)
                .frame(width: WordDetailCardConstants.capsuleWidth, height: WordDetailCardConstants.capsuleHeight)
            pronunciationAccuracy
        })
    }
    
    private var dividerLine: some View {
        Capsule()
            .fill(Color.voiceShadow)
            .frame(width: .infinity, height: WordDetailCardConstants.divicerLine)
    }
    
    // MARK: - Bodttom Right
    private var pronunciationAccuracy: some View {
        HStack(spacing: WordDetailCardConstants.accuracyHspacing, content: {
            Text(WordDetailCardConstants.accuracyText)
                .font(.bold20)
                .foregroundStyle(Color.black01)
            
            printPointGuide(type: viewModel.accuracyType)
        })
    }
    
    @ViewBuilder
    private func printPointGuide(type: AccuracyType) -> some View {
        switch type {
        case .btnMic:
            makeTextView(type: type)
        case .success:
            successFailure(type: type)
        case .failure:
            successFailure(type: type)
        }
    }
    
    private func successFailure(type: AccuracyType) -> some View {
        HStack(spacing: WordDetailCardConstants.guideHspacing, content: {
            Text("\(viewModel.currentScore)")
                .font(type.font)
                .foregroundStyle(type.color)
            
            Label(title: {
                makeTextView(type: type)
            }, icon: {
                Image(type.image ?? .greenCheck)
            })
        })
    }
    
    private func makeTextView(type: AccuracyType) -> some View {
        Text(type.text)
            .font(type.font)
            .foregroundStyle(type.color)
    }
    
    // MARK: - BottomLeft
    private var voiceLevel: some View {
        HStack(spacing: WordDetailCardConstants.voiceHspacing, content: {
            Image(.mic)
                .resizable()
                .aspectRatio(contentMode: .fit)
                .frame(width: WordDetailCardConstants.micImageSize, height: WordDetailCardConstants.micImageSize)
            
            voiceLevelRectangle
        })
    }
    
    private var voiceLevelRectangle: some View {
        HStack(spacing: WordDetailCardConstants.voiceHspacing) {
            ForEach(0..<WordDetailCardConstants.voiceBarCount, id: \.self) { index in
                Capsule()
                    .fill(Color.green02)
                    .frame(
                        width: WordDetailCardConstants.voiceWidth,
                        height: computedBarHeight(
                            relativeIndex: abs(index - WordDetailCardConstants.voiceBarCount / 2)
                        )
                    )
                    .animation(
                        .easeOut(duration: WordDetailCardConstants.voiceAnimation),
                        value: viewModel.voiceLevel
                    )
            }
        }
    }
    
    private func computedBarHeight(relativeIndex: Int) -> CGFloat {
        let base: CGFloat = 24
        let variationStep: CGFloat = 10
        let variation = variationStep * CGFloat(WordDetailCardConstants.voiceBarCount / 2 - relativeIndex)
        
        if viewModel.voiceLevel == 0 {
            return base
        } else {
            return base + variation * CGFloat(viewModel.voiceLevel)
        }
    }
}

#Preview {
    WordDetailCard(viewModel: .init())
}
