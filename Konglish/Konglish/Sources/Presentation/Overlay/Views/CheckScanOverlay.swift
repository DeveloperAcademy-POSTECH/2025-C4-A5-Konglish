//
//  CheckScanOverlay.swift
//  Konglish
//
//  Created by Apple MacBook on 7/29/25.
//

import SwiftUI

struct CheckScanOverlay: View {
    @Bindable var arViewModel: ARViewModel
    let allPlanesDetected: Bool
    
    var body: some View {
        Color.clear
            .overlay(alignment: .top, content: {
                ChekScanCamera(currentCount: $arViewModel.currentDetectedPlanes)
            })
            .overlay(alignment: .topTrailing, content: {
                MainButton(buttonType: .icon(.exit), action: {
                    // TODO: - Stop
                })
                .safeAreaPadding(.trailing, UIConstants.naviLeadingPadding)
            })
            .overlay(alignment: .bottom, content: {
                MainButton(buttonType: .text(.cardSprinkle(onOff: allPlanesDetected)), action: {
                    arViewModel.placeCardsButtonTapped()
                })
                .safeAreaPadding(.horizontal, UIConstants.horizonBtnPadding)
            })
    }
}

#Preview {
    CheckScanOverlay(arViewModel: ARViewModel(), allPlanesDetected: true)
}
