//
//  ExitOption.swift
//  Konglish
//
//  Created by Apple MacBook on 7/29/25.
//

import SwiftUI
import Dependency

struct ExitOptionWindow: View {
    @EnvironmentObject var container: DIContainer
    let onContinue: () -> Void
    
    fileprivate enum ExitOptionWindowConstants {
        static let cornerRadius: CGFloat = 30
        static let btnHspacing: CGFloat = 80
        static let bgWidth: CGFloat = 502
        static let bgHeight: CGFloat = 308
        static let imageSize: CGFloat = 100
        static let btnSize: CGFloat = 136
        static let leftText: String = "계속하기"
        static let rightText: String = "나가기"
    }
    var body: some View {
        ZStack {
            RoundedRectangle(cornerRadius: ExitOptionWindowConstants.cornerRadius)
                .fill(Material.ultraThin)
                .overlay(
                    RoundedRectangle(cornerRadius: ExitOptionWindowConstants.cornerRadius)
                        .fill(Color.white)
                )
                .grayShadow()
                .frame(width: ExitOptionWindowConstants.bgWidth, height: ExitOptionWindowConstants.bgHeight)
            
            btnGroup
        }
    }
    
    private var btnGroup: some View {
        HStack(spacing: ExitOptionWindowConstants.btnHspacing, content: {
            Button(action: {
                onContinue()
            }, label: {
                makeBtn(image: .continue, btnText: ExitOptionWindowConstants.leftText)
            })
            
            Button(action: {
                container.navigationRouter.pop()
            }, label: {
                makeBtn(image: .exit, btnText: ExitOptionWindowConstants.rightText)
            })
        })
    }
    
    
    private func makeBtn(image: ImageResource, btnText: String) -> some View {
        VStack {
            ZStack {
                RoundedRectangle(cornerRadius: ExitOptionWindowConstants.cornerRadius)
                    .fill(Color.green02)
                    .frame(width: ExitOptionWindowConstants.btnSize, height: ExitOptionWindowConstants.btnSize)
                    .mainButtonShadow(shadowColor: Color.green09)
                
                Image(image)
                    .resizable()
                    .frame(width: ExitOptionWindowConstants.imageSize, height: ExitOptionWindowConstants.imageSize)
                
            }
            
            Text(btnText)
                .font(.bold32)
                .foregroundStyle(Color.black01)
        }
    }
}

#Preview {
    ExitOptionWindow(onContinue: {})
}
