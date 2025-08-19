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
        static let title: UIImage = #imageLiteral(resourceName: "appLogo")
        static let cornerRadius: CGFloat = 20
        static let topPadding: CGFloat = 58
        static let bottomPadding: CGFloat = 58
        static let contentsVspacing: CGFloat = 64
        static let safeHorizonPadding: CGFloat = 160
        static let shadowOffset: CGFloat = 8
    }
    
    var body: some View {
        NavigationStack(path: $container.navigationRouter.path) {
            ZStack {
                Color.green01.ignoresSafeArea()
            }
            .navigationDestination(for: AppRoute.self, destination: { destination in
                NavigationRoutingView(destination: destination)
                    .safeAreaPadding(.top, UIConstants.topPadding)
                    .safeAreaPadding(.bottom, UIConstants.bottomPadding)
            })
            .overlay(alignment: .topLeading, content: {
                title
            })
            .overlay(alignment: .bottom, content: {
                bottomContents
            })
            .overlay(alignment: .center, content: {
                SwipeTabView()
                    .safeAreaPadding(.horizontal, GuidingConstants.safeHorizonPadding)
            })
            .safeAreaPadding(.top, UIConstants.topPadding)
            .safeAreaPadding(.bottom, UIConstants.bottomPadding)
        }
    }
    
    // MARK: - Bottom
    private var bottomContents: some View {
        MainButton(buttonType: .text(.start(onOff: true)), action: {
            container.navigationRouter.push(.category)
        }, shadowOffset: GuidingConstants.shadowOffset)
        .safeAreaPadding(.horizontal, UIConstants.horizonBtnPadding)
    }
    
    private var title: some View {
        Image(uiImage: GuidingConstants.title)
            .resizable()
            .frame(width: 350, height: 100)
            .safeAreaPadding(.leading, UIConstants.naviLeadingPadding)
    }
}

#Preview {
    let container = DIContainer(navigationRouter: NavigationRouter<AppRoute>())
    return GuidingView()
        .environmentObject(container)
}
