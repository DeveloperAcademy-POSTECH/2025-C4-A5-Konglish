//
//  CheckScanOverlay.swift
//  Konglish
//
//  Created by Apple MacBook on 7/29/25.
//

import SwiftUI
import Dependency

struct CheckScanOverlay: View {
    @Bindable var arViewModel: ARViewModel
    @EnvironmentObject var container: DIContainer
    let allPlanesDetected: Bool
    
    var body: some View {
        Color.clear
            .overlay(alignment: .top, content: {
                ChekScanCamera(currentCount: $arViewModel.currentDetectedPlanes)
            })
            .overlay(alignment: .topTrailing, content: {
                MainButton(buttonType: .icon(.exit), action: {
                    container.navigationRouter.pop()
                })
            })
            .overlay(alignment: .bottom, content: {
                MainButton(buttonType: .text(.cardSprinkle(onOff: allPlanesDetected)), action: {
                    arViewModel.placeCardsButtonTapped()
                })
                .safeAreaPadding(.horizontal, UIConstants.horizonBtnPadding)
            })
            .navigationBarBackButtonHidden(true)
            .safeAreaPadding(.trailing, UIConstants.naviLeadingPadding)
            .safeAreaPadding(.bottom, UIConstants.bottomPadding)
            .safeAreaPadding(.top, UIConstants.topPadding)
    }
}

#Preview {
    CheckScanOverlay(arViewModel: ARViewModel(), allPlanesDetected: true)
}
