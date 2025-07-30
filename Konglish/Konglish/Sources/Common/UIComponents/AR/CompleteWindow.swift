//
//  CompleteWindowView.swift
//  Konglish
//
//  Created by Apple MacBook on 7/24/25.
//

import Foundation
import SwiftUI
import Dependency

struct CompleteWindow: View {
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
        static let titleOutline: CGFloat = 4
        static let scoreOutline: CGFloat = 3
        static let title: String = "Clear!"
        static let subTitle: String = "카테고리로 돌아가기"
    }
    
    var body: some View {
        ZStack {
            Color.black.opacity(0.4)
            
            RoundedRectangle(cornerRadius: CompleteWindowConstants.cornerRadius)
                .fill(Color.white.opacity(0.8))
                .background(Material.ultraThin.quaternary)
            
            VStack {
                title
                score
                MainButton(buttonType: .text(.backMain), action: {
                    container.navigationRouter.reset()
                })
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
            .foregroundStyle(Color.green07)
            .customOutline(width: CompleteWindowConstants.titleOutline, color: .white)
    }
    
    private var score: some View {
        Label(title: {
            Text("\(model.score)")
                .font(.poetsen(.regular, size: 80))
                .foregroundStyle(Color.gray04)
        }, icon: {
            Image(.bin)
        })
    }
}


#Preview {
    CompleteWindow(model: .init(score: 46, level: .init(levelNumber: .easy, category: .init(imageName: "", difficulty: 1, nameKor: "1", nameEng: "2"))))
}
