//
//  LevelView.swift
//  Konglish
//
//  Created by Apple MacBook on 7/28/25.
//

import SwiftUI
import SwiftData
import Dependency

struct LevelView: View {
    
    let cateogryID: UUID
    @Query var category: [CategoryModel]
    @State private var selected: Bool = false
    @State private var selectedLevel: LevelModel?
    @EnvironmentObject var container: DIContainer
    
    fileprivate enum LevelCardConstants {
        static let buttonPading: CGFloat = 409
        static let levelVspacing: CGFloat = 77
        static let levelHspacing: CGFloat = 64
        static let naviHspacing: CGFloat = 56
        static let naviTitle: String = "레벨 선택"
    }
    
    var body: some View {
        ZStack {
            Color.green01.ignoresSafeArea()
            
            VStack(spacing: .zero, content: {
                if let category = category.first(where: { $0.id == cateogryID }) {
                    HStack(spacing: LevelCardConstants.levelHspacing, content: {
                        ForEach(
                            category.levels.sorted(by: { $0.levelNumber.numericValue < $1.levelNumber.numericValue }),
                            id: \.id
                        ) { level in
                            LevelCard(level: level, num: level.levelNumber, action: {
                                selectedLevel = level
                            }, isTapped: Binding(
                                get: { selectedLevel?.id == level.id },
                                set: { new in
                                    if new {
                                        selected = new
                                    }
                                }
                            ))
                        }
                    })
                }
            })
        }
        .navigationBarBackButtonHidden(true)
        .overlay(alignment: .topLeading, content: {
            topNavi
        })
        .overlay(alignment: .bottom, content: {
            MainButton(buttonType: .text(.start(onOff: selected)), action: {
                if let id = selectedLevel?.id {
                    container.navigationRouter.push(.ar(levelId: id))
                }
            })
            .safeAreaPadding(.horizontal, UIConstants.horizonBtnPadding)
        })
        .safeAreaPadding(.bottom, UIConstants.bottomPadding)
    }
    
    private var topNavi: some View {
        HStack(spacing: LevelCardConstants.naviHspacing, content: {
            MainButton(buttonType: .icon(.back), action: {
                container.navigationRouter.pop()
            })
            
            Text(LevelCardConstants.naviTitle)
                .font(.semibold64)
                .foregroundStyle(Color.green09)
        })
        .safeAreaPadding(.leading, UIConstants.naviLeadingPadding)
    }
}
