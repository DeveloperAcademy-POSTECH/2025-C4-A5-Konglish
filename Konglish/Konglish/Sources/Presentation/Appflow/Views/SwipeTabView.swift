//
//  SwipeTabView.swift
//  Konglish
//
//  Created by Apple Coding machine on 7/29/25.
//

import SwiftUI
import Lottie

struct SwipeTabView: View {
    @State var selectedIndex = 0
    let totalPages = 3
    
    fileprivate enum GuideCardConstants {
        static let cardGuideHeight: CGFloat = 480
        static let contentsWidth: CGFloat = 804
        static let contentsHeight: CGFloat = 425
        static let cornerRadiust: CGFloat = 20
        static let padding: CGFloat = 30
        static let bgWidth: CGFloat = 756
        static let bgHeight: CGFloat = 339
        static let cornerRadius: CGFloat = 20
        static let guideVspacing: CGFloat = 16
        static let guideCircleSize: CGFloat = 12
        static let pageHspacing: CGFloat = 8
        static let lineWidth: CGFloat = 4
    }
    
    var body: some View {
        VStack(spacing: GuideCardConstants.guideVspacing, content: {
            TabView(selection: $selectedIndex, content: {
                ForEach(0..<3) { index in
                    card(index: index)
                        .tag(index)
                }
            })
            .tabViewStyle(.page(indexDisplayMode: .never))
            
            pageControl
        })
        .padding(GuideCardConstants.padding)
        .background {
            RoundedRectangle(cornerRadius: GuideCardConstants.cornerRadius)
                .fill(Color.white)
                .grayShadow()
        }
        .frame(maxHeight: GuideCardConstants.cardGuideHeight)
    }
    
    private func card(index: Int) -> some View {
        ZStack {
            RoundedRectangle(cornerRadius: GuideCardConstants.cornerRadius)
                .fill(Color.white01)
                .stroke(Color.gray01, style: .init(lineWidth: GuideCardConstants.lineWidth))
            
            LottieView(animation: .named(lottieName(for: index)))
                .playing()
                .looping()
        }
        .frame(width: GuideCardConstants.bgWidth, height: GuideCardConstants.bgHeight)
    }
    
    private var pageControl: some View {
        HStack(spacing: GuideCardConstants.pageHspacing, content: {
            ForEach(0..<totalPages, id: \.self) { index in
                Circle()
                    .fill(index == selectedIndex ? Color.green02 : Color.gray01)
                    .frame(width: GuideCardConstants.guideCircleSize)
            }
        })
    }
    
    private func lottieName(for index: Int) -> String {
        switch index {
        case 0: return "one"
        case 1: return "two"
        case 2: return "three"
        default: return ""
        }
    }
}

#Preview {
    SwipeTabView()
}
