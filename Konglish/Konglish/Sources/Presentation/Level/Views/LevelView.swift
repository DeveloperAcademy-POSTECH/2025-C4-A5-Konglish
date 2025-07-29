//
//  LevelView.swift
//  Konglish
//
//  Created by Apple MacBook on 7/28/25.
//

import SwiftUI

struct LevelView: View {
    
    let category: CategoryModel
    @State private var selected: Bool = false
    
    fileprivate enum LevelCardConstants {
        static let buttonPading: CGFloat = 409
        static let levelVspacing: CGFloat = 77
        static let levelHspacing: CGFloat = 64
        static let naviHspacing: CGFloat = 56
        static let naviTitle: String = "레벨 선택"
    }
    
    var body: some View {
        NavigationStack {
            ZStack {
                Color.green01.ignoresSafeArea()
                
                VStack(spacing: .zero, content: {
                    HStack(content: {
                        ForEach(category.levels, id: \.id) { level in
                            LevelCard(level: level, num: level.levelNumber, action: {
                                // TODO: - 버튼 레벨 저장
                            }, isTapped: $selected)
                        }
                    })
                    
                    Spacer()
                    
                    MainButton(buttonType: .text(.start), action: {
                        // TODO: - AR View 진입
                    })
                    .safeAreaPadding(.horizontal, UIConstants.horizonBtnPadding)
                })
            }
            .navigationBarBackButtonHidden(true)
            .overlay(alignment: .topLeading, content: {
                topNavi
            })
        }
    }
    
    private var topNavi: some View {
        HStack(spacing: LevelCardConstants.naviHspacing, content: {
            MainButton(buttonType: .icon(.back), action: {
                print("Hello")
            })
            
            Text(LevelCardConstants.naviTitle)
                .font(.semibold64)
                .foregroundStyle(Color.green09)
        })
        .safeAreaPadding(.leading, UIConstants.naviLeadingPadding)
    }
}

#Preview {
    @Previewable @State var selected: Bool = false
    
    LevelView(category: .init(imageName: "11", difficulty: 1, nameKor: "11", nameEng: "22"))
}
