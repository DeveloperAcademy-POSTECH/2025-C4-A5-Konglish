//
//  LevelCard.swift
//  Konglish
//
//  Created by Apple MacBook on 7/22/25.
//

import SwiftUI

struct CategoryCard: View {
    
    // MARK: - Property
    let categoryModel: CategoryModel
    let action: () -> Void
    
    // MARK: - Property
    fileprivate enum CategoryConstants {
        static let cornerRadius: CGFloat = 20
        static let cardTopPadding: CGFloat = 8
        static let cardInfoVspacing: CGFloat = 8
        static let cardContetnsVspacing: CGFloat = 12
        
        static let cardWidth: CGFloat = 280
        static let cardBottomHeight: CGFloat = 448
        static let cardTopHeight: CGFloat = 440
    }
    
    // MARK: - Init
    init(categoryModel: CategoryModel, action: @escaping () -> Void) {
        self.categoryModel = categoryModel
        self.action = action
    }
    
    // MARK: - Body
    var body: some View {
        Button(action: {
            
        }, label: {
            ZStack(alignment: .top, content: {
                RoundedRectangle(cornerRadius: CategoryConstants.cornerRadius)
                    .fill(Color.gray01)
                    .frame(width: CategoryConstants.cardWidth, height: CategoryConstants.cardBottomHeight)
                
                topArea
            })
        })
    }
    
    // MARK: - TopArea
    private var topArea: some View {
        ZStack {
            RoundedRectangle(cornerRadius: CategoryConstants.cornerRadius)
                .fill(Color.white)
                .frame(width: CategoryConstants.cardWidth, height: CategoryConstants.cardTopHeight)
            
            cardContetns
        }
    }
    
    // MARK: - Top
    private var cardContetns: some View {
        VStack(spacing: CategoryConstants.cardContetnsVspacing, content: {
            Image(categoryModel.imageName)
            cardInfo
        })
    }
    
    // MARK: - Bottom
    /// 카드 하단 정보
    private var cardInfo: some View {
        VStack(spacing: CategoryConstants.cardInfoVspacing, content: {
            Star(count: categoryModel.difficulty)
            title
            subTitle
        })
    }
    
    /// 카테고리 제목
    private var title: some View {
        Text(categoryModel.nameKor)
            .font(.bold32)
            .foregroundStyle(.gray03)
    }
    
    /// 카테고리 영어 제목
    private var subTitle: some View {
        Text(categoryModel.nameEng)
            .font(.bold20)
            .foregroundStyle(.gray02)
    }
}
