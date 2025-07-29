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
    StartOverlay(arViewModel: ARViewModel())
}
