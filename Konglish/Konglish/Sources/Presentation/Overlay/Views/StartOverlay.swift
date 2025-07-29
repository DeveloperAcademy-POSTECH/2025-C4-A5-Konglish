//
//  StartOverlay.swift
//  Konglish
//
//  Created by Apple MacBook on 7/28/25.
//

import SwiftUI

struct StartOverlay: View {
    var arViewModel: ARViewModel
    
    // MARK: - Constants
    fileprivate enum StartOverlayConstants {
        static let opacity: Double = 0.4
        static let guidPadding: CGFloat = 222
        static let cornerRadius: CGFloat = 20
        static let guideHeight: CGFloat = 67
        static let guideText: String = "준비가 되었다면 시작해볼까요?"
    }
    var body: some View {
        ZStack {
            Color.black.opacity(StartOverlayConstants.opacity).ignoresSafeArea()
            
            VStack {
                Spacer()
                guideText
                Spacer()
                MainButton(buttonType: .text(.start), action: {
                    arViewModel.startButtonTapped()
                })
                .safeAreaPadding(.horizontal, UIConstants.horizonBtnPadding)
            }
        }
        .overlay(alignment: .topLeading, content: {
            MainButton(buttonType: .icon(.back), action: {
              //TODO: - 종료
            })
            .safeAreaPadding(.horizontal, UIConstants.naviLeadingPadding)
        })
    }
    
    private var guideText: some View {
        ZStack {
            RoundedRectangle(cornerRadius: StartOverlayConstants.cornerRadius)
                .fill(Material.ultraThin)
                .frame(height: StartOverlayConstants.guideHeight)
                .whiteShadow()
            
            Text(StartOverlayConstants.guideText)
                .font(.semibold24)
                .foregroundStyle(Color.black)
        }
        .safeAreaPadding(.horizontal, StartOverlayConstants.guidPadding)
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
    StartOverlay(arViewModel: viewModel)
}
