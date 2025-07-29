//
//  SuccessProgress.swift
//  Konglish
//
//  Created by Apple MacBook on 7/22/25.
//

import SwiftUI

/// 카드 레벨 프로그레스 바
struct SuccessProgress: View {
    
    // MARK: - Property
    let currentCount: Int
    let maxCount: Int = 40
    var progressValue: Double {
        Double(currentCount) / Double(maxCount)
    }
    
    // MARK: - Constants
    fileprivate enum SuccessProgressConstants {
        static let cornerRadius: CGFloat = 20
        static let progressTopHeight: CGFloat = 26
        static let progressBottomHeight: CGFloat = 30
        static let cardInfoHspacing: CGFloat = 17
    }
    
    // MARK: - Init
    init(currentCount: Int) {
        self.currentCount = currentCount
    }
    
    // MARK: - Body
    var body: some View {
        ZStack {
            progressBarBg(bottom: .bgShadow, top: .progressBg)
            GeometryReader { geo in
                progressBarBg(bottom: .tintShadow, top: .green05)
                    .frame(width: geo.size.width * progressValue)
            }
            successInfo
        }
        .frame(height: SuccessProgressConstants.progressBottomHeight)
    }
    
    // MARK: - BottomArea
    
    /// 프로그레스 내부 카드 갯수 정보 표시
    private var successInfo: some View {
        HStack(spacing: SuccessProgressConstants.cardInfoHspacing, content: {
            Image(.successCard)
            Text("\(currentCount) / \(maxCount)")
                .font(.bold20)
                .foregroundStyle(Color.white)
        })
    }
    
    
    // MARK: - Common
    /// 프로그레스 백그라운드 바 생성
    /// - Parameters:
    ///   - bottom: 아래 영역 컬러
    ///   - top: 윗 영역 컬러
    /// - Returns: 프로그레스 막대 생성
    private func progressBarBg(bottom: Color, top: Color) -> some View {
        ZStack(alignment: .top, content: {
            RoundedRectangle(cornerRadius: SuccessProgressConstants.cornerRadius)
                .fill(bottom)
            
            RoundedRectangle(cornerRadius: SuccessProgressConstants.cornerRadius)
                .fill(top)
                .frame(height: SuccessProgressConstants.progressTopHeight)
        })
    }
}

#Preview {
    SuccessProgress(currentCount: 30)
}
