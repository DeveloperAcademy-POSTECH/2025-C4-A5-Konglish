//
//  DIContainer.swift
//  Config
//
//  Created by Apple MacBook on 7/18/25.
//

import Foundation

public final class DIContainer: ObservableObject {
    @Published public var navigationRouter: NavigationRouter<AppRoute>
    
    public init(navigationRouter: NavigationRouter<AppRoute>) {
        self.navigationRouter = navigationRouter
    }
}
