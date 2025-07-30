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
                .safeAreaPadding(.trailing, UIConstants.naviLeadingPadding)
            })
            .overlay(alignment: .bottom, content: {
                MainButton(buttonType: .text(.cardSprinkle(onOff: allPlanesDetected)), action: {
                    arViewModel.placeCardsButtonTapped()
                })
                .safeAreaPadding(.horizontal, UIConstants.horizonBtnPadding)
            })
            .navigationBarBackButtonHidden(true)
            .safeAreaPadding(.horizontal, UIConstants.naviLeadingPadding)
            .safeAreaPadding(.bottom, UIConstants.bottomPadding)
            .safeAreaPadding(.top, 20)
    }
}

#Preview {
    CheckScanOverlay(arViewModel: ARViewModel(), allPlanesDetected: true)
}
