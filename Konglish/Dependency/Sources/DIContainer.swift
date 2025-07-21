//
//  DIContainer.swift
//  Config
//
//  Created by Apple MacBook on 7/18/25.
//

import Foundation

@Observable
public final class DIContainer {
    public let navigationRouter: NavigationRouter<AppRoute>
    
    public init(navigationRouter: NavigationRouter<AppRoute>) {
        self.navigationRouter = navigationRouter
    }
}
