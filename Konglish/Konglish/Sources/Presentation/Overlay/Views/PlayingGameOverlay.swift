//
//  PlayingGameOverlay.swift
//  Konglish
//
//  Created by 임영택 on 7/29/25.
//

import SwiftUI
import Dependency
import ARCore

/// 플레잉 중 오버레이
struct PlayingGameOverlay: View {
    @Bindable var arViewModel: ARViewModel
    @EnvironmentObject var container: DIContainer
    
    fileprivate enum PlayingGameConstants {
        static let guideWidth: CGFloat = 749
        static let guideHeight: CGFloat = 67
        static let horizonPadding: CGFloat = 40
        static let cornerRadius: CGFloat = 20
        static let guideText: String = "가운데의 조준점을 카드 위에 대고 버튼을 눌러주세요"
    }
    
    var body: some View {
        ZStack {
            Color.black.opacity(0.4).ignoresSafeArea()
        }
        .overlay(alignment: .topLeading, content: {
            GameStatus(currentScore: $arViewModel.currentGameScore, currentCard: $arViewModel.numberOfFinishedCards, currentLife: $arViewModel.currentLifeCounts)
        })
        .overlay(alignment: .topTrailing, content: {
            pauseBtn
        })
        .overlay(alignment: .bottom, content: {
            bottonGuide
        })
        .overlay(alignment: .bottomLeading, content: {
            targetBtn
        })
        .overlay(alignment: .bottomTrailing, content: {
            targetBtn
        })
        .overlay(content: {
            Image(.aim)
        })
        .safeAreaPadding(.top, UIConstants.topPadding)
        .safeAreaPadding(.horizontal, PlayingGameConstants.horizonPadding)
        .safeAreaPadding(.bottom, UIConstants.bottomPadding)
        .navigationBarBackButtonHidden(true)
    }
    
    private var pauseBtn: some View {
        MainButton(buttonType: .icon(.exit), action: {
            container.navigationRouter.pop()
        })
    }
    
    private var targetBtn: some View {
        MainButton(buttonType: .icon(.target), action: {
            arViewModel.triggerFlipCard = true
        })
    }
    
    private var bottonGuide: some View {
        ZStack {
            RoundedRectangle(cornerRadius: PlayingGameConstants.cornerRadius)
                .fill(Color.white01)
                .background(Material.ultraThin)
                .clipShape(RoundedRectangle(cornerRadius: PlayingGameConstants.cornerRadius))
                .whiteShadow()
                .frame(width: PlayingGameConstants.guideWidth, height: PlayingGameConstants.guideHeight)
            
            Text(PlayingGameConstants.guideText)
                .font(.semibold32)
                .foregroundStyle(Color.black01)
        }
    }
    
    
    private func checkBtnAction() -> Bool {
        return arViewModel.currentDetectedPlanes > 0 ? true : false
    }
    
}


#Preview {
    PlayingGameOverlay(arViewModel: .init(), container: .init())
}
