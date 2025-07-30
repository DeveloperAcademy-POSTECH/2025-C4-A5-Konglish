//
//  FinishedOverlay.swift
//  Konglish
//
//  Created by 임영택 on 7/29/25.
//

import SwiftUI

struct FinishedOverlay: View {
    let gameSessionModel: GameSessionModel
    
    var body: some View {
        ZStack {
            Color.black.opacity(0.4).ignoresSafeArea()
        }
        .overlay(alignment: .center, content: {
            CompleteWindow(model: gameSessionModel)
                .navigationBarBackButtonHidden(true)
        })
        .safeAreaPadding(.horizontal, UIConstants.horizontalPading)
        
    }
}
