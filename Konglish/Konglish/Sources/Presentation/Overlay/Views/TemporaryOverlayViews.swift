//
//  TemporaryOverlayViews.swift
//  Konglish
//
//  Created by 임영택 on 7/29/25.
//

import SwiftUI

// FIXME: 플레잉 중의 오버레이가 완성되면 삭제해주세요
struct TemporaryPlayingOverlay: View {
    var arViewModel: ARViewModel
    
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
                MainButton(buttonType: .icon(.aim)) {
                    arViewModel.flipCardButtonTapped()
                }
                
                Spacer()
                
                MainButton(buttonType: .icon(.aim)) {
                    arViewModel.flipCardButtonTapped()
                }
            }
        }
        .padding(.vertical, 40)
        .padding(.horizontal, 36)
    }
}

// FIXME: 플레잉 중 카드 포커스 시 오버레이가 완성되면 삭제해주세요
struct TemporaryPlayingOnShowingCardOverlay: View {
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

struct TemporaryFinishedOverlay: View {
    var arViewModel: ARViewModel
    
    var body: some View {
        CompleteWindow(model: .init(score: arViewModel.currentGameScore, level: .init(levelNumber: .easy, category: .init(imageName: "몰라", difficulty: 3, nameKor: "몰라", nameEng: "아돈노"))))
    }
}
