//
//  OnShowingCardOverlay.swift
//  Konglish
//
//  Created by 임영택 on 7/29/25.
//

import SwiftUI

/// 플레잉 중 카드 뒤집혔을 때 오버레이
// TODO: 하이파이 디자인 맞추기
struct OnShowingCardOverlay: View {
    var arViewModel: ARViewModel
    @State private var detailCardViewModel = DetailCardViewModel()
    
    var body: some View {
        VStack {
            HStack {
                VStack {
                    Text("하트: \(arViewModel.currentLifeCounts)")
                    Text("점수: \(arViewModel.currentGameScore)")
                    Text("완료 수: \(arViewModel.numberOfFinishedCards)")
                }
                
                Spacer()
                
                MainButton(buttonType: .icon(.exit)) {
                    print("pause button tapped")
                }
            }
            
            Spacer()
            
            Text("+")
                .font(.system(size: 32, weight: .bold))
            
            Spacer()
            
            HStack(alignment: .bottom) {
                VStack {
                    // TODO: WordDetailCard 카드에 점수 제출 로직이 들어가면 이 버튼은 지워주세요
                    // 디버그용 제출 버튼
                    Button {
                        if let cardId = arViewModel.flippedCardId {
                            arViewModel.triggerSubmitAccuracy = (cardId, 0.9)
                        }
                        arViewModel.showingWordDetailCard = false
                        arViewModel.flippedCardId = nil
                    } label: {
                        Text("제출성공")
                            .background {
                                Rectangle()
                                    .background(Color.primary)
                                    .frame(width: 96, height: 96)
                            }
                    }
                    
                    Spacer()
                        .frame(height: 72)
                    
                    MainButton(buttonType: .icon(.sound)) {
                        // TODO: 발음 재생 기능
                    }
                }
                
                Spacer()
                
                VStack {                    
                    Spacer()
                        .frame(height: 72)
                    
                    MainButton(buttonType: .icon(.mic)) {
                        // TODO: 녹음 및 제출 기능
                    }
                }
            }
        }
        .overlay {
            if arViewModel.showingWordDetailCard {
                WordDetailCard(viewModel: detailCardViewModel)
            }
        }
        .padding(.vertical, 40)
        .padding(.horizontal, 36)
    }
}
