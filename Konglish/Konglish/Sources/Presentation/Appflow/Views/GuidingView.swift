//
//  GuidingView.swift
//  Konglish
//
//  Created by Apple Coding machine on 7/29/25.
//

import SwiftUI
import Dependency

struct GuidingView: View {
    
    @State var viewModel: GuidingViewModel = .init()
    @EnvironmentObject var container: DIContainer
    
    fileprivate enum GuidingConstants {
        static let title: String = "App Title Logo"
        static let cornerRadius: CGFloat = 20
        static let bottomPadding: CGFloat = 58
        static let contentsVspacing: CGFloat = 64
        static let safeHorizonPadding: CGFloat = 160
    }
    
    var body: some View {
        NavigationStack(path: $container.navigationRouter.path) {
            ZStack {
                Color.green01.ignoresSafeArea()
                SwipeTabView()
                    .safeAreaPadding(.horizontal, GuidingConstants.safeHorizonPadding)
            }
            .navigationDestination(for: AppRoute.self, destination: { destination in
                NavigationRoutingView(destination: destination)
            })
            .overlay(alignment: .topLeading, content: {
                title
            })
            .overlay(alignment: .bottom, content: {
                bottomContents
            })
        }
    }
    
    // MARK: - Bottom
    private var bottomContents: some View {
        MainButton(buttonType: .text(.start), action: {
            container.navigationRouter.push(.category)
        })
        .safeAreaPadding(.horizontal, UIConstants.horizonBtnPadding)
        .safeAreaPadding(.bottom, GuidingConstants.bottomPadding)
    }
    
    private var title: some View {
        Text(GuidingConstants.title)
            .font(.semibold64)
            .foregroundStyle(Color.green09)
            .safeAreaPadding(.leading, UIConstants.naviLeadingPadding)
    }
}

#Preview {
    let container = DIContainer(navigationRouter: NavigationRouter<AppRoute>())
    return GuidingView()
        .environmentObject(container)
}
