//
//  CompleteWindowView.swift
//  Konglish
//
//  Created by Apple MacBook on 7/24/25.
//

import Foundation
import SwiftUI
import Dependency

struct FailureWindow: View {
    let model: GameSessionModel
    @EnvironmentObject var container: DIContainer
    
    fileprivate enum CompleteWindowConstants {
        static let maxWidth: CGFloat = 749
        static let safeAreaVerticalPadding: CGFloat = 203
        static let safeAreaHorionPadding: CGFloat = 222
        static let mainVerticalPadding: CGFloat = 70
        static let mainHorizonPadding: CGFloat = 167
        static let verticalPadding: CGFloat = 14
        static let horizonPadding: CGFloat = 30
        static let cornerRadius: CGFloat = 30
        static let btnVspacing: CGFloat = 26
        static let titleOutline: CGFloat = 4
        static let title: String = "Game Over!"
        static let subTitle: String = "카테고리로 돌아가기"
    }
    
    var body: some View {
        ZStack {
            RoundedRectangle(cornerRadius: CompleteWindowConstants.cornerRadius)
                .fill(Color.white01)
                .background(Material.ultraThin)
                .grayShadow()
            
            VStack {
                title
                btnContents
            }
            .padding(.vertical, CompleteWindowConstants.mainVerticalPadding)
            .padding(.horizontal, CompleteWindowConstants.mainHorizonPadding)
            .frame(maxWidth: CompleteWindowConstants.maxWidth)
        }
        .safeAreaPadding(.vertical, CompleteWindowConstants.safeAreaVerticalPadding)
        .safeAreaPadding(.horizontal, CompleteWindowConstants.safeAreaHorionPadding)
    }
    
    private var title: some View {
        Text(CompleteWindowConstants.title)
            .font(.semibold64)
            .foregroundStyle(Color.red01)
            .customOutline(width: CompleteWindowConstants.titleOutline, color: .white)
    }
    
    private var btnContents: some View {
        VStack(spacing: CompleteWindowConstants.btnVspacing, content: {
            MainButton(buttonType: .text(.returnCategory), action: {
                container.navigationRouter.reset()
            })
        })
    }
}


#Preview {
    FailureWindow(model: .init(score: 46, level: .init(levelNumber: .easy, category: .init(imageName: "", difficulty: 1, nameKor: "1", nameEng: "2"))))
}
