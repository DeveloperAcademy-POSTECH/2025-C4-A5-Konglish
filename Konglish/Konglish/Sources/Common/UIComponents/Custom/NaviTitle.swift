//
//  NaviTitle.swift
//  Konglish
//
//  Created by Apple MacBook on 7/22/25.
//

import SwiftUI

/// 상단 네비게이션 타이틀 정의
struct NaviTitle: View {
    
    // MARK: - Property
    let naviTitleType: NaviTitleType
    
    // MARK: - Init
    init(naviTitleType: NaviTitleType) {
        self.naviTitleType = naviTitleType
    }
    
    // MARK: - Body
    var body: some View {
        Text(naviTitleType.rawValue)
            .font(naviTitleType.font)
            .foregroundStyle(naviTitleType.color)
    }
}
