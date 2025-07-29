//
//  CheckScanOverlay.swift
//  Konglish
//
//  Created by Apple MacBook on 7/29/25.
//

import SwiftUI

struct CheckScanOverlay: View {
    
    @State var checkCount: Int = 0
    @State var cardSprinkle: Bool = false
    
    var body: some View {
        Color.clear
            .overlay(alignment: .top, content: {
                ChekScanCamera(currentCount: $checkCount)
            })
            .overlay(alignment: .topTrailing, content: {
                MainButton(buttonType: .icon(.exit), action: {
                    // TODO: - Stop
                })
                .safeAreaPadding(.trailing, UIConstants.naviLeadingPadding)
            })
            .overlay(alignment: .bottom, content: {
                MainButton(buttonType: .text(.cardSprinkle(onOff: cardSprinkle)), action: {
                    
                })
                .safeAreaPadding(.horizontal, UIConstants.horizonBtnPadding)
            })
    }
}

#Preview {
    CheckScanOverlay()
}
