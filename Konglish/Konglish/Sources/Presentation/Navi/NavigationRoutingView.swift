//
//  NavigationRoutingView.swift
//  Konglish
//
//  Created by Apple Coding machine on 7/29/25.
//

import SwiftUI
import Dependency

struct NavigationRoutingView: View {
    
    @EnvironmentObject var container: DIContainer
    @State var destination: AppRoute
    
    var body: some View {
        Group {
            switch destination {
            case .category:
                CategorySelectView()
            case .level(let id):
                LevelView(cateogryID: id)
            case .ar(let id):
                //TODO: - AR 뷰 사용
                Text("11")
            }
        }
        .environmentObject(container)
    }
}
