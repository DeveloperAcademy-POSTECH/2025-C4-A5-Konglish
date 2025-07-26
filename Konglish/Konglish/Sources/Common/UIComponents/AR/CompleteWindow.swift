//
//  CompleteWindowView.swift
//  Konglish
//
//  Created by Apple MacBook on 7/24/25.
//

import Foundation
import SwiftUI

struct CompleteWindow: View {
    let model: GameSessionModel
    
    fileprivate enum CompleteWindowConstants {
        static let maxWidth: CGFloat = 749
        static let mainVerticalPadding: CGFloat = 70
        static let mainHorizonPadding: CGFloat = 167
        static let verticalPadding: CGFloat = 14
        static let horizonPadding: CGFloat = 30
        static let cornerRadius: CGFloat = 30
        static let titleOutline: CGFloat = 4
        static let scoreOutline: CGFloat = 3
        static let title: String = "Complete"
        static let subTitle: String = "첫 화면으로 돌아가기"
    }
    
    var body: some View {
        VStack {
            title
            score
            MainButton(buttonType: .text(.backMain), action: {
                print("Hello")
            })
        }
        .padding(.vertical, CompleteWindowConstants.mainVerticalPadding)
        .padding(.horizontal, CompleteWindowConstants.mainHorizonPadding)
        .background(Material.thin, in: RoundedRectangle(cornerRadius: CompleteWindowConstants.cornerRadius))
        .frame(maxWidth: CompleteWindowConstants.maxWidth)
    }
    
    private var title: some View {
        Text(CompleteWindowConstants.title)
            .font(.semibold64)
            .foregroundStyle(Color.secondary01)
            .customOutline(width: CompleteWindowConstants.titleOutline, color: .white)
    }
    
    private var score: some View {
        Text(verbatim: "Scroe \(model.score)")
            .font(.semibold32)
            .foregroundStyle(Color.secondary01)
    }
}

#Preview {
    CompleteWindow(model: .init(playedAt: .now, score: 2024, level: .init(levelNumber: 0, category: .init(imageName: "", difficulty: 2, nameKor: "11", nameEng: "11"))))
}
