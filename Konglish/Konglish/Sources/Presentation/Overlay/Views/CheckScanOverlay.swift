//
//  CheckScanOverlay.swift
//  Konglish
//
//  Created by Apple MacBook on 7/29/25.
//

import SwiftUI

struct CheckScanOverlay: View {
    @Bindable var arViewModel: ARViewModel
    
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
                MainButton(buttonType: .text(.cardSprinkle(onOff: arViewModel.currentDetectedPlanes == arViewModel.gameCards.count)), action: {
                    arViewModel.triggerPlaceCards = true
                })
                .safeAreaPadding(.horizontal, UIConstants.horizonBtnPadding)
            })
    }
}

#Preview {
    let category = CategoryModel(imageName: "동물", difficulty: 0, nameKor: "테스트", nameEng: "Test")
    
    let viewModel = ARViewModel(
        cardModels: [
            .init(imageName: "Apple", pronunciation: "Apple", wordKor: "사과", wordEng: "Apple", category: category),
            .init(imageName: "Banana", pronunciation: "Banana", wordKor: "바나나", wordEng: "Banana", category: category),
            .init(imageName: "Orange", pronunciation: "Orange", wordKor: "오렌지", wordEng: "Orange", category: category),
        ],
        categoryModel: category,
        levelType: .easy
    )
    CheckScanOverlay(arViewModel: viewModel)
}
