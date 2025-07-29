//
//  PlayingGameOverlay.swift
//  Konglish
//
//  Created by 임영택 on 7/29/25.
//

import SwiftUI

/// 플레잉 중 오버레이
// TODO: 하이파이 디자인 맞추기
struct PlayingGameOverlay: View {
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
