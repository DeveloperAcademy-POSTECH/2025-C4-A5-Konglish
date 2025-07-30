//
//  Star.swift
//  Konglish
//
//  Created by Apple MacBook on 7/22/25.
//

import SwiftUI

/// 카테고리 선택 시 사용하는 별
struct Star: View {
    
    // MARK: - Property
    let count: Int
    let maxCount: Int = 3
    
    // MARK: - Constants
    fileprivate enum StarConstants {
        static let spacing: CGFloat = 8
    }
    
    // MARK: - Init
    init(count: Int) {
        self.count = count
    }
    
    // MARK: - Body
    var body: some View {
        HStack(spacing: StarConstants.spacing, content: {
            ForEach(.zero..<maxCount, id: \.self) { index in
                if index < count {
                    Image(.starIcon)
                } else {
                    Image(.emptyStar)
                }
            }
        })
    }
}

#Preview {
    Star(count: 2)
}
